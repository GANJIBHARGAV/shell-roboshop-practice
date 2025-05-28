#!/bin/bash
userid=$(id -u)
roboshopid=$(id roboshop)
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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling the nodejs" 
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling the nodejs"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing the nodejs"

if [ $roboshopid -ne 0 ]
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

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading the catalogue code in zip mode"
cd /app 
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzipping the code"
npm install &>>$LOG_FILE
VALIDATE $? "Installing the node package manager"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
systemctl daemon-reload 
VALIDATE $? "Daemon reload catalogue service"

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enabling the catalogue"
systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "starting the catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "To have mongo client installed we have to setup MongoDB repo and install mongodb-client"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb client machine to connect to database"

mongosh --host mongodb.bhargavcommerce.shop </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "for loading the data into the tables or schema"




