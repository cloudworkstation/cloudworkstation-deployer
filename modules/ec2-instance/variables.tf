variable "aws_region" {
  type = string
  description = "AWS region where this should be provisioned"
}

variable "vpc_id" {
  type = string
  description = "ID of the VPC where the instance will sit"
}

variable "desktop_id" {
  type = string
  description = "8 character unique ID for the desktop"
}

variable "ami_id" {
  type = string
  description = "ID for AMI to use for desktop"
}

variable "subnets" {
  type = list(string)
  description = "Subnets in which to launch the instance, the subnet is picked at random"
}

variable "instance_type" {
  type = string
  description = "What type of instance to launch, defaults to t3.large"
  default = "t3.large"
}

variable "screen_geometry" {
  type = string
  description = "What screen resolution should be used, defaults to 1080p"
  default = "1920x1080"
}

variable "machinedefcode" {
  type = string
  description = "Machine definition used to create the instance"
}

variable "username" {
  type = string
  description = "What is the username of the user for the desktop"
}

variable "user_data" {
  type = string
  description = "Script to run on instance creation, should be base64 encoded"
}

variable "root_volume_size" {
  type = number
  description = "Size (in GB) of the root volume, defaults to 20"
  default = 20
}

variable "security_groups" {
  type = list(string)
  description = "List of additional security groups to attach to the instance, optional."
  default = []
}

variable "additional_instance_role_policies" {
  type = list(string)
  description = "List of additional policies to attach to the IAM instance profile, optional."
  default = []
}
