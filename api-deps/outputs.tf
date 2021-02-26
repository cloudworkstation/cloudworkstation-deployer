output "task_def_arn" {
  description = "ARN for the task def which is used to create/destroy instances"
  value = aws_ecs_task_definition.task.arn
}