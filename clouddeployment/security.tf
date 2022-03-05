resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "TraderMachine"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_security_group" "ssh_securitygroup" {
  name        = "sshSecurityGroup"
  description = "sshSecurityGroup"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    "Name" = "sshSecurityGroup"
  }
}

resource "aws_security_group" "nat_securitygroup" {
  name        = "natSecurityGroup"
  description = "natSecurityGroup"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    cidr_blocks = var.private_subnets
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = var.private_subnets
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    "Name" = "natSecurityGroup"
  }
}

resource "aws_security_group" "securitygroup" {
  name        = "privateSecurityGroup"
  description = "privateSecurityGroup"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    cidr_blocks = var.private_subnets
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = var.private_subnets
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
  }
  ingress {
    cidr_blocks = var.private_subnets
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
  }
  ingress {
    cidr_blocks = [var.cidr]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = [var.cidr]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    "Name" = "privateSecurityGroup"
  }
}
