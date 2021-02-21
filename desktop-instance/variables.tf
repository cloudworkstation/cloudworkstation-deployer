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

variable "desktop_id" {
  type = string
  description = "Short string which is the unique ID for the desktop"
}

variable "ami_id" {
  type = string
  description = "What Amazon Machine Image should be used to create the desktop instance"
}

variable "task_subnets" {
  type = list(string)
  description = "List subnets where tasks should be created."
}

variable "instance_subnets" {
  type = list(string)
  description = "List subnets where the instance should be created."
}

variable "instance_type" {
  type = string
  description = "What type of instance should be created, defaults to t3.medium"
  default = "t3.medium"
}

variable "machinedefcode" {
  type = string
  description = "Machine definition used to create the instance"
}

variable "screen_geometry" {
  type = string
  description = "What display resolution should be used, defaults to 1920x1080"
  default = "1920x1080"
}

variable "username" {
  type = string
  description = "What username is the desktop being created for?"
}

variable "services_registry_namespace" {
  type = string
  description = "ID of the CloudMap namespace used to register service tasks."
}

variable "traffic_source_security_group" {
  type = string
  description = "ID of the security group whic allows user traffic into the webapp"
}

variable "user_data" {
  type = string
  description = "Script which sets up VNC desktop for connection from webapp"
}