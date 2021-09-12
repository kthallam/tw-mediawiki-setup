## Subnet Group using Private Subnets
resource "aws_db_subnet_group" "mediakwinki_mariadb" {
  name       = "mariadb"
  subnet_ids = aws_subnet.private-subnets.*.id

  tags = {
    Name = "${var.PROJECT_NAME}-RDS-SubnetGroup"
  }
}


## Create Security Group for MariaDB access , Only inside VPC

resource "aws_security_group" "mediawiki-rds-sg" {
  name        = "allow-mariadb-internal"
  description = "Allow MariaDB Access Internal"
  vpc_id      = aws_vpc.mediawiki.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["${var.VPC_CIDR}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### Creating Random Password for database ###########
resource "random_password" "mediawiki_password" {
  length           = 16
  special          = true
  upper            = true
  override_special = "_$="
}

######### Creating Maria db ################

resource "aws_db_instance" "mariadb-rds" {
  identifier             = "mediawiki-rds"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mariadb"
  engine_version         = "10.4"
  instance_class         = "db.t2.micro"
  name                   = "wiki"
  username               = "wiki"
  password               = random_password.mediawiki_password.result
  db_subnet_group_name   = aws_db_subnet_group.mediakwinki_mariadb.id
  vpc_security_group_ids = [aws_security_group.mediawiki-rds-sg.id]
  skip_final_snapshot    = true
  tags = {
    Name = "${var.PROJECT_NAME}-rds"
  }
}