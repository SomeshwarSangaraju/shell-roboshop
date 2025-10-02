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

dnf module disable nodejs -y
VALIDATE $? "Disabling nodejs" &>> $LOG_FILE

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling nodejs" &>> $LOG_FILE

dnf install nodejs -y
VALIDATE $? "Installing nodejs" &>> $LOG_FILE

id roboshop 
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop | tee -a $LOG_FILE
    VALIDATE $? "Creating System user"
else
    echo -e "System user is already exist....... $Y SKIPPING $N" &>> $LOG_FILE
fi

mkdir -p /app 
VALIDATE $? "creating directory" &>> $LOG_FILE

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip 
VALIDATE $? "Downloading cart code" &>> $LOG_FILE

cd /app 
VALIDATE $? "Changing directory" &>> $LOG_FILE

unzip /tmp/cart.zip
VALIDATE $? "Unziping cart" &>> $LOG_FILE

npm install 
VALIDATE $? "Installing dependencies" &>> $LOG_FILE

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Accessing services" &>> $LOG_FILE

systemctl daemon-reload
VALIDATE $? "Reloading cart" &>> $LOG_FILE

systemctl enable cart 
VALIDATE $? "Enabling cart" &>> $LOG_FILE

systemctl start cart
VALIDATE $? "Starting cart" &>> $LOG_FILE

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"