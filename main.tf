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
  instance_type = var.lc_type

  ### user details ?? ###

  security_groups = [module.vpc.default_security_group_id]

  # Auto scaling group
  asg_name            = var.asg_name
  vpc_zone_identifier = [var.vpc_private_subnets, var.vpc_public_subnets]
  health_check_type   = var.asg_check_type

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.desired_capacity

  wait_for_capacity_timeout = var.capacity_timeout
  }

module "instance_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.instance_sg_name
  description = var.instance_sg_description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks  = var.instance_sg_ingress_cidr_blocks
  ingress_rules        = var.instance_sg_ingress_rules
}

module "lb_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = var.lb_sg_version

  for_each = var.project

  name  = "load-balancer-sg-${each.key}-${each.value.environment}"

  description = var.lb_sg_description 
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = var.lb_sg_ingress_cidr_blocks
}