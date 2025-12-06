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

# Security Group for the ALB
resource "aws_security_group" "lb_sg" {
  name        = "${var.name}-prom-lb-sg"
  description = "Security group forprom ALB"
  vpc_id      = var.vpc_id

  # HTTPS
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
    Name = "${var.name}-prom-lb-sg"
  }
}

# ALB- prom app lb
resource "aws_lb" "prom" {
  name                       = "${var.name}-prom-alb"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_sg.id]
  subnets                    = var.subnets
  enable_deletion_protection = false
  tags = {
    Name = "${var.name}-prom-alb"
  }
}


# Target Groups (prom)
resource "aws_lb_target_group" "prom" {
  name        = "${var.name}-prom-tg"
  port        = 31090
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

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
    Name = "${var.name}-prom-tg"
  }
}



# Target Attachments
# prom attachments (distributes across multiple instances)
resource "aws_lb_target_group_attachment" "prom" {
  count            = length(var.worker_instance_ids)
  target_group_arn = aws_lb_target_group.prom.arn
  target_id        = var.worker_instance_ids[count.index]
  port             = 31090
}



# Listeners (HTTP redirect, HTTPS forward) HTTP 80 -> HTTPS 443 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prom.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prom.arn
  }
}

# HTTPS 443 (forwards by listener rules below)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.prom.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prom.arn
  }
}

# Route53 records
resource "aws_route53_record" "prom" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "prom.${var.domain_name}"
  type    = "A"
  # description: Alias record to ALB for prom
  alias {
    name                   = aws_lb.prom.dns_name
    zone_id                = aws_lb.prom.zone_id
    evaluate_target_health = true
  }
}