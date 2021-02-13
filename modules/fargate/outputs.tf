output "fargate_cluster_id" {
  value = aws_ecs_cluster.cluster.id
  description = "ID for the fargate cluster"
}

output "fargate_cluster_arn" {
  value = aws_ecs_cluster.cluster.arn
  description = "ARN for the fargate cluster"
}