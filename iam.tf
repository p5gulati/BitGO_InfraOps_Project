resource "aws_iam_role" "ecs-execution-role" {
  name = "bitgo-execution-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name    = "bitgo-execution-role"
    Project = "bitgo-infra"
  }
}

resource "aws_iam_role_policy_attachment" "ecs-execution-role-policy" {
  role       = aws_iam_role.ecs-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs-tasks-role" {
    name = "bitgo-task-role"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name    = "bitgo-tasks-role"
    Project = "bitgo-infra"
  }
}

resource "aws_iam_role" "fis" {
  name = "bitgo-fis-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "fis.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name    = "bitgo-fis-role"
    Project = "bitgo-infra"
  }
}

resource "aws_iam_role_policy" "fis" {
  name = "bitgo-fis-policy"
  role = aws_iam_role.fis.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecs:StopTask",
        "ecs:DescribeTasks"
      ]
      Resource = "*"
    }]
  })
}
