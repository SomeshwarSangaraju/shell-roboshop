#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." f1)
LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME.log      #/var/log/shell-roboshop/16-logs.log
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)

mkdir -p $LOG_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

#root user is created at starting so root id is 0
if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run the script with root previlages"
    exit 1
fi

#checking the package is success or failure
VALIDATE(){
    if [ $? -ne 0 ]; then
        echo -e "$1 ...... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$1 ........ $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}
    
# cp $SCRIPT_DIR/mongo.repo /etc/yum.repo.d/mongo.repo
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE "Adding mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE "Installing mongodb"

systemctl enable mongod &>>$LOG_FILE
VALIDATE "Enabling mongodb"

systemctl start mongod &>>$LOG_FILE
VALIDATE "Starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE "Allowing remote connections to mongodb"

systemctl restart mongod
VALIDATE "Restarting mongodb"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"