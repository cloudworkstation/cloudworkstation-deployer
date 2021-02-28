locals {
  path_routing_config = [
    {
      name   = "api_route"
      number = var.number_of_api_instances
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

data "aws_caller_identity" "current" {}

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
    module.allow_p80.group_id,
    module.allow_p5000.group_id
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
    oidc_ru                     = var.oidc_remote_user_claim
  })
}

module "allow_p8080" {
  source = "../modules/reflexive-sec-group"

  aws_region = var.aws_region
  vpc_id     = var.vpc_id
  port_num   = 8080
}

module "allow_p5000" {
  source = "../modules/reflexive-sec-group"

  aws_region = var.aws_region
  vpc_id     = var.vpc_id
  port_num   = 5000
}

data "aws_iam_policy_document" "cloudmap_policy" {
  statement {
    sid    = "1"
    effect = "Allow"

    actions = [
      "servicediscovery:Get*",
      "servicediscovery:List*"
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

module "db" {
  source = "../modules/dynamo-db-table"

  table_name = var.table_name
  hash_key   = "domain"
  sort_key   = "sub_id"
}

data "aws_iam_policy_document" "api_policy" {
  statement {
    sid    = "1"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "2"
    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "3"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]

    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.table_name}"
    ]
  }
}

resource "aws_iam_policy" "api_policy" {
  policy = data.aws_iam_policy_document.api_policy.json
}

module "api" {
  source = "../modules/ecs-service"

  aws_region   = var.aws_region
  vpc_id       = var.vpc_id
  cluster_name = var.cluster_name
  service_name = "${var.cluster_name}-api"
  cpu          = 256
  memory       = 512

  use_spot_capacity = var.use_spot_capacity

  task_name           = "api"
  number_of_instances = var.number_of_api_instances

  attach_to_alb                 = false
  container_to_expose           = "api"
  container_port_to_expose      = 5000
  service_registry_id           = var.services_registry_namespace
  service_registry_service_name = "api"

  task_subnets = var.task_subnets

  security_groups = [
    module.allow_p5000.group_id
  ]

  task_role_policies = [
    aws_iam_policy.api_policy.arn
  ]

  tasks_def = templatefile("${path.module}/api-tasks.json", {
    region       = var.aws_region
    cluster      = var.cluster_name
    service      = "${var.cluster_name}-api"
    table_name   = var.table_name
    task_arn     = module.api_deps.task_name_and_revision
    sec_group    = module.api_deps.security_group_id
    subnets      = join(",", var.task_subnets)
    env_key      = var.env_key
  })
}

module "api_deps" {
  source = "../api-deps"

  aws_region   = var.aws_region
  vpc_id       = var.vpc_id
  cluster_name = var.cluster_name
  env_key      = var.env_key

  task_subnets                = var.task_subnets
  instance_subnets            = var.instance_subnets
  desktops_registry_namespace = var.desktops_registry_namespace
  security_group_id           = module.allow_p8080.group_id
  instance_mgr_version        = var.instance_mgr_version
}