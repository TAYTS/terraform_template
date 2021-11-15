output "vpc_id" {
  description = "ID of VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_default_rt_id" {
  description = "ID of Default Route Table"
  value       = aws_vpc.vpc.default_route_table_id
}

output "igw_id" {
  description = "ID of IGW"
  value       = aws_internet_gateway.igw.id
}

output "public_subnet_ids" {
  description = "IDs of public subnet"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnet"
  value       = aws_subnet.private_subnet[*].id
}
