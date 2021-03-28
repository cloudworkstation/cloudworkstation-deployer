output "task_def_arn" {
  description = "ARN for the task def which is used to create/destroy instances"
  value = aws_ecs_task_definition.task.arn
}

output "task_name_and_revision" {
  description = "Task name and revision number for the task def which is used to create/destroy instances"
  value = "${aws_ecs_task_definition.task.family}:${aws_ecs_task_definition.task.revision}"
}

output "security_group_id" {
  description = "ID for security group which allows network egress"
  value = aws_security_group.allow_egress_to_world.id
}

output "ec2_state_sns" {
  description = "SNS topic for the EC2 state change notifications"
  value = aws_sns_topic.ec2_state_change_sns.id
}

output "kms_key_id" {
  description = "KMS key used to encrypt SNS and SQS topics"
  value = aws_kms_key.kms_key.id
}