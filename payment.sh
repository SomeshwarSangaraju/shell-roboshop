USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." f1 )
LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME.log
SCRIPT_DIR=$PWD
MONGODB_IP=mongodb.someshwar.fun

mkdir -p LOG_FOLDER
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

dnf install python3 gcc python3-devel -y

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop | tee -a $LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "System user already exist .... $Y SKIPPING $N" &>> $LOG_FILE
fi

mkdir -p /app 
VALIDATE $? "Creating directory" &>> $LOG_FILE

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "Downloading payment code" &>> $LOG_FILE

cd /app 
VALIDATE $? "changing directory" &>> $LOG_FILE

unzip /tmp/payment.zip
VALIDATE $? "Unziping payment" &>> $LOG_FILE

pip3 install -r requirements.txt
VALIDATE $? "Installing pip requirements" &>> $LOG_FILE

systemctl daemon-reload
VALIDATE $? "Reloading services" &>> $LOG_FILE

systemctl enable payment
VALIDATE $? "Enabling payment" &>> $LOG_FILE

systemctl start payment
VALIDATE $? "Starting payment" &>> $LOG_FILE

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"