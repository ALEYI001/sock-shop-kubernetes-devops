output "master_node_sg_id" {
  description = "Security group ID for Kubernetes master nodes"
  value       = aws_security_group.master_node_sg.id
}

output "master_node_instance_ip" {
  description = "IDs of the Kubernetes master node instances"
  value       = aws_instance.master_nodes[*].private_ip
}
