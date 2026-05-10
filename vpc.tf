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

