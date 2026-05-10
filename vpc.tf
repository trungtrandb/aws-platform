provider "aws" {
  region = var.aws_region
}

locals {
  project = "main"

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]
}

# -------------------
# VPC
# -------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project}-vpc"
  }
}

# -------------------
# Internet Gateway
# -------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.project}-igw"
  }
}

# -------------------
# Public Subnets
# -------------------

resource "aws_subnet" "public" {
  count = 3

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project}-public-subnet-${count.index + 1}"
  }
}

# -------------------
# Private Subnets
# -------------------

resource "aws_subnet" "private" {
  count = 3

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 101}.0/24"
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${local.project}-private-subnet-${count.index + 1}"
  }
}

# -------------------
# Public Route Table
# -------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.project}-public-rt"
  }
}

# -------------------
# Public Route Table Associations
# -------------------

resource "aws_route_table_association" "public" {
  count = 3

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2" {
  name        = "${local.project}-ec2-sg"
  description = "Security group for K3s control-plane nodes"
  vpc_id      = aws_vpc.main.id

  ingress { // SSH port
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress { // Kubernetes API via NLB
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    cidr_blocks = [
      var.admin_cidr,
      aws_vpc.main.cidr_block
    ]
  }

  ingress { // HTTP for workloads (optional)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { // HTTPS for workloads (optional)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { // PostgreSQL external access (restricted to admin CIDR)
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress { // Kafka NodePort backend for NLB listener 9094
    from_port   = 30094
    to_port     = 30094
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { // Kafka NodePort backend for NLB listener 9095
    from_port   = 30095
    to_port     = 30095
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { // Kafka NodePort backend for NLB listener 9096
    from_port   = 30096
    to_port     = 30096
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow full east-west traffic between control-plane nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow access to Kafka UI"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { // Allow all outbound traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
