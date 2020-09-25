# Input variable definitions

# VPC viables names
variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "daniele-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "vpc_private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type    = bool
  default = true
}

variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default     = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Placement group viables names

variable "pg_name" {
  description = "Name of PG"
  type        = string
  default     = "daniele-pg-test"
}

variable "pg_strategy" {
  description = "Starategy of PG"
  type        = string
  default     = "partition"
}

# ASG viables names

variable "asg_name" {
  description = "Name of ASG"
  type        = string
  default     = "daniele-asg"
}

variable "asg_check_type" {
  description = "Name of LC check type"
  type        = string
  default     = "EC2"
}

variable "asg_min_size" {
  description = "ASG instances min size"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "ASG instances max size"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "ASG instances desired capacity"
  type        = number
  default     = 2
}

variable "asg_grace_period" {
  description = "ASG instances grace period"
  type        = number
  default     = 300
}

# Launch template names

variable "lt_name" {
  description = "Name of LT"
  type        = string
  default     = "daniele-lt"
}

variable "lt_image_id" {
  description = "Name of LT image id"
  type        = string
  default     = "ami-00a205cb8e06c3c4e"
}

variable "lt_type" {
  description = "Name of LT type"
  type        = string
  default     = "t3.micro"
}

variable "lt_is_ip_addr_public" {
  description = "Name of LT type"
  type        = bool
  default     = true
}

variable "lt_key_name" {
  description = "Key name for LT istances"
  type        = string
  default     = "sub1_private_key.pem"
}

# Istance SG viable names
variable "instance_sg_name" {
  description = "Name of Instance SG"
  type        = string
  default     = "instances-sg"
}

variable "instance_sg_description" {
  description = "Description of Instance SG"
  type        = string
  default     = "Security group for auto scaling group istances"
}

variable "instance_sg_cidr_blocks" {
  description = "Description of Instance SG"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # <- da rivedere
}

variable "instance_sg_ingress_rules" {
  description = "Instance SG ingress rules"
  type        = list(string)
  default     = ["http-80-tcp"]
}

# LB SG viables names

variable "lb_sg_description" {
  description = "LB SG description"
  type        = string
  default     = "Security group for load balancer with HTTP ports open within VPC"
}

variable "lb_sg_ingress_cidr_blocks" {
  description = "LB SG ingress cidr blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"] # <- da rivedere
}

# Target groups aviable names

variable "lb_tg_name" {
  description = "Name of LB TG"
  type        = string
  default     = "danielelbtg"
}

# Load Balancer aviable names

variable "lb_name" {
  description = "Name of LB"
  type        = string
  default     = "danielelb"
}

variable "lb_type" {
  description = "Type of LB"
  type        = string
  default     = "application"
}
