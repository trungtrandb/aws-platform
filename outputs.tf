output "ec2_public_ips" {
  value = aws_instance.public[*].public_ip
}

output "nlb_dns_name" {
  value = aws_lb.main.dns_name
}

output "k3s_api_endpoint" {
  value = "https://${aws_lb.main.dns_name}:6443"
}

output "kafka_bootstrap_endpoint" {
  value = "${aws_lb.main.dns_name}:9094"
}

output "kafka_broker_endpoints" {
  value = [
    "${aws_lb.main.dns_name}:9094",
    "${aws_lb.main.dns_name}:9095",
    "${aws_lb.main.dns_name}:9096"
  ]
}