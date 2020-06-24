provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "state-files-ecs-demo"
    key    = "prod/int-alb.tfstate"
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

resource "aws_alb_target_group" "ecs-demo-internal" {
  name                 = "ecs-demo-internal-tg-prod"
  protocol             = "HTTP"
  port                 = 80
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
  deregistration_delay = "20"

  health_check {
    path     = "/api/v2/health-check"
    protocol = "HTTP"
  }

  tags = {
    Name = "ecs-demo-alb-internal-tg-prod"
    Environment = "prod"
    Created_By = "Terraform"
  }
  depends_on = ["aws_alb.ecs-demo-internal"]
}

resource "aws_alb" "ecs-demo-internal" {
  name            = "ecs-demo-internal-prod"
  subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
  security_groups = [data.terraform_remote_state.security_groups.outputs.internal_alb_security_group_id]
  idle_timeout    = "300"
  internal        = true

  enable_deletion_protection = true


  tags = {
    Name        = "ecs-demo-internal-prod"
    Environment = "prod"
    Created_By = "Terraform"
  }
}

resource "aws_alb_listener" "ecs-demo-internal" {
  load_balancer_arn = aws_alb.ecs-demo-internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.ecs-demo-internal.id
    type = "forward"
  }
}






 


