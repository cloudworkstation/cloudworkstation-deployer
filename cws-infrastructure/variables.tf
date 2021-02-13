variable "aws_region" {
  type = string
  description = "AWS region where this should be provisioned"
}

variable "vpc_id" {
  type = string
  description = "ID of the VPC where the deployment should happen"
}

variable "cluster_name" {
  type = string
  description = "Name for fargate cluster, defaults to 'desktops'"
  default = "desktops"
}

variable "namespace_suffix" {
  type = string
  description = "Suffix to use for CloudMap namespaces, defaults to 'workstations.local'"
  default = "workstations.local"
}

variable "pub_subnets" {
  type = list(string)
  description = "List of public subnets where ALB should be created."
}

variable "root_domain" {
  type = string
  description = "Route53 hosted zone under which the entry for the ALB will be created."
}

variable "hostname" {
  type = string
  description = "Name of the recordset which will be created in Route53 to point to the ALB, defaults to 'desktops'"
  default = "desktops"
}