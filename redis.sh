#!/bin/bash
STARTTIME=$(date +%s)
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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabiling the redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enable the redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing the redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode c protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Edited the redis conf to connect remote server"

systemctl enable redis 
VALIDATE $? "Enable the redis"

systemctl start redis
VALIDATE $? "Start the redis" 

ENDTIME=$(date +%s)
TOTAL_TIME=$(($ENDTIME-$STARTTIME))
echo "Script executed total time is $TOTAL_TIME seconds"