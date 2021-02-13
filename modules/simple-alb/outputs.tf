output "alb_sec_group" {
  description = "ID for the security group which protects the ALB"
  value = aws_security_group.allow_tls_from_world.id
}

output "listener_arn" {
  description = "ARN for the ALB listener which is created"
  value = aws_lb_listener.alb_listener.arn
}