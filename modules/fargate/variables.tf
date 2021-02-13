variable "aws_region" {
  type = string
  description = "AWS region where this should be provisioned"
}

variable "cluster_name" {
  type = string
  description = "Name for fargate cluster, defaults to 'desktops'"
  default = "desktops"
}