# Create an Auto scaling group for spin up required instances
resource "aws_autoscaling_group" "instance-asg" {
  name                      = "instance-asg"
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.instance-tg.arn]
  vpc_zone_identifier       = aws_lb.instance-lb.subnets

  launch_template {
    id      = aws_launch_template.nginx-temp.id
    version = "$Latest"
  }
}

# Create a launch template for Nginx Server
resource "aws_launch_template" "nginx-temp" {
  name_prefix   = "nginx-temp"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.instance-sg.id]
  user_data              = base64encode(data.template_file.apache-data-script.rendered)

   tag_specifications {
    resource_type = "instance"
    tags = {
      Name : "nginx-temp"
    }
  }
}

# Create a launch template for Apache Server
resource "aws_launch_template" "apache-temp" {
  name_prefix            = "apache-temp"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.instance-sg.id]
  user_data              = base64encode(data.template_file.nginx-data-script.rendered)

   tag_specifications {
    resource_type = "instance"
    tags = {
      Name : "apache-temp"
    }
  }
}

data "template_file" "apache-data-script" {
  template = file("./user-data-apache.tpl")
  vars = {
    server = "apache"
  }
}

data "template_file" "nginx-data-script" {
  template = file("./user-data-nginx.tpl")
  vars = {
    server = "nginx"
  }
}

