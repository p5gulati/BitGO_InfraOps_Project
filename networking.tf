resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "bitgo-vpc"
    Project = "bitgo-infra"
  }
}

resource "aws_subnet" "az-1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "bitgo-subnet1"
    Project = "bitgo-infra"
  }

}

resource "aws_subnet" "az-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "bitgo-subnet2"
    Project = "bitgo-infra"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gw"
    Project = "bitgo-infra"
  }
}

resource "aws_route_table" "route-table" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
        Name    = "bitgo-public-rt"
        Project = "bitgo-infra"
    }
}

resource "aws_route_table_association" "association-subnet1" {
  subnet_id      = aws_subnet.az-1.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_route_table_association" "association-subnet2" {
  subnet_id      = aws_subnet.az-2.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_security_group" "alb" {
  name        = "bitgo-alb-sg"
  description = "Security group for the ALB - allows HTTP and HTTPS from internet"
  vpc_id      = aws_vpc.main.id

  tags = {
  Name    = "bitgo-alb-sg"
  Project = "bitgo-infra"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "ecs" {
  name        = "bitgo-ecs-sg"
  description = "Security group for ECS tasks - only accepts traffic from ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name    = "bitgo-ecs-sg"
    Project = "bitgo-infra"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_egress" {
  security_group_id = aws_security_group.ecs.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}