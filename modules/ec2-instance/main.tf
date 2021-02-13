/*provider "aws" {
  region = var.aws_region
}*/

resource "random_string" "random_secret" {
  length = 8
  special = false
}

resource "random_shuffle" "subnet" {
  input = var.subnets
  result_count = 1
}

resource "aws_security_group" "allow_egress_to_world" {
  name_prefix = "desktop-${var.desktop_id}"
  description = "Allow outbound to world"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "desktop_${var.desktop_id}_to_world"
  }
}

resource "aws_instance" "desktop" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = random_shuffle.subnet.result[0]
  associate_public_ip_address = false
  vpc_security_group_ids       = concat([
                                    aws_security_group.allow_egress_to_world.id
                                  ], var.security_groups)

  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
  }

  /*
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]
  */

  user_data_base64 = base64encode(var.user_data)

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name           = "desktop-${var.desktop_id}"
    VncPassword    = random_string.random_secret.result
    ScreenGeometry = var.screen_geometry
    Username       = var.username
  }
}

data "aws_iam_policy_document" "tag_reading_policy" {
  statement {
    sid = "1"

    actions = [
      "ec2:DescribeTags"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "tag_reading_policy" {
  policy = data.aws_iam_policy_document.tag_reading_policy.json
}

resource "aws_iam_role" "ecs_instance_role" {
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_ecs_service_policy" {
  role        = aws_iam_role.ecs_instance_role.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "attach_tag_reading_policy" {
  role        = aws_iam_role.ecs_instance_role.name
  policy_arn  = aws_iam_policy.tag_reading_policy.arn
}

resource "aws_iam_role_policy_attachment" "user_policies" {
  count       = length(var.additional_instance_role_policies)

  role        = aws_iam_role.ecs_instance_role.name
  policy_arn  = element(var.additional_instance_role_policies, count.index)
}

resource "aws_iam_instance_profile" "instance_profile" {
  role = aws_iam_role.ecs_instance_role.name
}