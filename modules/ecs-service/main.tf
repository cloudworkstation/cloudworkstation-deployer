/*provider "aws" {
  region = var.aws_region
}*/

data "aws_caller_identity" "current" {}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "/ecs/${var.cluster_name}/${var.service_name}"
}

data "aws_iam_policy_document" "ecs_task_role_assume_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "task_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "task_user_policies" {
  count       = length(var.task_role_policies)

  role        = aws_iam_role.task_role.name
  policy_arn  = element(var.task_role_policies, count.index)
}

data "aws_iam_policy_document" "ecs_service_role_assume_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "service_role_policy" {
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = ["*"]
  }

  statement {
    sid       = "2"
    effect    = "Allow"
    actions   = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "get_secret_policy" {
  count = var.repository_credentials_secret == "" ? 0 : 1

  statement {
    sid = "1"
    effect = "Allow"

    actions = ["secretsmanager:GetSecretValue"]

    resources = [var.repository_credentials_secret]
  }

}

resource "aws_iam_policy" "service_role_policy" {
  policy = data.aws_iam_policy_document.service_role_policy.json
}

resource "aws_iam_policy" "get_secret_policy" {
  count = var.repository_credentials_secret == "" ? 0 : 1

  policy = data.aws_iam_policy_document.get_secret_policy[0].json
}

resource "aws_iam_role" "service_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_service_role_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "service_managed_ecs_policy_attach" {
  role       = aws_iam_role.service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "service_role_policy_attach" {
  role       = aws_iam_role.service_role.name
  policy_arn = aws_iam_policy.service_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "secret_role_policy_attach" {
  count = var.repository_credentials_secret == "" ? 0 : 1

  role       = aws_iam_role.service_role.name
  policy_arn = aws_iam_policy.get_secret_policy[0].arn
}

resource "aws_ecs_task_definition" "task" {
  depends_on = [aws_cloudwatch_log_group.logs]

  family                    = "${var.service_name}-${var.task_name}"
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = var.cpu
  memory                    = var.memory
  container_definitions     = var.tasks_def

  execution_role_arn  = aws_iam_role.service_role.arn
  task_role_arn       = length(var.task_role_policies) == 0 ? null : aws_iam_role.task_role.arn
}

resource "aws_security_group" "allow_egress_to_world" {
  name_prefix = "ecs-egress"
  description = "Allow outbound to world"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs_${var.service_name}_${var.task_name}_to_world"
  }
}

resource "aws_security_group" "allow_ingress_from_lb" {
  count = var.attach_to_alb ? 1 : 0

  name_prefix = "ecs-ingress"
  description = "Allow inbound from lb"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = [
      var.alb_security_group
    ]
  }

  tags = {
    Name = "lb_to_ecs_${var.service_name}_${var.task_name}"
  }
}


resource "aws_service_discovery_service" "discovery" {
  name = "_${var.service_registry_service_name}._tcp"
  
  dns_config {
    namespace_id = var.service_registry_id
    
    dns_records {
      ttl   = 60
      type  = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 2
  }
}

resource "aws_ecs_service" "service" {
  name              = var.service_name
  cluster           = data.aws_ecs_cluster.cluster.id
  task_definition   = aws_ecs_task_definition.task.arn
  desired_count     = var.number_of_instances

  service_registries {
    registry_arn    = aws_service_discovery_service.discovery.arn
    container_name  = var.container_to_expose
    container_port  = var.container_port_to_expose
  }

  dynamic "load_balancer" {
    for_each = var.attach_to_alb ? [ "blah" ] : []
    
    content {
      target_group_arn  = aws_lb_target_group.target_group.0.arn
      container_name    = var.container_to_expose
      container_port    = var.container_port_to_expose
    }
  }

  network_configuration {
    subnets         = var.task_subnets
    security_groups = concat([aws_security_group.allow_egress_to_world.id], 
                              var.security_groups,
                              var.alb_listener_arn == "" ? [] : [aws_security_group.allow_ingress_from_lb.0.id])
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.use_spot_capacity ? [ "using-spot" ] : []

    content {
      capacity_provider = "FARGATE_SPOT"
      weight            = 100
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.use_spot_capacity ? [ ] : [ "not-using-spot"]

    content {
      capacity_provider = "FARGATE"
      weight            = 100
    }
  }
}

resource "aws_lb_listener_rule" "lb_listener_rule" {
  count = var.attach_to_alb ? 1 : 0

  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.0.arn
  }

  condition {
    host_header {
      values = [var.service_public_dns_name]
    }
  }

  depends_on = [ aws_lb_target_group.target_group ]
}

resource "aws_lb_target_group" "target_group" {
  count = var.attach_to_alb ? 1 : 0

  port                  = "80"
  protocol              = "HTTP"
  vpc_id                = var.vpc_id
  target_type           = "ip"
  deregistration_delay  = 10

  health_check {
    matcher             = "200,301,302"
    path                = "/_stats"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    port                = "8080"
  }
}