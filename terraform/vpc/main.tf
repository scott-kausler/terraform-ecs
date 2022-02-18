
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = terraform.workspace
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, var.subnet_count)
  private_subnets = slice(["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"], 0, var.subnet_count)
  public_subnets  = slice(["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"], 0, var.subnet_count)

  enable_nat_gateway = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}