# Terraform configuration

provider "aws" {
  region = "eu-central-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = var.asg_name

  # Launch configuration
  lc_name      = var.lc_name
  image_id     = var.lc_image_id
  instace_type = var.lc_type

  security_groups = [module.vpc.default_security_group_id]

  # Auto scaling group
  asg_name            = var.asg_name
  vpc_zone_identifier = [var.vpc_private_subnets, var.vpc_public_subnets]
  health_check_type   = var.asg_check_type #"EC2"

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.desired_capacity

  wait_for_capacity_timeout = var.capacity_timeout
  }

