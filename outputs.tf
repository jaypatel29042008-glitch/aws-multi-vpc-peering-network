output "bastion_public_ip" {
  value       = aws_instance.ec2_bastion.public_ip
  description = "Public IP of Bastion Jump Host"
}

output "app_server_private_ip" {
  value       = aws_instance.ec2_app.private_ip
  description = "Private IP of Internal App Server"
}

output "target_server_private_ip" {
  value       = aws_instance.ec2_target.private_ip
  description = "Private IP of Target Server in VPC 2"
}

output "vpc_peering_id" {
  value       = aws_vpc_peering_connection.peering.id
  description = "VPC Peering Connection ID"
}
