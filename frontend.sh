#!/bin/bash
userid=$(id -u)
#roboshopid=$(id roboshop)
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

dnf module list nginx &>>$LOG_FILE
VALIDATE $? "Listing the nginx modules"

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling the nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling the nginx"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing the nginx"

systemctl enable nginx 
VALIDATE $? "Enabling the nginx server"

systemctl start nginx 
VALIDATE $? "Starting the nginx server"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing the default html content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading the code"

cd /usr/share/nginx/html &>>$LOG_FILE
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the code"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "Removing the default nginx conf"
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying the nginx conf"

systemctl restart nginx
VALIDATE $? "Restarting the nginx server"

