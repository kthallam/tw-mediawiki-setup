####### Creating EFS for storing media wiki application ###########

resource "aws_efs_file_system" "mediawiki" {
  tags = {
    Name = "${var.PROJECT_NAME}-efs"
  }
  encrypted       = true
  throughput_mode = "bursting"
  depends_on = [
    aws_subnet.private-subnets,
  ]
}

resource "aws_security_group" "sg_mediawiki_efs" {
  name        = "mediawiki-efs-sg"
  description = "Allowing NFS Traffic to vpc"
  vpc_id      = aws_vpc.mediawiki.id
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    self        = true
    cidr_blocks = ["${var.VPC_CIDR}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### Creating mount points to mount via ip #########

resource "aws_efs_mount_target" "mount_targets" {
  count           = length(aws_subnet.private-subnets.*.id)
  file_system_id  = aws_efs_file_system.mediawiki.id
  subnet_id       = aws_subnet.private-subnets[count.index].id
  security_groups = [aws_security_group.sg_mediawiki_efs.id]
}