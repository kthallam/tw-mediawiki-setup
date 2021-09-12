# tw-mediawiki-setup

This Terraform code will create following resources in AWS account. 
1. VPC along with private and public subnets in 4 AZ's.
2. MariaDB RDS Instance Creation.
3. EFS to Store the Contents of Media Wiki Application.
4. Media wiki Launch Configuration along with Auto Scaling group.
5. Media Wiki Public Facing ALB
