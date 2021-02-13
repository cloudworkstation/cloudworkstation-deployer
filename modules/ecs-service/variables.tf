variable "aws_region" {
  type = string
  description = "AWS region where this should be provisioned"
}

variable "vpc_id" {
  type = string
  description = "VPC ID used for creating LB target group, optional, only needed when attaching to an LB"
  default = ""
}

variable "cluster_name" {
  type = string
  description = "Name for fargate cluster where the service should run, defaults to 'desktops'"
  default = "desktops"
}

variable "service_name" {
  type = string
  description = "Name for service which will run on fargate"
}

variable "task_name" {
  type = string
  description = "Name for task which will run on fargate"
}

variable "task_role_policies" {
  type = list(string)
  description = "List of policies to attach to the task execution role, optional."
  default = []
}

variable "repository_credentials_secret" {
  type = string
  description = "Secret which stores credentials to access the container repository, needed if using a private repository"
  default = ""
}

variable "number_of_instances" {
  type = number
  description = "How many instances of the tasks should run in the service? Defaults to 1"
  default = 1
}

variable "cpu" {
  type = number
  description = "Amount of CPU to allocate to the task 1024=1 CPU"
}

variable "memory" {
  type = number
  description = "Amount of memory to allocate to the task in MB"
}

variable "tasks_def" {
  type = string
  description = "JSON tasks definition"
}

variable "task_subnets" {
  type = list(string)
  description = "List of subnets in which to launch tasks"
}

variable "security_groups" {
  type = list(string)
  description = "List of security groups to attach to the service"
  default = []
}

variable "container_to_expose" {
  type = string
  description = "Which container in the task should be exposed as a service"
}

variable "container_port_to_expose" {
  type = number
  description = "Port number on the container which is exposed in the service registry"
}

variable "service_registry_id" {
  type = string
  description = "ID of the service registry to use for the service"
}

variable "service_registry_service_name" {
  type = string
  description = "Name of the service to expose in the service registry.  This will be converted to a SRV compliant value."
}

variable "attach_to_alb" {
  type = bool
  description = "Should we attach this service to an ALB"
  default = false
}

variable "alb_listener_arn" {
  type = string
  description = "ARN of listener ARN to attach to, only needed when using an ALB"
  default = ""
}

variable "service_public_dns_name" {
  type = string
  description = "Public DNS name for the service, only needed if the service is being exposed via a load balancer"
  default = ""
}

variable "alb_security_group" {
  type = string
  description = "ID of the security group where the load balancer traffic comes from, optional, only needed when using a load balancer"
  default = ""
}

variable "use_spot_capacity" {
  type = bool
  description = "Should spot capacity be used to create Fargate tasks.  Defaults to 'false'"
  default = false
}