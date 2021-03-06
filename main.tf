# Terraform configuration

provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "daniele-vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "sub1_public" {
  vpc_id                  = aws_vpc.daniele-vpc.id
  cidr_block              = var.vpc_private_subnets[0]
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "sub1_public"
  }
}

resource "aws_subnet" "sub2_public" {
  vpc_id                  = aws_vpc.daniele-vpc.id
  cidr_block              = var.vpc_private_subnets[1]
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "sub2_public"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.daniele-vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.daniele-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.daniele-vpc.id
  route_table_id = aws_route_table.r.id
}

module "instance_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.instance_sg_name
  description = var.instance_sg_description
  vpc_id      = aws_vpc.daniele-vpc.id

  ingress_cidr_blocks  = var.instance_sg_cidr_blocks
  ingress_rules        = var.instance_sg_ingress_rules
}

resource "aws_security_group" "instance_sg" {
  name        = var.instance_sg_name
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.daniele-vpc.id

  ingress {
    description = "HTTP from LB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.instance_sg_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.instance_sg_cidr_blocks
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_launch_template" "lt" {
  name          = var.lt_name
  image_id      = var.lt_image_id
  instance_type = var.lt_type

  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  user_data = filebase64("${path.module}/example.sh")
}

resource "aws_placement_group" "pg" {
  name     = var.pg_name
  strategy = var.pg_strategy
}

resource "aws_lb_target_group" "lb_tg" {
   name     = var.lb_tg_name
   port     = 80
   protocol = "HTTP"
   vpc_id   = aws_vpc.daniele-vpc.id
 }

resource "aws_autoscaling_group" "asg" {
  name             = var.asg_name

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  health_check_grace_period = var.asg_grace_period
  placement_group           = aws_placement_group.pg.id
  vpc_zone_identifier       = [aws_subnet.sub1_public.id, aws_subnet.sub2_public.id]

  launch_template {
  id      = aws_launch_template.lt.id
  version = "$Latest"
  }

  target_group_arns = ["${aws_lb_target_group.lb_tg.arn}"]
} 

data "aws_instances" "test" {
  filter {
    name   = "image-id"
    values = [var.lt_image_id]
  }

  depends_on = [aws_autoscaling_group.asg]
}

module "lb_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "3.12.0"

  name = var.lb_sg_name

  description = var.lb_sg_description 
  vpc_id      = aws_vpc.daniele-vpc.id

  ingress_cidr_blocks = var.lb_sg_ingress_cidr_blocks
}

resource "aws_alb" "alb_http" {
  name            = var.lb_name
  internal        = false
  idle_timeout    = "300"
  security_groups = [module.lb_sg.this_security_group_id]
  subnets         = [aws_subnet.sub1_public.id, aws_subnet.sub2_public.id]
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb_http.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_tg.arn
    type             = "forward"
  }

}

resource "aws_alb_target_group" "alb_tg" {
  name        = var.lb_tg_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.daniele-vpc.id
  target_type = "instance"
}

resource "aws_alb_target_group_attachment" "test" {
   count            = var.asg_desired_capacity
   target_group_arn = aws_alb_target_group.alb_tg.arn
   target_id        = data.aws_instances.test.ids[count.index]
   
   depends_on = [data.aws_instances.test]
 }
