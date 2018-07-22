#!/bin/bash



#Get Avaialbility Zones
newdate=`date +%d%m%Y`
echo "=======================================================================================================" >> networkscripts.log
echo "==================================Script Started=======================================================" >> networkscripts.log


AZ1=$(aws ec2 describe-availability-zones | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AvailabilityZones"][0]["ZoneName"];')
 AZ2=$(aws ec2 describe-availability-zones | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AvailabilityZones"][1]["ZoneName"];')
AZ3=$(aws ec2 describe-availability-zones | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AvailabilityZones"][0]["ZoneName"];')
 AZ4=$(aws ec2 describe-availability-zones | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AvailabilityZones"][1]["ZoneName"];')
 
echo "==================================VPC Information=======================================================" >> networkscripts.log
#Create VPC ,2 Public Subnets ,2 PrivateSubnets


echo "Creating VPC and Subnets"

VPCID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["Vpc"]["VpcId"];') &&
Publicsubnet1=$( aws ec2 create-subnet --vpc-id $VPCID --availability-zone $AZ1 --cidr-block 10.0.1.0/24 | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["Subnet"]["SubnetId"];') &&
Publicsubnet2=$( aws ec2 create-subnet --vpc-id $VPCID --availability-zone $AZ2 --cidr-block 10.0.2.0/24 |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["Subnet"]["SubnetId"];') &&
PrivateSubnet1=$( aws ec2 create-subnet --vpc-id $VPCID --availability-zone $AZ3 --cidr-block 10.0.3.0/24 | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["Subnet"]["SubnetId"];') &&
PrivateSubnet2=$( aws ec2 create-subnet --vpc-id $VPCID --availability-zone $AZ4 --cidr-block 10.0.4.0/24 |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["Subnet"]["SubnetId"];') 


echo "modifying Public Subnets to have public IP Address and vpc DNS hostnames"


 aws ec2 modify-subnet-attribute --subnet-id $Publicsubnet1 --map-public-ip-on-launch 
 aws ec2 modify-subnet-attribute --subnet-id $Publicsubnet2 --map-public-ip-on-launch 
 aws ec2 modify-vpc-attribute  --enable-dns-hostnames  --vpc-id $VPCID

 echo "Adding Tags to VPC and Subnets"
 
aws ec2 create-tags --resources $VPCID --tags Key=StackName,Value=candidate8vpc
aws ec2 create-tags --resources $Publicsubnet1 --tags Key=StackName,Value=candidate8Publicsubnet1
aws ec2 create-tags --resources $Publicsubnet2 --tags Key=StackName,Value=candidate8Publicsubnet2
aws ec2 create-tags --resources $PrivateSubnet1 --tags Key=StackName,Value=candidate8PrivateSubnet1
aws ec2 create-tags --resources $PrivateSubnet2 --tags Key=StackName,Value=candidate8PrivateSubnet2

echo 'VPC ID: ['"$VPCID"']' >> networkscripts.log
echo 'Publicsubnet1 ID: ['"$Publicsubnet1"']' >> networkscripts.log
echo 'Publicsubnet2 ID: ['"$Publicsubnet2"']' >> networkscripts.log
echo 'PrivateSubnet1 ID: ['"$PrivateSubnet1"']' >> networkscripts.log
echo 'PrivateSubnet2 ID: ['"$PrivateSubnet2"']' >> networkscripts.log


#Create InternetGateway and attach-internet-gateway to VPC
echo "Creating InternetGateway and Attach it To VPC"

InternetGatewayId=$(aws ec2 create-internet-gateway |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["InternetGateway"]["InternetGatewayId"];')&&
aws ec2 attach-internet-gateway --internet-gateway-id $InternetGatewayId --vpc-id $VPCID

#Create Route Table and netwrok association

echo "Creating Route Tables For Public and Private Subnets"


PublicRouteTable=$(aws ec2 create-route-table --vpc-id $VPCID |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["RouteTable"]["RouteTableId"];') &&
PublicRoute=$(aws ec2 create-route --route-table-id $PublicRouteTable --destination-cidr-block 0.0.0.0/0 --gateway-id $InternetGatewayId) &&

PublicSubnet1RouteTableAssociation=$(aws ec2 associate-route-table --route-table-id $PublicRouteTable --subnet-id $Publicsubnet1 |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AssociationId"];')

PublicSubnet2RouteTableAssociation=$(aws ec2 associate-route-table --route-table-id $PublicRouteTable --subnet-id $Publicsubnet2 |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AssociationId"];')

PrivateRouteTable=$(aws ec2 create-route-table --vpc-id $VPCID |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["RouteTable"]["RouteTableId"];') &&
PrivateSubnet1RouteTableAssociation=$(aws ec2 associate-route-table --route-table-id $PrivateRouteTable --subnet-id $PrivateSubnet1 |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AssociationId"];') &&
PrivateSubnet2RouteTableAssociation=$(aws ec2 associate-route-table --route-table-id $PrivateRouteTable --subnet-id $PrivateSubnet2 |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["AssociationId"];')

echo "==================================Routing Information===================================================" >> networkscripts.log
echo 'InternetGatewayId ID: ['"$InternetGatewayId"']' >> networkscripts.log
echo 'PublicRouteTable ID: ['"$PublicRouteTable"']' >> networkscripts.log
echo 'PublicSubnet1RouteTableAssociation ID: ['"$PublicSubnet1RouteTableAssociation"']' >> networkscripts.log
echo 'PublicSubnet2RouteTableAssociation ID: ['"$PublicSubnet2RouteTableAssociation"']' >> networkscripts.log
echo 'PrivateRouteTable ID: ['"$PrivateRouteTable"']' >> networkscripts.log
echo 'PrivateSubnet1RouteTableAssociation ID: ['"$PrivateSubnet1RouteTableAssociation"']' >> networkscripts.log
echo 'PrivateSubnet2RouteTableAssociation ID: ['"$PrivateSubnet2RouteTableAssociation"']' >> networkscripts.log

echo "==================================VPC Information Ended=======================================================" >> networkscripts.log
echo "==================================ELB Information STarted=======================================================" >> networkscripts.log

###########Creating Certificate#############

echo "Setting SSL Ceriticate ARN"


CertificateArn="arn:aws:iam::272462672480:server-certificate/candidate8certificate"
#####Create ELB Secuirty Group 
echo "Creating ELB Secuirty Group  for HTTP and HTTPS"


WebServerSecurityGroup=$(aws ec2 create-security-group --group-name WebServerSecurityGroup --description "Security Group for  ELB" --vpc-id $VPCID |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["GroupId"];') &&
HTTPSecurityGroupIngress=$(aws ec2 authorize-security-group-ingress --group-id $WebServerSecurityGroup --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 80, "ToPort": 80, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]') &&
HTTPsSecurityGroupIngress=$(aws ec2 authorize-security-group-ingress --group-id $WebServerSecurityGroup --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 443, "ToPort": 443, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]')
SSHSecurityGroupIngress=$(aws ec2 authorize-security-group-ingress --group-id $WebServerSecurityGroup --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]')

aws ec2 create-tags --resources $WebServerSecurityGroup --tags Key=StackName,Value=candidate8sgweb

#ELB
echo "Creating ELB and attaching Health Check"

ELBName=$(aws elb create-load-balancer --load-balancer-name WebELB --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" "Protocol=HTTPS,LoadBalancerPort=443,InstanceProtocol=HTTP,InstancePort=80,SSLCertificateId=$CertificateArn" --subnets  $Publicsubnet1 $Publicsubnet2  --security-groups $WebServerSecurityGroup --tags Key=StackName,Value=candidate8ELB |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["DNSName"];' ) &&
aws elb configure-health-check --load-balancer-name WebELB --health-check Target="HTTP:80/wordpress/wp-admin/install.php",Interval=10,UnhealthyThreshold=5,HealthyThreshold=2,Timeout=5

echo 'WebServerSecurityGroup ID: ['"$WebServerSecurityGroup"']' >> networkscripts.log
echo 'ELBName DNSName: ['"$ELBName"']' >> networkscripts.log
echo "==================================ELB Information Finished=======================================================" >> networkscripts.log
##########DATABASE CREATION####################
DBNAME=mydbname
DBUSERNAME=myawsuser
DBPASSWORD=myawsuserpwd

echo "==================================DATABASE Information Started=======================================================" >> networkscripts.log
echo "Creating DBEC2SecurityGroup ,db-subnet-group and MYSQLRDS"

DBEC2SecurityGroup=$(aws ec2 create-security-group --group-name DBEC2SecurityGroup --description "Security Group for  ELB" --vpc-id $VPCID |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["GroupId"];')
DBSecurityGroupIngress=$(aws ec2 authorize-security-group-ingress --group-id $DBEC2SecurityGroup --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 3306, "ToPort": 3306, "IpRanges": [{"CidrIp": "10.0.0.0/16"}]}]')

aws ec2 create-tags --resources $DBEC2SecurityGroup --tags Key=StackName,Value=candidate8sgdb

myDBSubnetGroup=$(aws rds create-db-subnet-group --db-subnet-group-name "mydbsubnetgroup" --db-subnet-group-description "mydbsubnetgroupDescription" --subnet-ids $PrivateSubnet1 $PrivateSubnet2 |python -c 'import json,sys;obj=json.load(sys.stdin);print obj["DBSubnetGroup"]["DBSubnetGroupName"];')


rds=$(aws rds create-db-instance --db-instance-identifier $DBNAME --allocated-storage 5 --db-instance-class db.t2.small  --engine mysql --master-username $DBUSERNAME --master-user-password $DBPASSWORD --engine-version "5.7.17"  --db-subnet-group-name $myDBSubnetGroup --vpc-security-group-ids $DBEC2SecurityGroup  --availability-zone $AZ3 --tags Key=StackName,Value=candidate8rds)

echo "setting Parameters"
cp userdatatempate.txt candidate8userdata.txt
perl -pi -e "s/DBNAMEvalue/$DBNAME/g" candidate8userdata.txt
perl -pi -e "s/DBUSERNAMEvalue/$DBUSERNAME/g" candidate8userdata.txt
perl -pi -e "s/DBPASSWORDvalue/$DBPASSWORD/g" candidate8userdata.txt



echo 'DBEC2SecurityGroup Id: ['"$DBEC2SecurityGroup"']' >> networkscripts.log
echo 'myDBSubnetGroup Name: ['"$myDBSubnetGroup"']' >> networkscripts.log
####################################Creating Cleanup Script##############################


echo "aws rds delete-db-instance --db-instance-identifier mydbname --skip-final-snapshot" > stackcleanupscript.sh
echo "aws rds  delete-db-subnet-group --db-subnet-group-name mydbsubnetgroup" >> stackcleanupscript.sh
echo "aws ec2 delete-security-group --group-id $DBEC2SecurityGroup" >> stackcleanupscript.sh
echo "aws elb delete-load-balancer --load-balancer-name WebELB" >> stackcleanupscript.sh
echo "aws ec2 delete-security-group  --group-id  $WebServerSecurityGroup" >> stackcleanupscript.sh
echo "aws ec2 disassociate-route-table --association-id $PublicSubnet1RouteTableAssociation" >> stackcleanupscript.sh
echo "aws ec2 disassociate-route-table --association-id $PublicSubnet2RouteTableAssociation" >> stackcleanupscript.sh
echo "aws ec2 delete-route-table --route-table-id $PublicRouteTable" >> stackcleanupscript.sh
echo "aws ec2 disassociate-route-table --association-id $PrivateSubnet1RouteTableAssociation" >> stackcleanupscript.sh
echo "aws ec2 disassociate-route-table --association-id $PrivateSubnet2RouteTableAssociation" >> stackcleanupscript.sh
echo "aws ec2 delete-route-table --route-table-id $PrivateRouteTable" >> stackcleanupscript.sh
echo "aws ec2  detach-internet-gateway --internet-gateway-id $InternetGatewayId --vpc-id $VPCID" >> stackcleanupscript.sh
echo "aws ec2  delete-internet-gateway --internet-gateway-id $InternetGatewayId" >> stackcleanupscript.sh
echo "aws ec2 delete-subnet --subnet-id $PrivateSubnet2 " >> stackcleanupscript.sh
echo "aws ec2 delete-subnet --subnet-id $PrivateSubnet1 " >> stackcleanupscript.sh
echo "aws ec2 delete-subnet --subnet-id $Publicsubnet1  " >> stackcleanupscript.sh
echo "aws ec2 delete-subnet --subnet-id $Publicsubnet2  " >> stackcleanupscript.sh
echo "aws ec2 delete-vpc --vpc-id $VPCID" >> stackcleanupscript.sh


