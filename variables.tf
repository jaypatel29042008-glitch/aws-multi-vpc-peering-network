variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc1_cidr" {
  type    = string
  default = "28.0.0.0/16"
}

variable "subnet1_public_cidr" {
  type    = string
  default = "28.0.1.0/24"
}

variable "subnet2_private_cidr" {
  type    = string
  default = "28.0.2.0/24"
}

variable "vpc2_cidr" {
  type    = string
  default = "28.200.0.0/16"
}

variable "subnet3_target_cidr" {
  type    = string
  default = "28.200.0.0/16"
}

variable "admin_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ami_id" {
  type    = string
  default = "ami-0c101f26f147fa7fd"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "aws-capstone-key"
}
