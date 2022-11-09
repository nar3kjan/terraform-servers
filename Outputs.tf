output "elb-id" {
  value = aws_lb.web.id
}

output "elb_zone_id" {
  value = aws_lb.web.zone_id
}

output "elb_dns_name" {
  value = aws_lb.web.dns_name
}