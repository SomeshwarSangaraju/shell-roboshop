#!/bin/bash

USERID=$(id -u)
echo " $USERID "

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER='/var/log/shell-roboshop'
SCRIPT_NAME=$(echo $0 | cut -d "." f1)
LOG_FILES=$LOG_FOLDER/$SCRIPT_NAME.log      #/var/log/shell-roboshop/16-logs.log
SCRIPT_DIR=$PWD

mkdir -p $LOG_FOLDER
#root user is created at starting so root id is 0
if [ $USERID -ne 0 ]; then
    echo "Please run the script with root previlages"
    exit 1
fi

#checking the package is success or failure
VALIDATE(){
    if [ $? -ne 0 ]; then
        echo -e "$1 ...... $R FAILURE $N"
        exit 1
    else
        echo -e "$1 ........ $G SUCCESS $N"
    fi
}
    
# cp $SCRIPT_DIR/mongo.repo /etc/yum.repo.d/mongo.repo
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE "Adding mongo repo"


dnf install mongodb-org -y 
VALIDATE "Installing mongodb"

systemctl enable mongod 
VALIDATE "Enabling mongodb"

systemctl start mongod 
VALIDATE "Starting mongodb"

sed -i '/s/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE "Allowing remote connections to mongodb"

systemctl restart mongodb
VALIDATE "Restarting mongodb"


# for package in $@
# do
#     dnf list installed mysql
#     if [ $? -ne 0 ]; then
#         dnf install $package -y
#         VALIDATE $package
#     else
#         echo -e "$package is already exists..... $Y SKIPPING $N"
#     fi
# done
