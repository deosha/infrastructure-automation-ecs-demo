provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "state-files-ecs-demo"
    key    = "prod/deployment.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "ecs" {
  backend = "s3"
  config = {
    bucket = "state-files-ecs-demo"
    key    = "prod/ecs.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "app_instances" {
  backend = "s3"
  config = {
    bucket = "state-files-ecs-demo"
    key    = "prod/ecs-demo.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "load-balancers" {
  backend = "s3"
  config = {
    bucket = "state-files-ecs-demo"
    key    = "prod/alb.tfstate"
    region = "ap-south-1"
  }
}

data "template_file" "this" {
  template = file("task-definitions/ecs-demo-prod.tpl")

  vars= {
    tag = var.tag
  }
}

data aws_ecs_task_definition "this" {
  task_definition = aws_ecs_task_definition.this.family
}


resource "aws_ecs_task_definition" "this" {
  family = "ecs-demo-prod"
  container_definitions = data.template_file.this.rendered
  network_mode = "bridge"
  requires_compatibilities = [
    "EC2"]
//  volume {
//    name      = "applicationData"
//    host_path = "/var/log"
//  }
}

resource "aws_ecs_service" "private" {
  name = "ecs-demo-internal-prod"
  cluster = data.terraform_remote_state.ecs.outputs.cluster_id
  task_definition = "${aws_ecs_task_definition.this.family}:${max("${aws_ecs_task_definition.this.revision}","${data.aws_ecs_task_definition.this.revision}")}"
 // task_definition = "$(aws_ecs_task_definition.this.family):${aws_ecs_task_definition.this.revision}"
  desired_count = 6
  launch_type = "EC2"
  scheduling_strategy = "REPLICA"
  deployment_maximum_percent = "100"
  deployment_minimum_healthy_percent = "50"

  load_balancer {
    target_group_arn = data.terraform_remote_state.load-balancers.outputs.internal_alb_ecs-demo_tg_arn
    container_name   = "ecs-demo-prod"
    container_port   = 8080
  }

  ordered_placement_strategy {
    type = "binpack"
    field = "cpu"
  }

//  placement_constraints {
  //  type = "distinctInstance"
 // }

}



