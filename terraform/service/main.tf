data "aws_region" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.s3_backend_bucket
    key    = "env:/${terraform.workspace}/vpc.tfstate"
    region = data.aws_region.current.name
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    bucket = var.s3_backend_bucket
    key    = "env:/${terraform.workspace}/cluster.tfstate"
    region = data.aws_region.current.name
  }
}

data "terraform_remote_state" "service_build" {
  backend = "s3"

  config = {
    bucket = var.s3_backend_bucket
    key    = "env:/${terraform.workspace}/service-build.tfstate"
    region = data.aws_region.current.name
  }
}

locals {
  port = 3000
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = data.terraform_remote_state.cluster.outputs.load_balancer_arn
  port              = local.port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.fargate.target_group_arn[0]
  }
}

#####
# Security Group Config
#####
resource "aws_security_group_rule" "alb_ingress" {
  security_group_id = data.terraform_remote_state.cluster.outputs.load_balancer_security_group_id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = local.port
  to_port           = local.port
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "alb_egress" {
  security_group_id        = data.terraform_remote_state.cluster.outputs.load_balancer_security_group_id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = local.port
  to_port                  = local.port
  source_security_group_id = module.fargate.service_sg_id
}

resource "aws_security_group_rule" "task_ingress" {
  security_group_id        = module.fargate.service_sg_id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = local.port
  to_port                  = local.port
  source_security_group_id = data.terraform_remote_state.cluster.outputs.load_balancer_security_group_id
}


module "fargate" {
  source  = "umotif-public/ecs-fargate/aws"
  version = "~> 6.1.0"

  name_prefix        = terraform.workspace
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  cluster_id = terraform.workspace

  task_container_image = data.terraform_remote_state.service_build.outputs.image_name

  task_container_port             = local.port
  task_container_assign_public_ip = false

  target_groups = [
    {
      target_group_name = "traffic"
      container_port    = local.port
    }
  ]

  health_check = {
    port = "traffic-port"
    path = "/"
  }

  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT",
      weight            = 100
    }
  ]
}

output "url" {
  value = "${data.terraform_remote_state.cluster.outputs.load_balancer_dns_name}:${local.port}"
}