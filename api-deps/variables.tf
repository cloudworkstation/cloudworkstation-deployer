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

variable "task_subnets" {
  type = list(string)
  description = "List subnets where tasks should be created."
}

variable "instance_subnets" {
  type = list(string)
  description = "List subnets where the instance should be created."
}

variable "desktops_registry_namespace" {
  type = string
  description = "ID of the CloudMap namespace used to register desktops tasks."
}

variable "security_group_id" {
  type = string
  description = "ID for the security group where traffic for the instances will come from"
}

variable "instance_mgr_version" {
  type = string
  description = "What version of the instance manager is this module to use"
}

variable "env_key" {
  type = string
  description = "Key to identify the environment and desktops which belong to the environment, defaults to 'prod'"
  default = "prod"
}