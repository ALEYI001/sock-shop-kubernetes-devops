#
# AWS Application Load Balancer (ALB) for Grafana
#==============================================================================


# DATA SOURCES (Route 53 Zone and ACM Certificate)
# To fetch the existing Route 53 Hosted Zone
data "aws_route53_zone" "zone" {
  name         = var.domain_name
 private_zone = false 
}

# Data source to fetch the existing ACM Certificate
# ACM cert must exist in the same region as the ALB
data "aws_acm_certificate" "cert" {
  domain = var.domain_name
  statuses = ["ISSUED"]
  most_recent = true
}

# 1. ALB Security Group: Allows inbound HTTP (Port 80) traffic
resource "aws_security_group" "grafana_alb_sg" {
  name        = "-${var.name}-grafana-alb-sg"
  description = "Allows HTTP/HTTPS traffic to the Grafana ALB"
  vpc_id      = var.vpc_id

  # Ingress rule: Allow HTTP from anywhere (for redirects or direct access)
  ingress {
    description = "HTTP access from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Ingress rule: Allow HTTPS from anywhere
  ingress {
    description = "HTTPS access from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Default Egress: allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-grafana-alb-sg-"
  }
}

# 2. Grafana Application Load Balancer (ALB)
resource "aws_lb" "grafana_alb" {
  name               = "${var.name}-grafana-alb"
  internal           = false #Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.grafana_alb_sg.id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.name}-grafana-alb"
  }
}

# 3. Target Group: Defines the backend targets (your Grafana instances)
resource "aws_lb_target_group" "grafana_tg" {
  name     = "${var.name}-grafana-tg"
  port     = 31300
  protocol = "HTTP" # Connection between ALB and Grafana is usually HTTP
  vpc_id   = var.vpc_id
  target_type = "instance"
  
  health_check {
    path = "/" # A common, lightweight check for Grafana
    protocol = "HTTP"
    port = 31300
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 5
    interval = 30
  }

  tags = {
    Name = "${var.name}-grafana-tg"
  }
}

# 4a. Listener: HTTPS (Port 443)
resource "aws_lb_listener" "grafana_https_listener" {
  load_balancer_arn = aws_lb.grafana_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy       = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.grafana_cert.arn #Use the retrieved ACM ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }
}

# 4b. Listener: HTTP (Port 80) for redirecting all traffic to HTTPS
resource "aws_lb_listener" "http_redirect_listener" {
  load_balancer_arn = aws_lb.grafana_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type 		= "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn

    }
  }



# 5. Target Group Attachments: Attaches EC2 instances to the Target Group
resource "aws_lb_target_group_attachment" "grafana_targets" {
  for_each         = toset(var.grafana_instance_ids)
  target_group_arn = aws_lb_target_group.grafana_tg.arn
  target_id        = var.grafana_instance_ids[count.index]
  port             = 31300
}





