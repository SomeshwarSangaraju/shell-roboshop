#!/bin/bash

USERID=$(id -u)
echo " $USERID "

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#root user is created at starting so root id is 0
if [ $USERID -ne 0 ]; then
    echo "Please run the script with root previlages"
    exit 1
fi

#checking the package is success or failure
VALIDATE(){
    if [ $? -ne 0 ]; then
        echo "ERROR:: Installing is ...... $R FAILURE $N"
        exit 1
    else
        echo "SUCCESS:: Installing is ........ $G SUCCESS $N"
    fi
}
    

for package in $@
do
    dnf list installed mysql
    if [ $? - ne 0 ]; then
        dnf install $package -y
        VALIDATE $package
    else
        echo "$package is already exists..... $Y SKIPPING $N"
    fi
done
