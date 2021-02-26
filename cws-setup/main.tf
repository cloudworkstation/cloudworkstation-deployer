provider "aws" {
  region = var.aws_region
}

module "infra" {
  source = "../cws-infrastructure"

  aws_region       = var.aws_region
  vpc_id           = var.vpc_id
  cluster_name     = var.cluster_name
  namespace_suffix = var.namespace_suffix
  pub_subnets      = var.pub_subnets
  root_domain      = var.root_domain
  hostname         = var.hostname

  //depends_on = [ module.services ]
}

module "services" {
  source = "../cws-services"

  aws_region       = var.aws_region
  vpc_id           = var.vpc_id
  cluster_name     = var.cluster_name
  namespace_suffix = var.namespace_suffix

  number_of_oidc_instances   = var.number_of_oidc_instances
  number_of_router_instances = var.number_of_router_instances

  use_spot_capacity = var.use_spot_capacity

  services_registry_namespace = module.infra.services_namespace_id
  desktops_registry_namespace = module.infra.desktops_namespace_id
  alb_listener_arn            = module.infra.alb_listener_arn
  alb_security_group          = module.infra.alb_sec_group
  public_dns_name             = "${var.hostname}.${var.root_domain}"
  task_subnets                = var.priv_subnets
  instance_subnets            = var.priv_subnets
  instance_mgr_version        = var.instance_mgr_version

  oidc_metadata_url                = var.oidc_metadata_url
  oidc_jwks_uri                    = var.oidc_jwks_uri
  oidc_client_id                   = var.oidc_client_id
  oidc_client_secret_ssm_name      = var.oidc_client_secret_ssm_name
  oidc_crypto_passphrase_ssm_name  = var.oidc_crypto_passphrase_ssm_name

}