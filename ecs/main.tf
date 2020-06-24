provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "state-files-ecs-demo"
    key    = "prod/ecs.tfstate"
    region = "ap-south-1"
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  name   = "ecs-demo-prod"
}

module "ec2-profile" {
  source = "terraform-aws-modules/ecs/aws//modules/ecs-instance-profile"
  name   = "ecs-demo-prod"
}
