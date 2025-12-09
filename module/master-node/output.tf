
output "master_node_instance_ip" {
  description = "IDs of the Kubernetes master node instances"
  value       = aws_instance.master_nodes[*].private_ip
}
