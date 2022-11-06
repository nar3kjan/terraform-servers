variable "aws_region" {
  default = "us-east-1"
}

variable "instance_tyoe" {
  default = "t2.micro"
}

variable "common_tags" {
  default = {
    Name = "My Network"
    Owner = "Narek Arakelyan"
    Environment = "Development"
  }
}