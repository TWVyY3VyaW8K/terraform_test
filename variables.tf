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

variable "min_size" {
  description = "LC instances min size"
  type        = int
  default     = 2
}

variable "max_size" {
  description = "LC instances max size"
  type        = int
  default     = 2
}

variable "desired_capacity" {
  description = "LC instances desired capacity"
  type        = int
  default     = 3
}

variable "capacity_timeout" {
  description = "LC instances capacity tameout"
  type        = int
  default     = 0
}

# Launch configuration names
variable "lc_name" {
  description = "Name of LC"
  type        = string
  default     = "daniele-lc"
}

variable "lc_image_id" {
  description = "Name of LC image id"
  type        = string
  default     = "ami-07dfba995513840b5"
}

variable "lc_type" {
  description = "Name of LC type"
  type        = string
  default     = "t3.micro"
}

# Istance SG viable names
variable "vpc_name" {
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
  description = "Description of Instance SG"
  type        = list(string)
  default     = ["http-80-tcp"]
}

# LB SG viables names
variable "lb_sg_version" {
  description = "LB SG version"
  type        = string
  default     = "3.12.0"
}

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