resource "aws_lb" "main" {
    name = "load-balancer"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb.id]
    subnets = [aws_subnet.az-1.id, aws_subnet.az-2.id]
    enable_deletion_protection = false

    tags = {
    Name    = "bitgo-alb"
    Project = "bitgo-infra"
  }
}

resource "aws_lb_target_group" "main" {
  name        = "tf-lb-alb-tg"
  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id

  health_check {
    matcher = "200"
    path = "/health"
    protocol = "HTTP"
    interval = 15
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "bitgo-alb-target"
    Project = "bitgo-infra"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = aws_acm_certificate_validation.main.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code  = "HTTP_301"
    }
  }
}