provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "state-files-ecs-demo"
    key    = "prod/ext-alb.tfstate"
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

data "terraform_remote_state" "security_groups" {
  backend = "s3"
  config = {
    bucket = "state-files-ecs-demo"
    key    = "prod/security-groups.tfstate"
    region = "ap-south-1"
  }
}

resource "aws_alb_target_group" "this" {
  name                 = "ecs-demo-ext-tg-prod"
  protocol             = "HTTP"
  port                 = 8080
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
  deregistration_delay = "20"

  health_check {
    path     = "/health-check"
    protocol = "HTTP"
  }

  tags = {
    Name = "ecs-demo-tg-prod"
    Environment = "prod"
    Created_By = "Terraform"
  }
  depends_on = ["aws_alb.this"]
}

resource "aws_alb" "this" {
  name            = "ecs-demo-ext-prod"
  subnets         = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups = [data.terraform_remote_state.security_groups.outputs.public_alb_security_group_id]
  idle_timeout    = "300"
  internal        = false

  enable_deletion_protection = true


  tags = {
    Name        = "ecs-demo-external-prod"
    Environment = "prod"
    Created_By = "Terraform"
  }
}

resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:ap-south-1:xxxxxxxxxx:certificate/xxxxxxxxxxxxxxxxxx"

  default_action {
    target_group_arn = aws_alb_target_group.this.id
    type = "forward"
  }
}




 


