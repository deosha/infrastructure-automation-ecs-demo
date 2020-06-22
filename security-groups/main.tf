provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "state-files-ecs-demo"
    key    = "prod/security-groups.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "state-files-ecs-demo"
    key    = "prod/network.tfstate"
    region = "ap-south-1"
  }
}

module "ssh_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "ecs-demo-ssh-prod-sg"
  description = "Security group for ssh access with ssh port open within VPC"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = [ "10.0.0.0/24", "10.104.1.0/24", "10.104.2.0/24", "10.104.3.0/24", "10.104.4.0/24", "10.104.5.0/24", "10.104.6.0/24","10.104.7.0/24", "10.104.8.0/24"]
}

module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "ecs-demo-bastion-prod-sg"
  description = "Security group for ssh access with ssh port open within VPC"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "public_alb_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "ecs-demopublic-alb-prod-sg"
  description = "Security group for public"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules            = ["https-443-tcp"]
}

module "internal_alb_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "ecs-demo-internal-alb-prod-sg"
  description = "Security group for internal alb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24","10.0.3.0/24","10.0.4.0/24","10.0.5.0/24"]
}


