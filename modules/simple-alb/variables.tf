variable "aws_region" {
  type = string
  description = "AWS region where this should be provisioned"
}

variable "root_domain" {
  type = string
  description = "Route53 hosted zone where records pointing to the ALB/certificates will be created"
}

variable "hostname" {
  type = string
  description = "Name of host to use for deployment e.g. <host>.root.domain, defaults to 'desktops'"
  default = "desktops"
}

variable "subnets" {
  type = list(string)
  description = "List of subnets where the ALB should be deployed, they should be public"
}