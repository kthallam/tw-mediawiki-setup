# tw-mediawiki-setup

This Terraform code will create following resources in AWS account. 
1. VPC along with private and public subnets in 4 AZ's.
2. MariaDB RDS Instance Creation.
3. EFS to Store the Contents of Media Wiki Application.
4. Media wiki Launch Configuration along with Auto Scaling group.
5. Media Wiki Public Facing ALB


## Process to run the above code.

Amazon linux v2 machine has been used to setup it and following commands will work.

1. Install Docker and start the service 

```
# setenforce 0
# amazon-linux-extras install docker -y 
# systemctl enable docker 
# systemctl start docker 
```

2. Run the following container with the given command. 

```
docker run -e AWS_DEFAULT_REGION="us-east-1" -e AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID> -e AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> -e AWS_S3_BUCKET="<AWS S3 BUCKET TO UPLOAD STATE FILE > " tk185114/mediawiki:latest

```

Replace the values with actual values and then run. 
