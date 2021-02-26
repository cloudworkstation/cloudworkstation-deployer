locals {
  quoted_task_subnets     = [for s in var.task_subnets : join("", ["\"", s, "\""])]
  quoted_instance_subnets = [for s in var.instance_subnets : join("", ["\"", s, "\""])]

  container_task_def = [{
    name          = "instance-manager"
    image         = "cloudworkstation/instance-manager:latest"
    cpu           = 256
    memory        = 512
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.cluster_name}/instance-manager"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "instance-manager"
      }
    }
    
    environment = [
      {
        name  = "MODE"
        value = "TBC"
      },
      {
        name  = "STATE_BUCKET"
        value = module.state_bucket.s3_bucket_name
      },
      {
        name  = "STATE_KEY"
        value = "desktop"
      },
      {
        name  = "AWS_REGION"
        value = var.aws_region
      },
      {
        name  = "VERSION"
        value = var.instance_mgr_version
      },
      {
        name  = "VPC_ID"
        value = var.vpc_id
      },
      {
        name  = "TASK_SUBNETS"
        value = "[${join(", ", local.quoted_task_subnets)}]"
      },
      {
        name  = "INSTANCE_SUBNETS"
        value = "[${join(", ", local.quoted_instance_subnets)}]"
      },
      {
        name  = "DESKTOP_ID"
        value = "TBC"
      },
      {
        name  = "AMI_ID"
        value = "TBC"
      },
      {
        name  = "MACHINE_USERNAME"
        value = "TBC"
      },
      {
        name  = "INSTANCE_TYPE"
        value = "TBC"
      },
      {
        name  = "SCREEN_GEOMETRY"
        value = "TBC"
      },
      {
        name  = "MACHINE_DEF_ID"
        value = "TBC"
      },
      {
        name  = "NAMESPACE_ID"
        value = var.desktops_registry_namespace
      },
      {
        name  = "SECURITY_GROUP_ID"
        value = var.security_group_id
      },
      {
        name  = "B64_USER_DATA"
        value = "TBC"
      }
    ]

  }]
}

data "aws_caller_identity" "current" {}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "/ecs/${var.cluster_name}/instance-manager"
}

module "state_bucket" {
  source = "../modules/s3-bucket"

  bucket_prefix = "desktop-state"
}

resource "aws_ecs_task_definition" "task" {
  depends_on = [aws_cloudwatch_log_group.logs]

  family                    = "desktop-instance-manager"
  network_mode              = "awsvpc"
  requires_compatibilities  = [ "FARGATE" ]
  cpu                       = 256
  memory                    = 512
  container_definitions     = jsonencode(local.container_task_def)
  execution_role_arn        = aws_iam_role.execution_role.arn
  task_role_arn             = aws_iam_role.task_role.arn
}

data "aws_iam_policy_document" "ecs_assume_policy" {
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

resource "aws_iam_role" "execution_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "er_managed_ecs_policy_attach" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
}

data "aws_iam_policy_document" "instance_manager_policy" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateSecurityGroup"
    ]
  }

  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:PutRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:ListRoles",
      "iam:GetPolicy",
      "iam:GetInstanceProfile",
      "iam:GetPolicyVersion",
      "iam:AttachRolePolicy",
      "iam:PassRole"
    ]
  }

  statement {
    sid    = "3"
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:CreateService",
      "ecs:UpdateService",
      "ecs:DeleteService"
    ]
    resources = [ "*" ]
  }

  statement {
    sid    = "4"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [ "*" ]
  }

  statement {
    sid    = "5"
    effect = "Allow"
    actions = [
      "servicediscovery:CreateService"
    ]
    resources = [ "*" ]
  }

  statement {
    sid    = "6"
    effect = "Allow"
    actions = ["s3:*"]
    resources = [
      module.state_bucket.s3_bucket_arn,
      "${module.state_bucket.s3_bucket_arn}/*"
    ]
  }
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
    Name = "securitygroup_for_instance_mgr"
  }
}