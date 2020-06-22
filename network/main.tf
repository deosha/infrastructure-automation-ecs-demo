provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "state-files-ecs-demo"
    key    = "prod/network.tfstate"
    region = "ap-south-1"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ecs-demo-prod"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  database_subnets  = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
  

  enable_nat_gateway = true
  single_nat_gateway = false
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  private_subnet_suffix = "app"
  public_subnet_suffix = "nat"


  create_database_nat_gateway_route = true
  create_database_internet_gateway_route = false
  create_database_subnet_group = false
  create_database_subnet_route_table = false
  database_subnet_suffix = "db"

  tags = {
    Terraform = "true"
    Environment = "prod"
  }
}
