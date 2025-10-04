# #!/bin/bash

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

# dnf module disable nodejs -y
# VALIDATE $? "Disabling nodejs" &>> $LOG_FILE

# dnf module enable nodejs:20 -y
# VALIDATE $? "Enabling nodejs" &>> $LOG_FILE

# dnf install nodejs -y
# VALIDATE $? "Installing nodejs" &>> $LOG_FILE

# id roboshop | tee -a $LOG_FILE
# if [ $? -ne 0 ]; then
#     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop | tee -a $LOG_FILE
#     VALIDATE $? "Creating System user"
# else
#     echo -e "System user is already exist....... $Y SKIPPING $N" &>> $LOG_FILE
# fi

# mkdir -p /app 
# VALIDATE $? "creating directory" &>> $LOG_FILE

# curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
# VALIDATE $? "Downloading catalogue code" &>> $LOG_FILE

# cd /app 
# VALIDATE $? "Changing directory" &>> $LOG_FILE

# unzip /tmp/catalogue.zip
# VALIDATE $? "Unziping catalogue" &>> $LOG_FILE

# npm install 
# VALIDATE $? "Installing dependencies" &>> $LOG_FILE

# cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
# VALIDATE $? "Accessing services" &>> $LOG_FILE

# systemctl daemon-reload
# VALIDATE $? "Reloading catalogue" &>> $LOG_FILE

# systemctl enable catalogue 
# VALIDATE $? "Enabling catalogue" &>> $LOG_FILE

# systemctl start catalogue
# VALIDATE $? "Starting catalogue" &>> $LOG_FILE

# cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
# VALIDATE $? "Accessing mongo repo" | tee -a $LOG_FILE

# dnf install mongodb-mongosh -y
# VALIDATE $? "Installing mongodb" &>> $LOG_FILE

# mongosh --host $MONGODB_IP </app/db/master-data.js
# VALIDATE $? "Loading Master data" | tee -a $LOG_FILE

# mongosh --host $MONGODB_IP
# VALIDATE $? "Checking connected to mongodb or not" | tee -a $LOG_FILE

# show dbs
# VALIDATE $? "showing dbs" | tee -a $LOG_FILE

# use catalogue
# VALIDATE $? "Selecting database" | tee -a $LOG_FILE

# show collections

# db.products.find()

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

##### NodeJS ####
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"
dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading catalogue application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Enable catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install MongoDB client"

INDEX=$(mongosh mongodb.daws86s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarted catalogue"



