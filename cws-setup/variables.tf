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

variable "priv_subnets" {
  type = list(string)
  description = "List of private subnets where tasks should be created."
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
  description = "Number of api instances which should run, defaults to 2."
  default = 2
}

variable "use_spot_capacity" {
  type = bool
  description = "Should spot capacity be used to create Fargate tasks.  Defaults to 'false'"
  default = false
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
  description = "What version of instance manager should we use, defaults to v0.05"
  default = "v0.05"
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