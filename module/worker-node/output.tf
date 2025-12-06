# ---Outputs ---
output "worker_instance_ids" {
  description = "IDs of the three worker EC2 instances"
  value       = aws_instance.worker_node[*].id
}