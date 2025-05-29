#!/bin/bash
STARTTIME=$(date +%s)
userid=$(id -u)
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_FILE=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_FILE.log"
SCRIPT_DIR=$PWD


mkdir -p $LOGS_FOLDER
echo "Script execution started at $(date)" | tee -a $LOG_FILE
if [ $userid -ne 0 ]
then
echo "Error:: please run with root user" | tee -a $LOG_FILE
exit 1
else
echo "Super.. under the root user only" | tee -a $LOG_FILE
fi

echo "Enter root password"
read -s MY_ROOT_PASSWORD
# validate function is used to take input1 as exit status and input2 as server as $1 ans $2
VALIDATE(){
    if [ $1 -eq 0 ]
then
echo "$2 ... SUCCESS" | tee -a $LOG_FILE
else
echo "$2 ... FAILED" | tee -a $LOG_FILE
exit 1
fi
}
dnf install maven -y
VALIDATE $? "Installing maven"

id roboshop
if [ $? -ne 0 ]
then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "creating the system user"
else
echo "System user already created... skipping"
fi

# creating the app directory 
# -p ignores the failure if the directory already created
mkdir -p /app
VALIDATE $? "creating the app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading the shipping code in zip mode"

rm -rf /app/*
cd /app 
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping the code"

mvn clean package &>>$LOG_FILE &>>$LOG_FILE
VALIDATE $? "Instaling the maven package"
mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "Moving the target jar files"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "Copying the shipping service to etc file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload shipping service"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "enabling the shipping"
systemctl start shipping &>>$LOG_FILE
VALIDATE $? "starting the shipping"

dnf install mysql -y
VALIDATE $? "Installing mysql"

mysql -h mysql.bhargavcommerce.shop -uroot -p$MY_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
mysql -h mysql.bhargavcommerce.shop -uroot -p$MY_ROOT_PASSWORD < /app/db/app-user.sql &>>$LOG_FILE
mysql -h mysql.bhargavcommerce.shop -uroot -p$MY_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE

systemctl restart shipping
VALIDATE $? "Restarting the shipping "



