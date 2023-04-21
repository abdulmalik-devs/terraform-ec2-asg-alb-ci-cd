output "nginx-server"{
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.nginx-server.public_ip
}

output "apache-server" {
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.apache-server.public_ip
}

output "load_balancer_dns_name" {
  value = aws_lb.instance-lb.dns_name
}

output "aws_subnets_ids" {
  value = data.aws_subnets.subnets.ids
}