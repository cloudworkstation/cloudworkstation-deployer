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

variable "number_of_oidc_instances" {
  type = number
  description = "Number of OIDC (login) instances which should run, defaults to 2."
  default = 2
}

variable "number_of_router_instances" {
  type = number
  description = "Number of desktop router instances which should run, defaults to 2."
  default = 2
}

variable "number_of_api_instances" {
  type = number
  description = "Number of API server instances which should run, defaults to 2."
  default = 2
}

variable "number_of_console_instances" {
  type = number
  description = "Number of console server instances which should run, defaults to 2."
  default = 2
}


variable "use_spot_capacity" {
  type = bool
  description = "Should spot capacity be used to create Fargate tasks.  Defaults to 'false'"
  default = false
}

variable "services_registry_namespace" {
  type = string
  description = "ID of the CloudMap namespace used to register service tasks."
}

variable "desktops_registry_namespace" {
  type = string
  description = "ID of the CloudMap namespace used to register desktop tasks."
}

variable "alb_listener_arn" {
  type = string
  description = "ARN of ALB listener to attach to, only needed when using an ALB"
}

variable "public_dns_name" {
  type = string
  description = "The public DNS name where the ALB is reachable e.g. 'desktops.root.com'"
}

variable "alb_security_group" {
  type = string
  description = "ID of the security group where the load balancer traffic comes from"
}

variable "task_subnets" {
  type = list(string)
  description = "List of subnets in which to launch tasks"
}

variable "instance_subnets" {
  type = list(string)
  description = "List of subnets in which to launch instances"
}

variable "oidc_metadata_url" {
  type = string
  description = "This is the URL for the OIDC IdP meta-data"
}

variable "oidc_jwks_uri" {
  type = string
  description = "This is the URL for the OIDC IdP JWKS service"
}

variable "oidc_client_id" {
  type = string
  description = "The Client ID which is configured on the OIDC IdP"
}

variable "oidc_client_secret_ssm_name" {
  type = string
  description = "Name of SSM SecureString parameter which contains the client secret expected by the OIDC IdP"
}

variable "oidc_crypto_passphrase_ssm_name" {
  type = string
  description = "Name of SSM SecureString parameter which contains the passphrase used to encrypt session tokens"
}

variable "instance_mgr_version" {
  type = string
  description = "Version of the instance manager to use"
}

variable "table_name" {
  type = string
  description = "Name of the DyanamoDB table to create to store application data, defaults to 'desktops_data'"
  default = "desktops_data"
}

variable "oidc_remote_user_claim" {
  type = string
  description = "Name of claim to use as OIDC remote user value, defaults to 'email'"
  default = "email"
}

variable "env_key" {
  type = string
  description = "Key to identify the environment and desktops which belong to the environment, defaults to 'prod'"
  default = "prod"
}

variable "tf_state_access_log_bucket" {
  type = string
  description = "Name of the bucket to put access logs in, if blank access logging is disabled"
  default = ""
}

variable "tf_state_access_log_prefix" {
  type = string
  description = "Prefix for access logging if enabled"
  default = ""
}