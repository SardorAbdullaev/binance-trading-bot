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

resource "aws_security_group" "securitygroup" {
  name        = "privateSecurityGroup"
  description = "privateSecurityGroup"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    cidr_blocks = ["172.31.0.0/24"]
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["172.31.1.0/24"]
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["172.31.0.0/16"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["172.31.0.0/16"]
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
