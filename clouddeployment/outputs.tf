output "ssh_private_key_pem" {
  sensitive = true
  value     = tls_private_key.ssh.private_key_pem
}

output "ssh_public_key_pem" {
  value = tls_private_key.ssh.public_key_pem
}

output "node_instance_private_ip" {
  value = aws_instance.app_node.private_ip
}

output "nat_gateway_ip" {
  value = aws_eip.nat_gateway[0].public_ip
}

output "jumphost_ip" {
  value = aws_eip.jumphost.public_ip
}
