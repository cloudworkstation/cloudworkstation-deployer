variable "aws_region" {
  type = string
  description = "AWS region where this should be provisioned"
}

variable "vpc_id" {
  type = string
  description = "ID of the VPC where the instance will sit"
}

variable "port_num" {
  type = number
  description = "Port number to allow communications on"
}