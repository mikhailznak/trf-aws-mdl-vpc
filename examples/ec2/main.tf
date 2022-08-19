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

resource "aws_instance" "public_1" {
  ami                         = "ami-052efd3df9dad4825"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  associate_public_ip_address = true
  subnet_id                   = module.example.public_subnets_id_map["us-east-1a"]
  vpc_security_group_ids      = [module.example.public_sg_id]
  key_name                    = "us-east-1-dev"
}

resource "aws_instance" "private_1" {
  ami                         = "ami-052efd3df9dad4825"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  associate_public_ip_address = false
  subnet_id                   = module.example.private_subnets_id_map["us-east-1a"]
  vpc_security_group_ids      = [module.example.private_sg_id]
  key_name                    = "us-east-1-dev"
}

resource "aws_instance" "database_1" {
  ami                         = "ami-052efd3df9dad4825"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  associate_public_ip_address = false
  subnet_id                   = module.example.database_subnets_id_map["us-east-1a"]
  vpc_security_group_ids      = [module.example.database_sg_id]
  key_name                    = "us-east-1-dev"
}

resource "aws_instance" "database_2" {
  ami                         = "ami-052efd3df9dad4825"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  associate_public_ip_address = false
  subnet_id                   = module.example.database_subnets_id_map["us-east-1a"]
  vpc_security_group_ids      = [module.example.database_sg_id]
  key_name                    = "us-east-1-dev"
}