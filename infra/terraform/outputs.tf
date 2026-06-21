output "control_plane_public_ip" {
  description = "Public IP of the k3s control plane"
  value       = aws_instance.nodes["control-plane"].public_ip
}

output "control_plane_private_ip" {
  description = "Private IP of the k3s control plane"
  value       = aws_instance.nodes["control-plane"].private_ip
}

output "worker_public_ips" {
  description = "Public IPs of the worker nodes"
  value = {
    worker-1 = aws_instance.nodes["worker-1"].public_ip
    worker-2 = aws_instance.nodes["worker-2"].public_ip
  }
}

output "worker_private_ips" {
  description = "Private IPs of the worker nodes"
  value = {
    worker-1 = aws_instance.nodes["worker-1"].private_ip
    worker-2 = aws_instance.nodes["worker-2"].private_ip
  }
}