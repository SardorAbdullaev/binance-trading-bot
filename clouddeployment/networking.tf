resource "aws_eip" "jumphost" {
  instance = aws_instance.ec2jumphost.id
  vpc      = true
  tags     = {
    "Name" = "${var.app_name}-jumphost"
  }
}

resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    Name        = "${var.app_name}-igw"
    Environment = var.app_environment
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name        = "${var.app_name}-private-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    Name        = "${var.app_name}-routing-table-public"
    Environment = var.app_environment
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws-igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    instance_id = aws_instance.ec2nat.id
  }
  tags = {
    "Name" = "${var.app_name}-routing-table-private"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private[0].id
  route_table_id = aws_route_table.private.id
}
