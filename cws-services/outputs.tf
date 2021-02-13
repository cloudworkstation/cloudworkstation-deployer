output "router_security_group" {
  description = "ID of the security group created for router to desktop traffic"
  value = module.allow_p8080.group_id
}