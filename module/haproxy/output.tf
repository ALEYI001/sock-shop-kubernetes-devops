output "haproxy_private_ips" {
  value = aws_instance.haproxy[*].private_ip
}
