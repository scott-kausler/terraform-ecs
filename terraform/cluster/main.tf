data "aws_region" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.s3_backend_bucket
    key    = "env:/${terraform.workspace}/vpc.tfstate"
    region = data.aws_region.current.name
  }
}

resource "aws_ecs_cluster" "main" {
  name = terraform.workspace

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_lb" "main" {
  name = terraform.workspace

  load_balancer_type = "application"
  internal           = false
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_security_group" "lb" {
  name   = terraform.workspace
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "load_balancer_arn" {
  value = aws_lb.main.arn
}

output "load_balancer_security_group_id" {
  value = aws_security_group.lb.id
}

output "load_balancer_dns_name" {
  value = aws_lb.main.dns_name
}