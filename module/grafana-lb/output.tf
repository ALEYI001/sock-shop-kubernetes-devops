# Optional: Output the DNS name of the Load Balancer for easy access
output "grafana_alb_dns_name" {
  description = "The DNS name of the Grafana Application Load Balancer."
  value       = aws_lb.grafana_alb.dns_name
}

