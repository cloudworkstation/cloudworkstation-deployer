variable "aws_region" {
  type = string
  description = "AWS region where this should be provisioned"
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPC where the namespace should be created"
}

variable "dns_name" {
  type = string
  description = "DNS name for the namespace"
}