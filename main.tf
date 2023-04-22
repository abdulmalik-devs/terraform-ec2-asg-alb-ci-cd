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

# Nginx Server configuration
resource "aws_instance" "nginx-server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  user_data     = file("./user-data-nginx.tpl")
  vpc_security_group_ids = [aws_security_group.instance-sg.id]

  tags = {
    Name = "nginx-server"
  }
}

# Apache Server configuration
resource "aws_instance" "apache-server" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  key_name      = var.key_name
  user_data     = file("./user-data-apache.tpl")
  vpc_security_group_ids = [aws_security_group.instance-sg.id]

  tags = {
    Name = "apache-server"
  }
}

# Data source for aws vpc
data "aws_vpc" "default_vpc" {
  default = true
}

# Data source for subnets
data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# Instance Security group configuration to allow port 80(HTTP), 22(SSH) respectively.
resource "aws_security_group" "instance-sg" {
  name        = "instance-sg"
  description = "SSH on port 22 and HTTP on port 80"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "allow ssh"
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
  }

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "allow http"
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 80
  }

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }
}

