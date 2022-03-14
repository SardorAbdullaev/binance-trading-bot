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
  cidr_block = var.cidr
  tags       = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
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
  hibernation = false
  credit_specification {
    cpu_credits = "unlimited"
  }
}

#resource "aws_instance" "trend_trader" {
#  ami             = "ami-00bf0e20ed7ea8cdc"
#  instance_type   = "t2.micro"
#  subnet_id       = aws_subnet.private[0].id
#  security_groups = [aws_security_group.securitygroup.name]
#  key_name        = aws_key_pair.ssh.key_name
#  tags            = {
#    "Name" = var.app_name
#  }
#  hibernation = false
#  credit_specification {
#    cpu_credits = "unlimited"
#  }
#}

resource "aws_instance" "ec2jumphost" {
  instance_type           = "t2.nano"
  ami                     = "ami-00bf0e20ed7ea8cdc"
  subnet_id               = aws_subnet.public[0].id
  security_groups         = [aws_security_group.ssh_securitygroup.id]
  key_name                = aws_key_pair.ssh.key_name
  disable_api_termination = false
  hibernation             = false
  # Change ami before decreasing the volume
  #  root_block_device {
  #    volume_size = 1
  #  }
  tags                    = {
    "Name" = "${var.app_name}-jumphost"
  }
  credit_specification {
    cpu_credits = "standard"
  }
}
resource "aws_instance" "ec2nat" {
  instance_type               = "t2.nano"
  ami                         = "ami-003acd4f8da7e06f9"
  subnet_id                   = aws_subnet.public[0].id
  security_groups             = [aws_security_group.nat_securitygroup.id]
  associate_public_ip_address = true
  source_dest_check           = false
  tags                        = {
    "Name" = "${var.app_name}-nat-instance"
  }
  credit_specification {
    cpu_credits = "standard"
  }
}
