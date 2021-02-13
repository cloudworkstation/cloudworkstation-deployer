locals {
  path_routing_config = [
    {
      name   = "api_route"
      number = "5"
      path   = "api"
      dns    = "_api._tcp.services.${var.namespace_suffix}"
    },
    {
      name   = "console_route"
      number = "5"
      path   = "console"
      dns    = "_console._tcp.services.${var.namespace_suffix}"
    },
    {
      name   = "desktops_route"
      number = var.number_of_router_instances
      path   = "desktop"
      dns    = "_desktops._tcp.services.${var.namespace_suffix}"
    }
  ]
}

module "allow_p80" {
  source = "../modules/reflexive-sec-group"

  aws_region = var.aws_region
  vpc_id     = var.vpc_id
  port_num   = 80
}

module "oidc" {
  source = "../modules/ecs-service"

  aws_region   = var.aws_region
  vpc_id       = var.vpc_id
  cluster_name = var.cluster_name
  service_name = "${var.cluster_name}-oidc"
  cpu          = 512
  memory       = 1024
  
  use_spot_capacity = var.use_spot_capacity

  task_name           = "rproxy"
  number_of_instances = var.number_of_oidc_instances
  
  container_to_expose           = "proxy"
  container_port_to_expose      = 80
  service_registry_id           = var.services_registry_namespace
  service_registry_service_name = "oidc"
  
  attach_to_alb           = true
  alb_listener_arn        = var.alb_listener_arn
  service_public_dns_name = var.public_dns_name
  alb_security_group      = var.alb_security_group
  task_subnets            = var.task_subnets

  security_groups = [
    module.allow_p80.group_id
  ]  

  tasks_def = templatefile("${path.module}/oidc-tasks.json", {
    region                      = var.aws_region
    cluster                     = var.cluster_name
    service                     = "${var.cluster_name}-oidc"
    metadata_url                = var.oidc_metadata_url
    jwks_uri                    = var.oidc_jwks_uri
    client_id                   = var.oidc_client_id
    domain                      = var.public_dns_name
    client_secret_ssm_name      = var.oidc_client_secret_ssm_name
    crypto_passphrase_ssm_name  = var.oidc_crypto_passphrase_ssm_name
    routing_config              = local.path_routing_config
  })
}

module "allow_p8080" {
  source = "../modules/reflexive-sec-group"

  aws_region = var.aws_region
  vpc_id     = var.vpc_id
  port_num   = 8080
}

data "aws_iam_policy_document" "cloudmap_policy" {
  statement {
    sid    = "1"
    effect = "Allow"

    actions = [
      //"servicediscovery:DeregisterInstance",
      "servicediscovery:Get*",
      "servicediscovery:List*"
      //"servicediscovery:RegisterInstance",
      //"servicediscovery:UpdateInstanceCustomHealthStatus"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudmap_policy" {
  policy = data.aws_iam_policy_document.cloudmap_policy.json
}

module "router" {
  source = "../modules/ecs-service"

  aws_region   = var.aws_region
  vpc_id       = var.vpc_id
  cluster_name = var.cluster_name
  service_name = "${var.cluster_name}-router"
  cpu          = 256
  memory       = 512

  use_spot_capacity = var.use_spot_capacity

  task_name           = "router"
  number_of_instances = var.number_of_router_instances

  attach_to_alb                 = false
  container_to_expose           = "router"
  container_port_to_expose      = 80
  service_registry_id           = var.services_registry_namespace
  service_registry_service_name = "desktops"

  task_subnets = var.task_subnets

  security_groups = [
    module.allow_p80.group_id,
    module.allow_p8080.group_id
 ]

  task_role_policies = [
    aws_iam_policy.cloudmap_policy.arn
  ]

  tasks_def = templatefile("${path.module}/router-tasks.json", {
    region       = var.aws_region
    cluster      = var.cluster_name
    service      = "${var.cluster_name}-router"
    notfoundurl  = "https://${var.public_dns_name}/console/desktopnotfound.html"
    stats_passwd = "blah"
    prom_passwd  = "blah"
    namespaces   = [
      {
        domainname = "invalid"
        namespace  = "desktops.${var.namespace_suffix}"
        mode       = "path"
      }
    ]
  })
}