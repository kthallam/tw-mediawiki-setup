#!/bin/bash
terraform init
terraform destroy -auto-approve
terraform plan
terraform apply -auto-approve
aws s3 cp terraform.tfstate s3://$AWS_S3_BUCKET/
