terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- VPC 1: Management & App VPC (28.0.0.0/16) ---
resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc1_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "VPC-1-Management-App" }
}

resource "aws_internet_gateway" "igw_vpc1" {
  vpc_id = aws_vpc.vpc1.id
  tags   = { Name = "VPC1-InternetGateway" }
}

# Subnet 1: Public Bastion (28.0.1.0/24)
resource "aws_subnet" "subnet1_public" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.subnet1_public_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags                    = { Name = "VPC1-Subnet1-Public-Bastion" }
}

# Subnet 2: Private Internal App (28.0.2.0/24)
resource "aws_subnet" "subnet2_private" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.subnet2_private_cidr
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "VPC1-Subnet2-Private-App" }
}

# --- VPC 2: Isolated Target VPC (28.200.0.0/16) ---
resource "aws_vpc" "vpc2" {
  cidr_block           = var.vpc2_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "VPC-2-Isolated-Target" }
}

# Subnet 3: Private Target Workload (28.200.0.0/16)
resource "aws_subnet" "subnet3_target" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = var.subnet3_target_cidr
  availability_zone = "${var.aws_region}b"
  tags              = { Name = "VPC2-Subnet3-Private-Target" }
}

# --- VPC Peering Connection ---
resource "aws_vpc_peering_connection" "peering" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true
  tags        = { Name = "Peering-VPC1-to-VPC2" }
}

# --- Route Tables & Rules ---
resource "aws_route_table" "rt_vpc1_public" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc1.id
  }

  route {
    cidr_block                = var.vpc2_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags = { Name = "VPC1-Public-RouteTable" }
}

resource "aws_route_table_association" "rta_subnet1" {
  subnet_id      = aws_subnet.subnet1_public.id
  route_table_id = aws_route_table.rt_vpc1_public.id
}

resource "aws_route_table" "rt_vpc1_private" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block                = var.vpc2_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags = { Name = "VPC1-Private-RouteTable" }
}

resource "aws_route_table_association" "rta_subnet2" {
  subnet_id      = aws_subnet.subnet2_private.id
  route_table_id = aws_route_table.rt_vpc1_private.id
}

resource "aws_route_table" "rt_vpc2_private" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block                = var.vpc1_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags = { Name = "VPC2-Target-RouteTable" }
}

resource "aws_route_table_association" "rta_subnet3" {
  subnet_id      = aws_subnet.subnet3_target.id
  route_table_id = aws_route_table.rt_vpc2_private.id
}

# --- Security Groups ---
resource "aws_security_group" "sg_bastion" {
  name        = "sg-bastion-public"
  description = "Allows SSH ingress from admin"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_app" {
  name        = "sg-app-private"
  description = "Allows SSH ingress strictly from Bastion Jump Host"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_target" {
  name        = "sg-target-isolated"
  description = "Allows SSH and ICMP ping from VPC 1 CIDR across Peering"
  vpc_id      = aws_vpc.vpc2.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc1_cidr]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc1_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- EC2 Compute Instances ---
resource "aws_instance" "ec2_bastion" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet1_public.id
  vpc_security_group_ids = [aws_security_group.sg_bastion.id]
  key_name               = var.key_name
  tags                   = { Name = "EC2-1-Bastion-Host" }
}

resource "aws_instance" "ec2_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet2_private.id
  vpc_security_group_ids = [aws_security_group.sg_app.id]
  key_name               = var.key_name
  tags                   = { Name = "EC2-2-Internal-App" }
}

resource "aws_instance" "ec2_target" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet3_target.id
  vpc_security_group_ids = [aws_security_group.sg_target.id]
  key_name               = var.key_name
  tags                   = { Name = "EC2-3-Target-Workload" }
}
