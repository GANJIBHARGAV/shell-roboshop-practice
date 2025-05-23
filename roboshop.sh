#!/bin/bash 

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-061c4e443b6a8969b"
INSTANCES=("INSTANCES=("mysql" "mongodb" "cart "user" "redis" "catalogue" "rabbitmq" "payment"
 "shipping" "dispatch" "frontend")

ZONE_ID="Z010338424SHV40WHWYRG"
DOMAIN_ID="bhargavcommerce.shop"

for instance in ${INSTANCES[@]}
do
INSTANCE_ID=$(aws ec2 run-instances 
--image-id $AMI_ID 
--instance-type t2.micro 
--security-group-ids $SG_ID
--tag-specification "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" 
--query "Instances[0].InstanceId" 
--output text)
if [ instance -ne "frontend" ]
then
IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID
 --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
else
IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID
 --query 'Reservations[*].Instances[*].PublicIpAddress' --output text) 
fi 
echo "$instance IP address is $IP"
done