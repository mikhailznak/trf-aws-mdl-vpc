module "example" {
  source         = "../../"
  vpc_cidr_block = "10.0.0.0/16"
  tags = {
    Managed = "Terraform"
    Env     = "Dev"
  }
  subnet_availability_zone = ["us-east-1a"]
  subnet_private_cidrs     = ["10.0.0.0/20"]
  subnet_public_cidrs      = ["10.0.32.0/20"]
  subnet_database_cidrs    = ["10.0.64.0/20"]
  default_route_table_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.example.ig_id
    }
  ]
}
