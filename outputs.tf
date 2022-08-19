output "subnet_availability_zone" {
  value = var.subnet_availability_zone
}

##################################
# VPC
##################################
output "vpc_id" {
  value = aws_vpc.this.id
}
output "vpc_arn" {
  value = aws_vpc.this.arn
}
output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

##################################
# Internet Gateway
##################################
output "ig_id" {
  value = aws_internet_gateway.this.id
}
output "ig_arn" {
  value = aws_internet_gateway.this.arn
}

##################################
# Private Subnet
##################################
output "private_subnets" {
  value = [for k in aws_subnet.private : k.id]
}
output "private_subnets_cidr_blocks" {
  value = [for k in aws_subnet.private : k.cidr_block]
}
output "private_subnets_id_map" {
  value = zipmap(var.subnet_availability_zone, [for k in aws_subnet.private : k.id])
}

##################################
# Public Subnet
##################################
output "public_subnets" {
  value = [for k in aws_subnet.public : k.id]
}
output "public_subnets_cidr_blocks" {
  value = [for k in aws_subnet.public : k.cidr_block]
}
output "public_subnets_id_map" {
  value = zipmap(var.subnet_availability_zone, [for k in aws_subnet.public : k.id])
}

##################################
# Database Subnet
##################################
output "database_subnets" {
  value = [for k in aws_subnet.database : k.id]
}
output "database_subnets_cidr_blocks" {
  value = [for k in aws_subnet.database : k.cidr_block]
}
output "database_subnets_id_map" {
  value = zipmap(var.subnet_availability_zone, [for k in aws_subnet.database : k.id])
}

##################################
# Security Groups
##################################
output "public_sg_id" {
  value = aws_security_group.public.id
}
output "private_sg_id" {
  value = aws_security_group.private.id
}
output "database_sg_id" {
  value = aws_security_group.database.id
}
