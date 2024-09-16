#!/bin/bash

AMI=ami-0b4f379183e5706b9 # This keeps changing
SG_ID=sg-004ee40a4b913685e # Replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z05776752T3BSQOUDSHB4 # Replace with your Zone ID
DOMAIN_NAME="aws-devops.online"

for i in "${INSTANCES[@]}"
do
    if [[ $i == "mongodb" ]] || [[ $i == "mysql" ]] || [[ $i == "shipping" ]]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    echo " creating $i - instance"
    # Run the instance
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI" \
        --instance-type "$INSTANCE_TYPE" \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
        --query 'Instances[0].InstanceId' \
        --output text)
    
    # Wait until the instance is running
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

    # Get the private IP address of the instance
    IP_ADDRESS=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text)
    
    echo "$i: $IP_ADDRESS"

    # Create or update the Route 53 record
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$ZONE_ID" \
        --change-batch "{
            \"Comment\": \"Creating a record set for $i\",
            \"Changes\": [
                {
                    \"Action\": \"UPSERT\",
                    \"ResourceRecordSet\": {
                        \"Name\": \"$i.$DOMAIN_NAME\",
                        \"Type\": \"A\",
                        \"TTL\": 60,
                        \"ResourceRecords\": [
                            {\"Value\": \"$IP_ADDRESS\"}
                        ]
                    }
                }
            ]
        }"
done
