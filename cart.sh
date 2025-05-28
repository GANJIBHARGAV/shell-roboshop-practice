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

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading the cart code in zip mode"

rm -rf /app/*
cd /app 
unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "unzipping the code"
npm install &>>$LOG_FILE
VALIDATE $? "Installing the node package manager"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
systemctl daemon-reload 
VALIDATE $? "Daemon reload cart service"

systemctl enable cart &>>$LOG_FILE
VALIDATE $? "enabling the cart"
systemctl start cart &>>$LOG_FILE
VALIDATE $? "starting the cart"

ENDTIME=$(date +%s)
TOTAL_TIME=$(($ENDTIME-$STARTTIME))
echo "Scripted completed within $TOTAL_TIME seconds"






