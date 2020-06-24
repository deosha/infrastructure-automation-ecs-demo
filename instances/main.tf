provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "state-files-ecs-demo"
    key    = "prod/instances.tfstate"
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

data "terraform_remote_state" "ecs" {
  backend = "s3"
  config = {
    bucket = "state-files-ecs-demo"
    key    = "prod/ecs.tfstate"
    region = "ap-south-1"
  }
}

data "aws_ami" "ecs_instance_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-2018.03.a-amazon-ecs-optimized"]
  }
}

data "aws_ami" "ephemeral_instance_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-hvm*-x86_64-gp2"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.tpl")

  vars = {
    ecs_config = var.ecs_config
    cluster_name = data.terraform_remote_state.ecs.outputs.cluster_name
    env_name = "prod"
    custom_userdata = var.custom_userdata
    cloudwatch_prefix = var.cloudwatch_prefix
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  name = "ecs-demo-prod"

  lc_name = "ecs-demo-prod"

  image_id        = data.aws_ami.ecs_instance_ami.id
  instance_type   = "c5.large"
  security_groups = [data.terraform_remote_state.security_groups.outputs.internal_alb_security_group_id,data.terraform_remote_state.security_groups.outputs.public_alb_security_group_id,data.terraform_remote_state.security_groups.outputs.ssh_security_group_id]
  user_data       = data.template_file.user_data.rendered
  iam_instance_profile = data.terraform_remote_state.ecs.outputs.iam_instance_profile_id
  key_name = "ecs-demo-prod"
  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    }
  ]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "ecs-demo-asg-prod"
  vpc_zone_identifier       = data.terraform_remote_state.vpc.outputs.private_subnets
  health_check_type         = "EC2"
  min_size                  = 2
  max_size                  = 6
  desired_capacity          = 3
  wait_for_capacity_timeout = 0
  enable_monitoring = true

  tags = [
    {
      key                 = "organization"
      value               = "my-org"
      propagate_at_launch = true
    },
    {
      key                 = "component"
      value               = "my-component"
      propagate_at_launch = true
    },
    {
      key                 = "subcomponent"
      value               = "my-subcomponent"
      propagate_at_launch = true
    },
    {
      key                 = "role"
      value               = "node"
      propagate_at_launch = true
    },
    {
      key                 = "servicetype"
      value               = "node"
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = "prod"
      propagate_at_launch = true
    }
 ]
}


