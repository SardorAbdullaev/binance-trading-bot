terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

resource "aws_vpc" "vpc" {
  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}

resource "aws_instance" "app_server" {
  ami                     = "ami-00bf0e20ed7ea8cdc"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.private[0].id
  security_groups         = [aws_security_group.securitygroup.id]
  key_name                = aws_key_pair.ssh.key_name
  disable_api_termination = false
  ebs_optimized           = false
  tags                    = {
    "Name" = var.app_name
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
}

resource "aws_instance" "app_node" {
  ami                     = "ami-00bf0e20ed7ea8cdc"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.private[0].id
  security_groups         = [aws_security_group.securitygroup.id]
  key_name                = aws_key_pair.ssh.key_name
  disable_api_termination = false
  ebs_optimized           = false
  tags                    = {
    "Name" = var.app_name
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
}

resource "aws_instance" "ec2jumphost" {
  instance_type           = "t2.micro"
  ami                     = "ami-00bf0e20ed7ea8cdc"
  subnet_id                 = aws_subnet.public[0].id
  security_groups         = [aws_security_group.securitygroup.id]
  key_name                = aws_key_pair.ssh.key_name
  disable_api_termination = false
  ebs_optimized           = false
  tags                    = {
    "Name" = "${var.app_name}-jumphost"
  }
}
