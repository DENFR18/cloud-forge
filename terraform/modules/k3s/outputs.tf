output "master_public_ip" {
  description = "Public IP of k3s master node"
  value       = aws_eip.master.public_ip
}

output "master_instance_id" {
  description = "Instance ID of k3s master"
  value       = aws_instance.master.id
}

output "worker_instance_ids" {
  description = "Instance IDs of k3s workers"
  value       = aws_instance.workers[*].id
}
