provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

terraform {
  cloud {
    organization = "nar3kjan"

    workspaces {
      name = "Servers"
    }
  }
}

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "nar3kjan"
    workspaces = {
      name = "GitHub_Actions"
    }
  }
}

data "terraform_remote_state" "route53" {
  backend = "remote"
  config = {
    organization = "nar3kjan"
    workspaces = {
      name = "Route53"
    }
  }
}



#==========================================================================================
/*data "aws_ami" "latest_ubuntu" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
*/

data "aws_ami" "latest_amazon" {
  owners = ["137112412989"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "my_webserver" {
  name        = "Web Server Security Group"
  description = "My First Security Group"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  dynamic "ingress" {
    for_each = ["80", "443", "22"]
    content {
      from_port    = ingress.value
      to_port      = ingress.value
      protocol     = "tcp"
      cidr_blocks  = ["0.0.0.0/0"]

    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
tags = {
      Name = "Security Group Build by Terraform"
      Owner = "Narek Arakelyan"
    } 
}


resource "aws_launch_configuration" "Web" {
  #name = "WebServer-Highly-Available"
  name_prefix = "WebServer-Highly-Available-LC-"
  image_id = data.aws_ami.latest_amazon.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.my_webserver.id]
  user_data = file("user_data.sh")
  key_name = "narek-key.n.virginia"
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name = "ASG-${aws_launch_configuration.Web.name}"
  launch_configuration = aws_launch_configuration.Web.name
  min_size = 2
  max_size = 2
  min_elb_capacity = 2
  vpc_zone_identifier = [data.terraform_remote_state.vpc.outputs.aws_public_subnet1_id, data.terraform_remote_state.vpc.outputs.aws_public_subnet2_id]
  health_check_type = "ELB"
  load_balancers = [aws_elb.web.name]
 
  
  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG"
      Owner  = "Narek Arakelyan"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }


  lifecycle {
    create_before_destroy = true
    }
  }



resource "aws_elb" "web" {
  name = "WebServer-HA-ELB"
  #availability_zones = [data.aws_availability_zones.available.names[0]]
  security_groups = [aws_security_group.my_webserver.id]
  subnets = [data.terraform_remote_state.vpc.outputs.aws_public_subnet1_id, data.terraform_remote_state.vpc.outputs.aws_public_subnet2_id]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }
  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = data.terraform_remote_state.route53.outputs.certificate_id 
  }


  
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 10
  }

  tags = {
    Name = "WebServer-Highly_Available_ELB"
  }
}



resource "aws_elb_listener" "front_end" {
  load_balancer_arn = aws_elb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
