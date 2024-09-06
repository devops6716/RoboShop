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

yum list installed | grep -q "mongo"

if [ $? -eq 0 ]
then

    ## CAll the mongo.repo file

    cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE 
    VALIDATE $? "Copied repo file"

    dnf install mongodb-org -y &>>$LOG_FILE
    VALIDATE $? " installing mongodb"

    systemctl enable mongod &>>$LOG_FILE
    VALIDATE $? " enabling mongodb"

    systemctl start mongod &>>$LOG_FILE
    VALIDATE $? "mongodb start"

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_FILE
    VALIDATE $? "Update remote to all"

    systemctl restart mongod &>> $LOG_FILE
    VALIDATE $? "mongodb restrt"
else
    echo " already installed"     