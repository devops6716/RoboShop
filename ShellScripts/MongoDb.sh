#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"
echo " Script start at $TIMESTAMP" &>>$LOG_FILE

## Validation function
VALIDATE()
{
    if [ $1 -ne 0]
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
    Exit 1
fi    
