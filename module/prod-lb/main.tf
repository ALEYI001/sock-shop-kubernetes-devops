
# Create application load balancer
resource "aws_lb" "prod_alb" {
  name               = "${var.name}-prod-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.prod_alb_sg.id]
  subnets            = var.public_subnets
  enable_deletion_protection = false
  tags = {
    Name = "${var.name}-prod-alb"
  }
}
# Security Group for the application Load Balancer
resource "aws_security_group" "prod_alb_sg" {
  name        = "${var.name}-prod-alb-sg"
  description = "Allow inbound HTTP and HTTPS traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 30002
    to_port     = 30002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow HTTPS
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # outbound allowed
  }

  tags = {
    Name = "${var.name}-prod-alb-sg"
  }
}

# Target Group for ALB 
resource "aws_lb_target_group" "prod_atg" {
  name     = "${var.name}-prod-atg"
  port     = 30002
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "30002"
    interval            = 30 
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
  tags = {
    Name = "${var.name}-atg"
  }
}
# HTTP Listener
resource "aws_lb_listener" "prod_https_listener" {
  load_balancer_arn = aws_lb.prod_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.acm-cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_atg.arn
  }
}

