output "app_url" {
  value       = "https://${aws_route53_record.app.name}"
  description = "The HTTPS URL to access the application"
}

output "alb_dns" {
  value       = aws_lb.main.dns_name
  description = "The ALB DNS name"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.docker-app.repository_url
  description = "ECR repository URL"
}

output "cloudwatch_dashboard" {
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
  description = "CloudWatch dashboard URL"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.ecs_cluster.name
  description = "ECS cluster name"
}

output "cloudwatch_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.cloudwatch-alarm.alarm_name
  description = "CloudWatch 5xx alarm name"
}