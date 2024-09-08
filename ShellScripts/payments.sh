#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"
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
dnf install python36 gcc python3-devel -y 
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
curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOG_FILE
VALIDATE $? "downloaded payments code"
cd /app 
unzip -o /tmp/payment.zip &>> $LOG_FILE
VALIDATE $? "unzipping payments"
pip3.6 install -r requirements.txt &>> $LOG_FILE
VALIDATE $? "Installing dependencies"
cp cp /home/centos/RoboShop/ShellScripts/payment.service /etc/systemd/system/payment.service
VALIDATE $? " paymentr service config"
systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? " daemon reload"

systemctl enable payment &>> $LOG_FILE
VALIDATE $? "enable payment"
systemctl start payment &>> $LOG_FILE
VALIDATE $? "start payment"