# Provider showing the region to provision your resources
provider "aws" {
  region = "us-east-1"
}

# An AMI information for the EC2 Instance to be Created
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

terraform {
  backend "s3" {
    bucket = "terra-file"
    key    = "tf-statefile/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "nginx-server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  user_data     = file("user-data-nginx.tpl")

  tags = {
    Name = "nginx-server"
  }
}

resource "aws_instance" "apache-server" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  key_name      = var.key_name
  user_data     = file("user-data-apache.tpl")

  tags = {
    Name = "apache-server"
  }
}

resource "aws_default_vpc" "default" {}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpc.default_vpc.id
  }
}

resource "aws_security_group" "instance-sg" {
  name        = "instance-sg"
  description = "SSH on port 22 and HTTP on port 80"
  vpc_id      = [aws_default_vpc.default.id]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# ---------------------------------------------------------------------------------------

# Create a target group for EC2 Instances
resource "aws_lb_target_group" "instance-tg" {
  name     = "instance-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    matcher             = 200
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 60
  }
}

# Attach EC2 Instance to a Target group
resource "aws_lb_target_group_attachment" "instance-tg-attach" {
  target_group_arn = aws_lb_target_group.instance-tg.arn
  target_id        = aws_instance.nginx-server.id
  port             = 80
}

resource "aws_lb" "instance-lb" {
  name                      = "instance-lb"
  internal                  = false
  load_balancer_type        = "application"
  security_groups           = [aws_security_group.instance-sg.id]
  subnets                   = data.aws_subnets.subnets.ids
  idle_timeout              = 400

  enable_deletion_protection = true

  tags = {
    Environment = "Terra-LoadBalancer"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.instance-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance-tg.arn
  }
}

resource "aws_launch_template" "instance-temp" {
  name_prefix   = "instance-temp"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "instance-asg" {
  name                      = "instance-asg"
  availability_zones        = ["us-east-1a"]
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true

  launch_template {
    id      = aws_launch_template.instance-temp.id
    version = "$Latest"
  }
}

