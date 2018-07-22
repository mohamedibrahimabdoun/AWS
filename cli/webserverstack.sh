#!/bin/bash



echo "=======================================================================================================" >> Webservstack.log
echo "==================================Web servers stack Script Started=====================================" >> Webservstack.log
MYSTRING=available
aws rds  describe-db-instances  --db-instance-identifier mydbname > result.json
DBInstanceStatus=$(aws rds  describe-db-instances  --db-instance-identifier mydbname |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["DBInstances"][0]["DBInstanceStatus"];')



echo "checking if RDS is available"

if [ "$DBInstanceStatus" = "$MYSTRING" ]
then


AZ1=$(aws ec2 describe-availability-zones | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AvailabilityZones"][0]["ZoneName"];')
 AZ2=$(aws ec2 describe-availability-zones | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AvailabilityZones"][1]["ZoneName"];')
AZ3=$(aws ec2 describe-availability-zones | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AvailabilityZones"][0]["ZoneName"];')
 AZ4=$(aws ec2 describe-availability-zones | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AvailabilityZones"][1]["ZoneName"];')
 
MasterDBHostName=$(aws rds   describe-db-instances --db-instance-identifier mydbname |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["DBInstances"][0]["Endpoint"]["Address"];')
MasterJDBCConnectionString=$(aws rds   describe-db-instances --db-instance-identifier mydbname |python -c 'import json,sys;obj=json.load(sys.stdin);address=obj["DBInstances"][0]["Endpoint"]["Address"] ; port=obj["DBInstances"][0]["Endpoint"]["Port"] ;result= "jdbc:mysql://" +str(address)+ ":" +str(port); print result; ')

perl -pi -e "s/MasterDBHostNamevalue/$MasterDBHostName/g" candidate8userdata.txt

##Create Launch Configuration

echo " Query VPC"
aws ec2 describe-vpcs > result.json
VPCID=$(python readJson.py Vpcs  VpcId candidate8vpc)

echo 'VPC ID: ['"$VPCID"']' >> Webservstack.log

echo " Query security groups"
aws ec2 describe-security-groups > result.json
SGID=$(python readJson.py SecurityGroups  GroupId candidate8sgweb)

echo 'Security Group ID: ['"$SGID"']' >> Webservstack.log

echo " Query Public Subnets"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPCID" > result.json
Publicsubnet1=$(python readJson.py Subnets  SubnetId candidate8Publicsubnet1)
echo 'Publicsubnet1: ['"$Publicsubnet1"']' >> Webservstack.log
 
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPCID" > result.json
Publicsubnet2=$(python readJson.py Subnets  SubnetId candidate8Publicsubnet2)
echo 'Publicsubnet2: ['"$Publicsubnet2"']' >> Webservstack.log

echo "Adding DB Instance Host Name to User data File"




echo "Createing Launch Configuration"
aws autoscaling create-launch-configuration --launch-configuration-name candidate8launchconfig --key-name candidate8stack --image-id  ami-08842d60 --security-groups $SGID --instance-type t2.micro --user-data file://candidate8userdata.txt


aws autoscaling create-auto-scaling-group --auto-scaling-group-name candidate8ASG --launch-configuration-name candidate8launchconfig --min-size 2 --max-size 5 --desired-capacity 2 --load-balancer-names WebELB  --tags Key=StackName,Value=candidate8ASG --vpc-zone-identifier $Publicsubnet1,$Publicsubnet2 --availability-zones $AZ1 $AZ2

####################################Creating Cleanup Script##############################


aws autoscaling describe-auto-scaling-groups > result.json
AutoScalingGroupName=$(python readJson.py AutoScalingGroups  AutoScalingGroupName candidate8ASG)



echo "aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $AutoScalingGroupName" > stackcleanupwebserver.sh

echo "aws autoscaling delete-launch-configuration --launch-configuration-name candidate8launchconfig" >> stackcleanupwebserver.sh

else

echo ' Databse is in '["$DBInstanceStatus"'] Status please wait'

fi
