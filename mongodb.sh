#!/bin/bash
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
echo "$2 is installed... SUCCESS" | tee -a $LOG_FILE
else
echo "$2 is not installed... FAILED" | tee -a $LOG_FILE
exit 1
fi
}