#!/bin/bash

AMI="ami-0b4f379183e5706b9"
SG_ID="sg-004ee40a4b913685e"
INSTANCES=("mongodb" "mysql" "redis" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
DOMAIN_NAME="aws-devops.online"

for i in "${INSTANCES[@]}"
do 
    echo " Instance is:  $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ] 
    then 
        INSTANCE_TYPE="t3.small"
    else    
        INSTANCE_TYPE="t2.micro"
    fi
    aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"  
done 
           #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done