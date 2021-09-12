data "aws_availability_zones" "available" {
  state = "available"
}

####### Dynamically finding the first mount target id ##########
data "aws_efs_mount_target" "mediawiki" {
  mount_target_id = aws_efs_mount_target.mount_targets[0].id
}


#### Dynamically finding the amazon linux 2 AMI ID #######
data "aws_ami" "amazon_linux" {
  most_recent = true
  #owners      = ["self"]
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  owners = ["amazon"]
}