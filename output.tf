output "nginx-server"{
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.nginx-server.public_ip
}

output "apache-server" {
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.apache-server.public_ip
}

output "load_balancer_dns_name" {
  description = "Load Balancer DNS namme"
  value = aws_lb.instance-lb.dns_name
}

output "aws_subnets_ids" {
  description = "List of subnets in the VPC"
  value = data.aws_subnets.subnets.ids
}