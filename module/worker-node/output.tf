# ---Outputs ---

output "worker_instance_ids" {
  description = "IDs of the three worker EC2 instances"
  value       = aws_instance.worker_node[*].id
}

output "worker_private_ips" {
  description = "Private IP addresses of the worker nodes (for internal cluster communication)"
  value       = aws_instance.worker_node[*].private_ip
}