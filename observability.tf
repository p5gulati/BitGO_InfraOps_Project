resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/bitgo-app"
  retention_in_days = 3

  tags = {
    Name    = "bitgo-ecs-logs"
    Project = "bitgo-infra"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch-alarm" {
  alarm_name                = "obs-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "HTTPCode_Target_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 10
  alarm_description         = "This metric monitors load balancer's throughput."
  treat_missing_data = "notBreaching"
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "bitgo-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title   = "Request Count"
          region  = "us-east-1"
          metrics = [["AWS/ApplicationELB", "RequestCount",
                      "LoadBalancer", aws_lb.main.arn_suffix]]
          period  = 60
          stat    = "Sum"
          view    = "timeSeries"
        }
      },
      {
        type = "metric"
        properties = {
          title   = "5XX Errors"
          region  = "us-east-1"
          metrics = [["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count",
                      "LoadBalancer", aws_lb.main.arn_suffix]]
          period  = 60
          stat    = "Sum"
          view    = "timeSeries"
        }
      },
      {
        type = "metric"
        properties = {
          title   = "Target Response Time"
          region  = "us-east-1"
          metrics = [["AWS/ApplicationELB", "TargetResponseTime",
                      "LoadBalancer", aws_lb.main.arn_suffix]]
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
        }
      },
      {
        type = "metric"
        properties = {
          title   = "Running Task Count"
          region  = "us-east-1"
          metrics = [["ECS/ContainerInsights", "RunningTaskCount",
                      "ServiceName", aws_ecs_service.bitgo-ecs.name,
                      "ClusterName", aws_ecs_cluster.ecs_cluster.name]]
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
        }
      }
    ]
  })
}