aws rds delete-db-instance --db-instance-identifier mydbname --skip-final-snapshot
aws rds  delete-db-subnet-group --db-subnet-group-name mydbsubnetgroup
aws ec2 delete-security-group --group-id sg-fa31be89
aws elb delete-load-balancer --load-balancer-name WebELB
aws ec2 delete-security-group  --group-id  sg-7ece400d
aws ec2 disassociate-route-table --association-id rtbassoc-ccd7fdb6
aws ec2 disassociate-route-table --association-id rtbassoc-c0d1fbba
aws ec2 delete-route-table --route-table-id rtb-cfedc0b4
aws ec2 disassociate-route-table --association-id rtbassoc-04ab817e
aws ec2 disassociate-route-table --association-id rtbassoc-5dd6fc27
aws ec2 delete-route-table --route-table-id rtb-fce9c487
aws ec2  detach-internet-gateway --internet-gateway-id igw-d620d6af --vpc-id vpc-42bda33b
aws ec2  delete-internet-gateway --internet-gateway-id igw-d620d6af
aws ec2 delete-subnet --subnet-id subnet-386fcf5c 
aws ec2 delete-subnet --subnet-id subnet-2d93a777 
aws ec2 delete-subnet --subnet-id subnet-8f98acd5  
aws ec2 delete-subnet --subnet-id subnet-406ece24  
aws ec2 delete-vpc --vpc-id vpc-42bda33b
