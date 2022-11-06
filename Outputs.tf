output "elb-id" {
  value = aws_elb.web.id
}

output "elb_zone_id" {
  value = aws_elb.web.zone_id
}

output "elb_dns_name" {
  value = aws_elb.web.dns_name
}