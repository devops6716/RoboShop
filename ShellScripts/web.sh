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

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "nginx installation"
systemctl enable nginx &>> $LOG_FILE
systemctl start nginx  &>> $LOG_FILE
VALIDATE $? "nginx started"
rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removed index.html"
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOG_FILE
VALIDATE $? "Downloaded web code"
cd /usr/share/nginx/html
unzip -o /tmp/web.zip &>> $LOG_FILE
VALIDATE $? "unzipping web is "
cp /home/centos/RoboShop/ShellScripts/roboshop.conf /etc/nginx/default.d/roboshop.conf 
VALIDATE $? "nginx config is "
systemctl restart nginx &>> $LOG_FILE
VALIDATE $? "restart nginx is"
