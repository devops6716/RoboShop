#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"
MYSQL_IP=172.31.25.41
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
dnf install maven -y &>> $LOG_FILE
VALIDATE $? "maven installation is "
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
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOG_FILE
cd /app
unzip -o /tmp/shipping.zip &>> $LOG_FILE
VALIDATE $? "Unzipping shipping"
mvn clean package &>> $LOG_FILE
VALIDATE $? "installing dependencies"
mv target/shipping-1.0.jar shipping.jar
cp /home/centos/RoboShop/ShellScripts/shipping.service /etc/systemd/system/shipping.service 
VALIDATE $? "shipping service file congiguration"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? " daemon reload"

systemctl enable shipping &>> $LOG_FILE
VALIDATE $? "enable shpping"
systemctl start shipping &>> $LOG_FILE
VALIDATE $? "start shipping"
##cp /home/centos/RoboShop/ShellScripts/mysql.repo /etc/yum.repos.d/mysql.repo
##VALIDATE $? "mysql config is "
dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "mysql installation"

VALIDATE $? "mysql istarted"
mysql -h $MYSQL_IP -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOG_FILE
VALIDATE $? "mysql root password changed"

VALIDATE $? "restart shipping"