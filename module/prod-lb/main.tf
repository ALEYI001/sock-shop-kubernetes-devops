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
  name        = "${var.name}-prod-lb-sg"
  description = "Security group forprod ALB"
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
    Name = "${var.name}-prod-lb-sg"
  }
}

# ALB- prod app lb
resource "aws_lb" "prod" {
  name                       = "${var.name}-prod-alb"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_sg.id]
  subnets                    = var.subnets
  enable_deletion_protection = false
  tags = {
    Name = "${var.name}-prod-alb"
  }
}


# Target Groups (prod)
resource "aws_lb_target_group" "prod" {
  name        = "${var.name}-prod-tg"
  port        = 30001
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
    port                = "30001"
  }

  tags = {
    Name = "${var.name}-prod-tg"
  }
}



# Target Attachments
# prod attachments (distributes across multiple instances)
resource "aws_lb_target_group_attachment" "prod" {
  count            = length(var.worker_instance_ids)
  target_group_arn = aws_lb_target_group.prod.arn
  target_id        = var.worker_instance_ids[count.index]
  port             = 30001
}



# Listeners (HTTP redirect, HTTPS forward) HTTP 80 -> HTTPS 443 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prod.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod.arn
  }
}

# HTTPS 443 (forwards by listener rules below)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.prod.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod.arn
  }
}

# Route53 records
resource "aws_route53_record" "prod" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "prod.${var.domain_name}"
  type    = "A"
  # description: Alias record to ALB for prod
  alias {
    name                   = aws_lb.prod.dns_name
    zone_id                = aws_lb.prod.zone_id
    evaluate_target_health = true
  }
}