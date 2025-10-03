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

dnf list installed maven
if [ $? -ne 0 ]; then
    dnf install maven -y
    VALIDATE $? "Installing maven"
else
    echo "Maven already exist ..... $Y SKIPPING $N"
fi

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop | tee -a $LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "System user already exist .... $Y SKIPPING $N" &>> $LOG_FILE
fi

mkdir -p /app 
VALIDATE $? "Creating directory" &>> $LOG_FILE

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "Downloading Shipping code" &>> $LOG_FILE

cd /app 
VALIDATE $? "changing directory" &>> $LOG_FILE

unzip /tmp/shipping.zip
VALIDATE $? "Unziping shipping" &>> $LOG_FILE

mvn clean package 
VALIDATE $? "clean installing" &>> $LOG_FILE

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Moving shipping" &>> $LOG_FILE

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Accessing service" &>> $LOG_FILE

systemctl daemon-reload
VALIDATE $? "Reloading services" &>> $LOG_FILE

systemctl enable shipping
VALIDATE $? "Enabling shipping" &>> $LOG_FILE

systemctl start shipping
VALIDATE $? "Starting shipping" &>> $LOG_FILE

dnf install mysql -y 
VALIDATE $? "Installing Mysql" &>> $LOG_FILE

mysql -h $MONGODB_IP -uroot -pRoboShop@1 < /app/db/schema.sql
VALIDATE $? "Loading schemas"  | tee -a $LOG_FILE

mysql -h $MONGODB_IP -uroot -pRoboShop@1 < /app/db/app-user.sql 
VALIDATE $? "Creating App user" | tee -a $LOG_FILE

mysql -h $MONGODB_IP -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? "Loading Master data" | tee -a $LOG_FILE

systemctl restart shipping
VALIDATE $? "Restarting shipping" | tee -a $LOG_FILE

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"