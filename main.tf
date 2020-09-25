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

module "instance_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.instance_sg_name
  description = var.instance_sg_description
  vpc_id      = module.vpc.vpc_id

  # ingress_cidr_blocks = var.instance_sg_ingress_cidr_blocks
  # ingress_rules       = var.instance_sg_ingress_rules

}

resource "aws_launch_template" "lt" {
  name          = var.lt_name
  image_id      = var.lt_image_id
  instance_type = var.lt_type
  key_name      = var.lt_key_name

  network_interfaces {
  associate_public_ip_address = var.lt_is_ip_addr_public
  }

  vpc_security_group_ids = [module.instance_sg.this_security_group_id]

  user_data = filebase64("${path.module}/example.sh")
}

resource "aws_placement_group" "pg" {
  name     = var.pg_name
  strategy = var.pg_strategy
}

resource "aws_autoscaling_group" "asg" {
  name             = var.asg_name

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.desired_capacity

  health_check_grace_period = var.asg_grace_period
  placement_group           = aws_placement_group.test.id
  vpc_zone_identifier       = module.vpc.public_subnets

  launch_template {
  id      = aws_launch_template.lt.id
  version = "$Latest"
  }

} 

module "lb_sg" {
  source  = "terraform-aws-modules/security-group/aws/modules/web"
  version = var.lb_sg_version

  for_each = var.project

  name = "load-balancer-sg-${each.key}-${each.value.environment}"

  description = var.lb_sg_description 
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = var.lb_sg_ingress_cidr_blocks
}

# resource "aws_lb_target_group" "lb_tg" {
#   name     = var.lb_tg_name
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = module.vpc.vpc_id
# }

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 2.0"

  name = var.lb_name

  subnets         = module.vpc.private_subnet_arns
  security_groups = [module.lb_sg.this_security_group_id]
  internal        = false

    listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
    {
      instance_port     = "8080"
      instance_protocol = "http"
      lb_port           = "8080"
      lb_protocol       = "http"
    },
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}