# USERID=$(id -u)

# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"

# LOG_FOLDER="/var/log/shell-roboshop"
# SCRIPT_NAME=$( echo $0 | cut -d "." f1 )
# LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME.log
# SCRIPT_DIR=$PWD
# START_TIME=$(date +%s)
# MONGODB_IP=mongodb.someshwar.fun

# mkdir -p $LOG_FOLDER
# echo "Script started executed at: $(date)" | tee -a $LOG_FILE

# if [ $USERID -ne 0 ]; then
#     echo "ERROR:: please run the script with root previlage"
#     exit 1
# fi

# VALIDATE(){
#     if [ $1 -ne 0 ]; then
#         echo -e "$2 is ..... $R FAILURE $N" | tee -a $LOG_FILE
#         exit 1
#     else
#         echo -e "$2 is ...... $G SUCCESS $N" | tee -a $LOG_FILE
#     fi
# }

# dnf module list nginx
# if [ $? -ne 0 ]; then
#     dnf module disable nginx -y
#     VALIDATE $? "Disabling default nginx version"
#     dnf module enable nginx:1.24 -y
#     VALIDATE $? "Enabling nginx version"
#     dnf install nginx -y
#     VALIDATE $? "Installing Nginx"
# else
#     echo -e "Nginx already exist ..... $Y SKIPPING $N"
# fi

# systemctl enable nginx 
# VALIDATE $? "Enabling nginx"

# systemctl start nginx 
# VALIDATE $? "Starting nginx"

# rm -rf /usr/share/nginx/html/* 
# VALIDATE $? "Removing previous code"

# curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
# VALIDATE $? "Downloading frontend code"

# cd /usr/share/nginx/html 
# VALIDATE $? "Changing directory"

# unzip /tmp/frontend.zip
# VALIDATE $? "Unziping frontend code"

# cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
# VALIDATE $? "Accessing nginx configurations"

# systemctl restart nginx
# VALIDATE $? "Restarting nginx"

# END_TIME=$(date +%s)
# TOTAL_TIME=$(( $END_TIME - $START_TIME ))
# echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"


#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daws86s.fun
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log

mkdir -p $LOG_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nginx -y &>>$LOG_FILE
dnf module enable nginx:1.24 -y &>>$LOG_FILE
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx  &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx 
VALIDATE $? "Restarting Nginx"