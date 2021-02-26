output "task_def_arn" {
  description = "ARN for the task def which is used to create/destroy instances"
  value = aws_ecs_task_definition.task.arn
}

output "security_group_id" {
  description = "ID for security group which allows network egress"
  value = aws_security_group.allow_egress_to_world.id
}