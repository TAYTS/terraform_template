#######    VPC    #######
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_tag
  }
}

#######    IGW    #######
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW"
  }
}

#######    Public Subnet    #######
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet[count.index].cidr
  availability_zone       = var.public_subnet[count.index].AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index}"
  }
}

#######    Private Subnet    #######
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet[count.index].cidr
  availability_zone       = var.private_subnet[count.index].AZ
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet ${count.index}"
  }
}
