resource "aws_ecr_repository" "docker-app" {
  name         = "bitgo-app"
  force_delete = true

  tags = {
    Name    = "bitgo-app"
    Project = "bitgo-infra"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "bitgo-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "bitgo-cluster"
    Project = "bitgo-infra"
  } 
}

resource "aws_ecs_task_definition" "main" {
  family = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  execution_role_arn = aws_iam_role.ecs-execution-role.arn
  task_role_arn = aws_iam_role.ecs-tasks-role.arn

  container_definitions = jsonencode([
    {
      name      = "bitgo-app"
      image     = "565471248232.dkr.ecr.us-east-1.amazonaws.com/bitgo-app:latest"
      essential = true
      
      portMappings = [
        {
          containerPort = 8080
          protocol = "tcp"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" = "/ecs/bitgo-app"
          "awslogs-region" = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "bitgo-ecs" {
  name = "ecs-service"
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count = 2
  launch_type = "FARGATE"
  depends_on = [aws_lb_listener.https, aws_lb_listener.http]
  network_configuration {
    subnets = [aws_subnet.az-1.id, aws_subnet.az-2.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name = "bitgo-app"
    container_port = 8080
  }
}