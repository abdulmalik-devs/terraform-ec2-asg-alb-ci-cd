output "nginx-server"{
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.nginx-server.public_ip
}

output "apache-server" {
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.apache-server.public_ip
}