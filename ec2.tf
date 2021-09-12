#### Creating TLS Private Key ############

resource "tls_private_key" "mediawiki_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#### Creating new aws key pair for media wiki Application ##########


resource "aws_key_pair" "mediawiki_key_pair" {
  key_name   = "mediawiki-key"
  public_key = tls_private_key.mediawiki_key.public_key_openssh
}


### Security group to attach to the mediawiki ec2 instances ########

resource "aws_security_group" "mediawiki-ec2-sg" {
  name        = "mediawiki-ec2-sg"
  description = "Allows http https and ssh access"
  vpc_id      = aws_vpc.mediawiki.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")
  vars = {
    efs_id = data.aws_efs_mount_target.mediawiki.ip_address
  }
}

######## Creating Launch Confguration for media wiki ###########

resource "aws_launch_configuration" "mediawiki" {
  name             = "mediawiki-new"
  image_id         = data.aws_ami.amazon_linux.id
  instance_type    = "t2.medium"
  key_name         = aws_key_pair.mediawiki_key_pair.key_name
  security_groups  = [aws_security_group.mediawiki-ec2-sg.id]
  user_data_base64 = base64encode(data.template_file.user_data.rendered)
  root_block_device {
    encrypted   = true
    volume_type = "gp2"
    volume_size = "20"
  }
}



resource "aws_security_group" "mediawiki-alb-sg" {
  name        = "mediawiki-alb-sg"
  description = "Allows http https and ssh access"
  vpc_id      = aws_vpc.mediawiki.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########### Creating Application load Balancer for media wiki #######

resource "aws_lb" "mediawiki_alb" {
  name                       = "mediawiki-alb"
  subnets                    = aws_subnet.public-subnets.*.id
  security_groups            = [aws_security_group.mediawiki-alb-sg.id]
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  enable_http2               = true
  tags = {
    Name = "wiki-elb"
  }
}

########### Creating Media Wiki Traget group ###############

resource "aws_lb_target_group" "mediawiki_traget_group" {
  name     = "mediawiki-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mediawiki.id
}

##### ALB Listner for media wiki #####################

resource "aws_lb_listener" "mediawiki" {
  load_balancer_arn = aws_lb.mediawiki_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mediawiki_traget_group.arn
  }
}


#### Creating Media Wiki Auto scaling group and attaching instances to the target group ########
resource "aws_autoscaling_group" "mediawiki" {
  name                 = "mediawiki-autoscaling-group"
  launch_configuration = aws_launch_configuration.mediawiki.name
  max_size             = "5"
  min_size             = "1"
  desired_capacity     = "1"
  vpc_zone_identifier  = aws_subnet.public-subnets.*.id
  target_group_arns    = [aws_lb_target_group.mediawiki_traget_group.arn]
}


