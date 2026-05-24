resource "aws_fis_experiment_template" "ecs-disrupt" {
  description = "takes down 1 ecs task to replicate real world scenario in case of severe user spike."
  role_arn    = aws_iam_role.fis.arn

  stop_condition {
    source = "aws:cloudwatch:alarm"
    value  = aws_cloudwatch_metric_alarm.cloudwatch-alarm.arn
  }

  target {
    name           = "ecs-tasks"
    resource_type  = "aws:ecs:task"
    selection_mode = "COUNT(1)"
    resource_arns  = [aws_ecs_cluster.ecs_cluster.arn]
  }

  action {
  name      = "stop-ecs-task"
  action_id = "aws:ecs:stop-task"

  target {
    key   = "Tasks"
    value = "ecs-tasks"
  }
}

  tags = {
    Name    = "bitgo-fis-experiment"
    Project = "bitgo-infra"
  }
}