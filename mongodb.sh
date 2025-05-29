#!/bin/bash
STARTTIME=$(date +%s)
userid=$(id -u)
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_FILE=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_FILE.log"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Mongodb installation" 

systemctl enable mongod  &>>$LOG_FILE
VALIDATE $? "Enable the mongodb " 

systemctl start mongod  &>>$LOG_FILE
VALIDATE $? "Starting mongodb" 
# using stream editor to change the ip address from 127.0.0.1 to 0.0.0.0 by giving this command because
#through vim editor we cant modify for programs s--> substitute g--> global
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 
VALIDATE $? "Editing mongodb configuration file for remote connection"
systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting the mongodb"

ENDTIME

