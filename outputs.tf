output "ec2_public_ips" {
  value = aws_instance.public[*].public_ip
}

output "nlb_dns_name" {
  value = aws_lb.main.dns_name
}

output "kafka_bootstrap_endpoint" {
  value = "${aws_lb.main.dns_name}:9094"
}

output "demo_endpoint" {
  value = "http://${aws_lb.main.dns_name}/api"
}