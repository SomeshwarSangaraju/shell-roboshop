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

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE "Allowing remote connections to mongodb"

systemctl restart mongodb
VALIDATE "Restarting mongodb"


# #!/bin/bash

# USERID=$(id -u)
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"

# LOGS_FOLDER="/var/log/shell-roboshop"
# SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
# LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log

# mkdir -p $LOGS_FOLDER
# echo "Script started executed at: $(date)" | tee -a $LOG_FILE

# if [ $USERID -ne 0 ]; then
#     echo "ERROR:: Please run this script with root privelege"
#     exit 1 # failure is other than 0
# fi

# VALIDATE(){ # functions receive inputs through args just like shell script args
#     if [ $1 -ne 0 ]; then
#         echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
#         exit 1
#     else
#         echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
#     fi
# }

# cp mongo.repo /etc/yum.repos.d/mongo.repo
# VALIDATE $? "Adding Mongo repo"

# dnf install mongodb-org -y &>>$LOG_FILE
# VALIDATE $? "Installing MongoDB"

# systemctl enable mongod &>>$LOG_FILE
# VALIDATE $? "Enable MongoDB"

# systemctl start mongod 
# VALIDATE $? "Start MongoDB"

# sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
# VALIDATE $? "Allowing remote connections to MongoDB"

# systemctl restart mongod
# VALIDATE $? "Restarted MongoDB"