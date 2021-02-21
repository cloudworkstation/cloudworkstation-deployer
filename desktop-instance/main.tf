module "allow_vnc" {
  source = "../modules/reflexive-sec-group"

  aws_region = var.aws_region
  vpc_id     = var.vpc_id
  port_num   = 5901
}

module "instance" {
  source = "../modules/ec2-instance"

  aws_region = var.aws_region
  desktop_id = var.desktop_id
  vpc_id     = var.vpc_id
  ami_id     = var.ami_id

  subnets = var.task_subnets

  instance_type   = var.instance_type
  screen_geometry = var.screen_geometry
  username        = var.username
  machinedefcode  = var.machinedefcode
  security_groups = [
    module.allow_vnc.group_id
  ]

  user_data = var.user_data
}

module "webapp" {
  source = "../modules/ecs-service"

  aws_region = var.aws_region
  vpc_id     = var.vpc_id

  cluster_name        = var.cluster_name
  service_name        = "desktop-proxy-${var.desktop_id}"
  task_name           = "desktop-${var.desktop_id}"
  number_of_instances = 1

  attach_to_alb            = false
  container_to_expose      = "vncproxy"
  container_port_to_expose = 8080

  service_registry_id           = var.services_registry_namespace
  service_registry_service_name = var.desktop_id

  security_groups = [
    module.allow_vnc.group_id,
    var.traffic_source_security_group
  ]

  cpu    = 512
  memory = 1024
  
  task_subnets = var.task_subnets

  tasks_def = templatefile("${path.module}/webapp-tasks.json", {
    region          = var.aws_region
    cluster         = var.cluster_name
    service         = "desktop-proxy-${var.desktop_id}"
    desktop_host    = module.instance.instance_priv_dns
    vnc_password    = module.instance.vnc_password
  })
}
