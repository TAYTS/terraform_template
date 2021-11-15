terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "personal"
  region  = var.region
}

#######    VPC 1    #######
module "vpc1" {
  source = "./module/vpc"

  vpc_tag = "vpc1"

  vpc_cidr = "10.1.0.0/16"

  public_subnet = [
    { AZ : var.AZ1, cidr : "10.1.1.0/28" },
    { AZ : var.AZ2, cidr : "10.1.2.0/28" },
    { AZ : var.AZ3, cidr : "10.1.3.0/28" },
  ]

  private_subnet = [
    { AZ : var.AZ1, cidr : "10.1.4.0/28" },
    { AZ : var.AZ2, cidr : "10.1.5.0/28" },
    { AZ : var.AZ3, cidr : "10.1.6.0/28" },
  ]
}

#######    VPC 2    #######
module "vpc2" {
  source = "./module/vpc"

  vpc_tag = "vpc2"

  vpc_cidr = "10.2.0.0/16"

  public_subnet = [
    { AZ : var.AZ1, cidr : "10.2.1.0/28" },
    { AZ : var.AZ2, cidr : "10.2.2.0/28" },
    { AZ : var.AZ3, cidr : "10.2.3.0/28" },
  ]

  private_subnet = [
    { AZ : var.AZ1, cidr : "10.2.4.0/28" },
    { AZ : var.AZ2, cidr : "10.2.5.0/28" },
    { AZ : var.AZ3, cidr : "10.2.6.0/28" },
  ]
}

#######    VPC1 Security Group    #######
module "vpc1_sg" {
  source = "./module/security_group"

  sg_tag = "vpc1_sg"

  vpc_id = module.vpc1.vpc_id
}

#######    VPC2 Security Group    #######
module "vpc2_sg" {
  source = "./module/security_group"

  sg_tag = "vpc2_sg"

  vpc_id = module.vpc2.vpc_id
}

#######    VPC Peering    #######
resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_vpc_id = module.vpc2.vpc_id
  vpc_id      = module.vpc1.vpc_id
  auto_accept = true
}

#######    VPC1 Default RT    #######
resource "aws_default_route_table" "vpc1_default_rt" {
  default_route_table_id = module.vpc1.vpc_default_rt_id

  route {
    cidr_block                = "10.2.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }

  tags = {
    Name = "VPC1 Main RT"
  }
}

#######    VPC1 Public RT    #######
resource "aws_route_table" "vpc1_public_rt" {
  vpc_id = module.vpc1.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc1.igw_id
  }

  route {
    cidr_block                = "10.2.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }

  tags = {
    Name = "VPC1 Public RT"
  }
}

#######    VPC1 Public Subnet Association    #######
resource "aws_route_table_association" "vpc1_public_rt_subnet_ass" {
  count = length(module.vpc1.public_subnet_ids)

  subnet_id      = module.vpc1.public_subnet_ids[count.index]
  route_table_id = aws_route_table.vpc1_public_rt.id
}

#######    VPC2 Default RT    #######
resource "aws_default_route_table" "vpc2_default_rt" {
  default_route_table_id = module.vpc2.vpc_default_rt_id

  route {
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }

  tags = {
    Name = "VPC2 Main RT"
  }
}

#######    VPC2 Public RT    #######
resource "aws_route_table" "vpc2_public_rt" {
  vpc_id = module.vpc2.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc2.igw_id
  }

  route {
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }

  tags = {
    Name = "VPC2 Public RT"
  }
}

#######    VPC2 Public Subnet Association    #######
resource "aws_route_table_association" "vpc2_public_rt_subnet_ass" {
  count = length(module.vpc2.public_subnet_ids)

  subnet_id      = module.vpc2.public_subnet_ids[count.index]
  route_table_id = aws_route_table.vpc2_public_rt.id
}

#######    Key Pair    #######
resource "aws_key_pair" "key_pair" {
  key_name   = "key_pair"
  public_key = file(var.public_key_path)
}

#######    EC2 Instance 1    #######
resource "aws_instance" "vpc1_instance" {
  ami             = "ami-0c8e97a27be37adfd"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.key_pair.key_name
  subnet_id       = module.vpc1.public_subnet_ids[0]
  security_groups = [module.vpc1_sg.sg_id]

  tags = {
    Name = "VPC1 EC2 Instance"
  }
}

#######    EC2 Instance 2    #######
resource "aws_instance" "vpc2_instance" {
  ami             = "ami-0c8e97a27be37adfd"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.key_pair.key_name
  subnet_id       = module.vpc2.private_subnet_ids[0]
  security_groups = [module.vpc2_sg.sg_id]

  tags = {
    Name = "VPC2 EC2 Instance"
  }
}
