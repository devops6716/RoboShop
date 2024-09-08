#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"
MONGODB_IP=172.31.37.231
echo " Script start at $TIMESTAMP" &>> $LOG_FILE

## Validation function
VALIDATE()
{
    if [ $1 -ne 0 ]
    then
        echo -e " Error ..... $2 $R Failed $N"
        exit 1
    else
        echo -e "  $2 $G Success $N"  
    fi     
}

## Checks for root

if [ $ID -ne 0 ]
then
    echo -e " $R Error.... Login with root access $N"
    exit 1 
fi    
dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "disabled nodejs"

dnf module enable nodejs:18 -y &>> $LOG_FILE
VALIDATE $? "enabled nodejs"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "installing nodejs"

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOG_FILE
    VALIDATE $? "User creation"
else 
    echo -e "user already exist so $Y skipping $N "
fi       

mkdir -p /app
VALIDATE $? "app directory creation"
curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOG_FILE
VALIDATE $? "User download"
cd /app 
unzip -o /tmp/user.zip &>> $LOG_FILE
VALIDATE $? "Unzipping user"
npm install >> $LOG_FILE
VALIDATE $? "instaling dependencies"
cp /home/centos/RoboShop/ShellScripts/user.service /etc/systemd/system/user.service  
VALIDATE $? " user service config"
systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? " daemon reload"

systemctl enable user &>> $LOG_FILE
VALIDATE $? "enable user"
systemctl start user &>> $LOG_FILE
VALIDATE $? "start user"
cp /home/centos/RoboShop/ShellScripts/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "mongo db config"

dnf install mongodb-org-shell -y &>> $LOG_FILE
VALIDATE $? "mongo db client install"

mongo --host $MONGODB_IP </app/schema/user.js &>> $LOG_FILE
VALIDATE $? "Data loaded in mongodb"