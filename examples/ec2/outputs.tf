output "vpc_id" {
  value = module.example.vpc_id
}
output "vpc_arn" {
  value = module.example.vpc_arn
}

##################################
# Private Subnet
##################################
output "private_subnets" {
  value = module.example.private_subnets
}
output "private_subnets_cidr_blocks" {
  value = module.example.private_subnets_cidr_blocks
}
output "private_subnets_map" {
  value = module.example.private_subnets_id_map
}

##################################
# Public Subnet
##################################
output "public_subnets" {
  value = module.example.public_subnets
}
output "public_subnets_cidr_blocks" {
  value = module.example.public_subnets_cidr_blocks
}
output "public_subnets_map" {
  value = module.example.public_subnets_id_map
}

##################################
# Database Subnet
##################################
output "database_subnets" {
  value = module.example.database_subnets
}
output "database_subnets_cidr_blocks" {
  value = module.example.database_subnets_cidr_blocks
}
output "database_subnets_map" {
  value = module.example.database_subnets_id_map
}
