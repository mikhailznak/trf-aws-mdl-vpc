locals {
  public_subnets_list_id   = [for k, v in aws_subnet.public : v.id]
  private_subnets_list_id  = [for k, v in aws_subnet.private : v.id]
  database_subnets_list_id = [for k, v in aws_subnet.database : v.id]
}

##################################
# VPC
##################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = var.vpc_enable_dns_support
  enable_dns_hostnames = var.vpc_enable_dns_hostnames

  tags = merge(
    {
      "Name" : var.vpc_name
    },
    var.tags
  )
}

##################################
# Internet Gateway
##################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = var.tags
}

##################################
# NAT Gateway
##################################

resource "aws_eip" "nat" {
  count = var.nat_gateway && length(var.subnet_private_cidrs) > 0 && length(var.subnet_public_cidrs) > 0 ? 1 : 0
  tags = merge(
    {
      "Name": "${var.vpc_name}-ip-nat"
      "Attached" : "Nat Gateway"
    },
    var.tags
  )
}
resource "aws_nat_gateway" "this" {
  count         = var.nat_gateway && length(var.subnet_private_cidrs) > 0 && length(var.subnet_public_cidrs) > 0 ? 1 : 0
  allocation_id = var.nat_gateway_ip == "" ? aws_eip.nat[0].id : var.nat_gateway_ip
  subnet_id     = aws_subnet.public[var.subnet_availability_zone[0]].id

  tags = merge(
    {
      Name = "${var.vpc_name}-nat-${var.subnet_availability_zone[0]}"
    }
  )
}

##################################
# Subnets
##################################

resource "aws_subnet" "private" {
  for_each          = zipmap(var.subnet_availability_zone, var.subnet_private_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    {
      Name = "${var.vpc_name}-subnet-private-${each.key}"
    },
    var.tags
  )
}
resource "aws_subnet" "public" {
  for_each          = zipmap(var.subnet_availability_zone, var.subnet_public_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    {
      Name = "${var.vpc_name}-subnet-public-${each.key}"
    },
    var.tags
  )
}
resource "aws_subnet" "database" {
  for_each          = zipmap(var.subnet_availability_zone, var.subnet_database_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    {
      Name = "${var.vpc_name}-subnet-database-${each.key}"
    },
    var.tags
  )
}

################################################################################
# Default routes
################################################################################

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  dynamic "route" {
    for_each = var.default_route_table_routes
    content {
      cidr_block                = route.value.cidr_block
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
  }

  tags = merge(
    {
      Name = "${var.vpc_name}-route-table-default"
    },
    var.tags
  )
}

################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public" {
  count  = length(var.subnet_public_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.vpc_name}-route-table-public"
    },
    var.tags
  )
}
resource "aws_route" "public_internet_gateway" {
  count = length(var.subnet_public_cidrs) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}
resource "aws_route_table_association" "public" {
  count = length(var.subnet_public_cidrs) > 0 ? length(var.subnet_availability_zone) : 0

  subnet_id      = aws_subnet.public[var.subnet_availability_zone[count.index]].id
  route_table_id = aws_route_table.public[0].id
}

################################################################################
# Private routes
################################################################################

resource "aws_route_table" "private" {
  count  = length(var.subnet_private_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.vpc_name}-route-table-private"
    },
    var.tags
  )
}
resource "aws_route" "private_nat_gateway" {
  count = var.nat_gateway && length(var.subnet_public_cidrs) > 0 ? length(var.subnet_availability_zone) : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}
resource "aws_route_table_association" "private" {
  count = length(var.subnet_private_cidrs) > 0 ? length(var.subnet_availability_zone) : 0

  subnet_id      = aws_subnet.private[var.subnet_availability_zone[count.index]].id
  route_table_id = aws_route_table.private[0].id
}

################################################################################
# Database routes
################################################################################

resource "aws_route_table" "database" {
  count  = length(var.subnet_database_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.vpc_name}-route-table-database"
    },
    var.tags
  )
}
resource "aws_route_table_association" "database" {
  count = length(var.subnet_database_cidrs) > 0 ? length(var.subnet_availability_zone) : 0

  subnet_id      = aws_subnet.database[var.subnet_availability_zone[count.index]].id
  route_table_id = aws_route_table.database[0].id
}

################################################################################
# Public Network ACLs
################################################################################

resource "aws_network_acl" "public" {
  count = length(var.subnet_public_cidrs) > 0 ? 1 : 0

  vpc_id     = aws_vpc.this.id
  subnet_ids = local.public_subnets_list_id

  tags = merge(
    {
      Name = "${var.vpc_name}-nacl-public"
    },
    var.tags
  )
}
resource "aws_network_acl_rule" "public_inbound" {
  count = length(var.subnet_public_cidrs) > 0 ? length(var.public_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress      = false
  rule_number = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
}
resource "aws_network_acl_rule" "public_outbound" {
  count = length(var.subnet_public_cidrs) > 0 ? length(var.public_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress      = true
  rule_number = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.public_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
}

################################################################################
# Private Network ACLs
################################################################################

resource "aws_network_acl" "private" {
  count = length(var.subnet_private_cidrs) > 0 ? 1 : 0

  vpc_id     = aws_vpc.this.id
  subnet_ids = local.private_subnets_list_id

  tags = merge(
    {
      Name = "${var.vpc_name}-nacl-private"
    },
    var.tags
  )
}
resource "aws_network_acl_rule" "private_inbound" {
  count = length(var.subnet_private_cidrs) > 0 ? length(var.private_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress      = false
  rule_number = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.private_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.private_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
}
resource "aws_network_acl_rule" "private_outbound" {
  count = length(var.subnet_private_cidrs) > 0 ? length(var.private_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress      = true
  rule_number = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.private_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.private_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
}

################################################################################
# Database Network ACLs
################################################################################

resource "aws_network_acl" "database" {
  count = length(var.subnet_database_cidrs) > 0 ? 1 : 0

  vpc_id     = aws_vpc.this.id
  subnet_ids = local.database_subnets_list_id

  tags = merge(
    {
      Name = "${var.vpc_name}-nacl-database"
    },
    var.tags
  )
}
resource "aws_network_acl_rule" "database_inbound" {
  count = length(var.subnet_database_cidrs) > 0 ? length(var.database_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.database[0].id

  egress      = false
  rule_number = var.database_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.database_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.database_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.database_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.database_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.database_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.database_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.database_inbound_acl_rules[count.index], "cidr_block", null)
}
resource "aws_network_acl_rule" "database_outbound" {
  count = length(var.subnet_database_cidrs) > 0 ? length(var.database_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.database[0].id

  egress      = true
  rule_number = var.database_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.database_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.database_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.database_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.database_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.database_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.database_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.database_outbound_acl_rules[count.index], "cidr_block", null)
}
