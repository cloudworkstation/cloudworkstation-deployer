/*provider "aws" {
  region = var.aws_region
}*/

data "aws_route53_zone" "root_zone" {
  name         = var.root_domain
  private_zone = false
}

resource "aws_security_group" "allow_tls_from_world" {
  name_prefix = "allow_tls_for_alb"
  description = "Allow TLS inbound traffic"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "lb" {
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [
    aws_security_group.allow_tls_from_world.id
  ]
  subnets             = var.subnets
}

resource "aws_lb_listener" "alb_listener" {

  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.endpoint_cert.arn

  default_action {
    type             = "fixed-response"
    
    fixed_response {
      content_type = "text/plain"
      message_body = "You are in the wrong place"
      status_code  = "404"
    }
  }
}

resource "aws_route53_record" "r53_alb" {
  zone_id = data.aws_route53_zone.root_zone.zone_id
  name    = "${var.hostname}.${var.root_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "endpoint_cert" {
  domain_name       = "${var.hostname}.${var.root_domain}"
  validation_method = "DNS"
}

resource "aws_route53_record" "endpoint_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.endpoint_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.root_zone.id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.endpoint_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.endpoint_cert_validation : record.fqdn]
}
