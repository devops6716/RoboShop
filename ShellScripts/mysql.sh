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
dnf module disable mysql -y &>> $LOG_FILE
VALIDATE $? "mysql disable"
cp mysql.repo /etc/yum.repos.d/mysql.repo
VALIDATE $? "mysql repo configured"
dnf install mysql-community-server -y &>> $LOG_FILE
VALIDATE $? "mysql installation "
systemctl enable mysqld &>> $LOG_FILE
systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "started mysql"
mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE
VALIDATE $? "mysql password changed is "