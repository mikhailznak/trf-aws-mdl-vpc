variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

#####################################
# VPC
#####################################

variable "vpc_name" {
  description = "VPC Name."
  type        = string
  default     = "default"
}
variable "vpc_cidr_block" {
  description = "CIDR IP block"
  type        = string
  default     = ""
}
variable "vpc_enable_dns_support" {
  description = "Flag to enable/disable DNS support in the VPC. Defaults true"
  type        = bool
  default     = true
}
variable "vpc_enable_dns_hostnames" {
  description = "Flag to enable/disable DNS hostnames in the VPC. Defaults false"
  type        = bool
  default     = false
}

#####################################
# Default Routes
#####################################

variable "default_route_table_routes" {
  description = <<EOD
Configuration block of routes..
Usage example:
```
gateway_id = "self" - means that by default will be used IG created by this module
```
EOD
  type        = list(map(string))
  default     = []
}

#####################################
# NAT Gateway
#####################################

variable "nat_gateway" {
  description = "Enable NAT gateway. Default is true"
  type        = bool
  default     = true
}
variable "nat_gateway_ip" {
  description = "NAT gateway IP. Default is generated by module"
  type        = string
  default     = ""
}

#####################################
# SUBNET
#####################################

variable "subnet_availability_zone" {
  description = "Subnets AZ"
  type        = list(string)
  default     = []
}
variable "subnet_private_cidrs" {
  description = "Private subnets. Connecction to internet via NAT"
  type        = list(string)
  default     = []
}
variable "subnet_public_cidrs" {
  description = "Public subnets. Direct access to internet"
  type        = list(string)
  default     = []
}
variable "subnet_database_cidrs" {
  description = "Database subnets. Fully isolated network"
  type        = list(string)
  default     = []
}

#####################################
# Public Network ACL
#####################################

variable "public_inbound_acl_rules" {
  description = "Public subnets inbound network ACLs"
  type        = list(map(string))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
variable "public_outbound_acl_rules" {
  description = "Public subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

#####################################
# Private Network ACL
#####################################

variable "private_inbound_acl_rules" {
  description = "Private subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
variable "private_outbound_acl_rules" {
  description = "Private subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

#####################################
# Database Network ACL
#####################################

variable "database_inbound_acl_rules" {
  description = "Database subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "10.0.0.0/16"
    },
  ]
}
variable "database_outbound_acl_rules" {
  description = "Database subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}