output "instance_id" {
  value = aws_instance.pulseops_host.id
}

output "public_ip" {
  value = aws_instance.pulseops_host.public_ip
}

output "private_ip" {
  value = aws_instance.pulseops_host.private_ip
}
