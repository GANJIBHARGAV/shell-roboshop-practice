#!/bin/bash 

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-061c4e443b6a8969b"
INSTANCES=("cart" "user" "mongodb" "mysql" "dispatch" "shipping" "frontend" "redis" "catalogue"
"rabbitmq" "payment")

ZONE_ID="Z010338424SHV40WHWYRG"
DOMAIN_ID="bhargavcommerce.shop"

for instance in ${INSTANCES[@]}
do
INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-061c4e443b6a8969b --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query "Instances[0].InstanceId" --output text)
if [ instance != "frontend" ]
then
IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
else
IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text) 
fi 
echo "$instance ip address is : $IP"

aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Testing creating a record set"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$instance'.'$DOMAIN_ID'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
      }
    }]
  }
  '
done
