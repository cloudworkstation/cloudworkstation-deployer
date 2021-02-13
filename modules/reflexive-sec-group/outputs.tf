output "group_id" {
  description = "ID for the security group"
  value = aws_security_group.sec_group.id
}