/*provider "aws" {
  region = var.aws_region
}*/

resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name        = var.dns_name
  description = "namespace for ECS cluster services for ${var.dns_name}"
  vpc         = var.vpc_id
}