module "fargate_cluster" {
  source = "../modules/fargate"

  aws_region   = var.aws_region
  cluster_name = var.cluster_name
}

module "services_registry" {
  source = "../modules/service-registry"

  aws_region = var.aws_region
  dns_name   = "services.${var.namespace_suffix}"
  vpc_id     = var.vpc_id
}

module "desktops_registry" {
  source = "../modules/service-registry"

  aws_region = var.aws_region
  dns_name   = "desktops.${var.namespace_suffix}"
  vpc_id     = var.vpc_id
}

module "alb" {
  source = "../modules/simple-alb"

  aws_region  = var.aws_region
  root_domain = var.root_domain
  hostname    = var.hostname
  subnets     = var.pub_subnets
}