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

# dnf list installed mysql
# if [ $? -ne 0 ]; then
#     dnf install mysql-server -y
#     VALIDATE $? "MYSQL"
# else
#     echo "MySQL is already exist ..... $Y SKIPPING $N"
# fi

# systemctl enable mysqld
# VALIDATE $? "Enabling mysql"

# systemctl start mysqld  
# VALIDATE $? "Starting mysql"


# mysql_secure_installation --set-root-pass RoboShop@1
# VALIDATE $? "Changing root password for mysql"

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
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
START_TIME=$(date +%s)
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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Server"
systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MySQL Server"
systemctl start mysqld   &>>$LOG_FILE
VALIDATE $? "Starting MySQL Server"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Setting up Root password"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
