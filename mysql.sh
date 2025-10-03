USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." f1 )
LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME.log
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
MONGODB_IP=mongodb.someshwar.fun

mkdir -p $LOG_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: please run the script with root previlage"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 is ..... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is ...... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf list installed mysql
if [ $? -ne 0 ]; then
    dnf install mysql-server -y
    VALIDATE $? "MYSQL"
else
    echo "MySQL is already exist ..... $Y SKIPPING $N"
fi

systemctl enable mysqld
VALIDATE $? "Enabling mysql"

systemctl start mysqld  
VALIDATE $? "Starting mysql"


mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Changing root password for mysql"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"

