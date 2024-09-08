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
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOG_FILE
VALIDATE $? "Redis download"
dnf module enable redis:remi-6.2 -y &>> $LOG_FILE
VALIDATE $? "Redis 6.2 enable"
dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Redis installation"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOG_FILE
VALIDATE $? "Remote access"
systemctl enable redis
systemctl start redis
VALIDATE $? "Redis started"