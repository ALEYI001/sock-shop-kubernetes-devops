# Data: Route53 zone + ACM certificate
data "aws_route53_zone" "zone" {
  name         = var.domain_name
  private_zone = false
}

# ACM cert must exist in the same region as the ALB
data "aws_acm_certificate" "cert" {
  domain      = var.domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# Security Group for prometheus ALB
resource "aws_security_group" "prometheus_alb_sg" {
  name        = "${var.name}-prometheus-alb-sg"
  description = "Allow HTTP/HTTPS for Prometheus ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
    Name = "${var.name}-prometheus-alb-sg"
  }

}

# Prometheus ALB
resource "aws_lb" "prometheus_alb" {
  name               = "${var.name}-prometheus-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.prometheus_alb_sg.id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.name}-prometheus-alb"
    Env  = "monitoring"
  }
}

# Prometheus TG 
resource "aws_lb_target_group" "prometheus_tg" {
  name     = "${var.name}-prometheus-tg"
  port     = 31090
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    protocol            = "HTTP"
    port                = "31090"  
  }

  tags = {
    Name = "${var.name}-prometheus-tg"
  }
}

# Listener for HTTP
resource "aws_lb_listener" "prometheus_http_listener" {
  load_balancer_arn = aws_lb.prometheus_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus_tg.arn
  }
}

# Listener for HTTPS
resource "aws_lb_listener" "prometheus_https_listener" {
  load_balancer_arn = aws_lb.prometheus_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.prometheus_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus_tg.arn
  }
}

# Attach backend instances to Target Group
resource "aws_lb_target_group_attachment" "prometheus_instances" {
  count            = length(var.prometheus_instance_ids)
  target_group_arn = aws_lb_target_group.prometheus_tg.arn
  target_id        = var.prometheus_instance_ids[count.index]
  port             = 31090
}
