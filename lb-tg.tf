# Load Balancer configuration for Instances
resource "aws_lb" "instance-lb" {
  name                      = "instance-lb"
  internal                  = false
  load_balancer_type        = "application"
  ip_address_type           = "ipv4"
  security_groups           = [aws_security_group.instance-sg.id]
  subnets                   = data.aws_subnets.subnets.ids

  enable_deletion_protection = false

  tags = {
    Environment = "Terra-LoadBalancer"
  }
}

# Create a target group for EC2 Instances
resource "aws_lb_target_group" "instance-tg" {
  name     = "instance-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    matcher             = "200-399"
    path                = "/health"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
  }
}

# Attach Nginx Instance to a Target group
resource "aws_lb_target_group_attachment" "instance-tg-attach-nginx" {
  target_group_arn = aws_lb_target_group.instance-tg.arn
  target_id        = aws_instance.nginx-server.id
  port             = 80
}

# Attach Apache Instance to a Target group
resource "aws_lb_target_group_attachment" "instance-tg-attach-apache" {
  target_group_arn = aws_lb_target_group.instance-tg.arn
  target_id        = aws_instance.apache-server.id
  port             = 80
}

# Create Load Balancer Listener to listen to the forwarded traffic from LoadBalancer 
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.instance-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance-tg.arn
  }
}