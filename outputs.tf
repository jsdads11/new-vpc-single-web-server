output "instance_public_ip" {
  #value = "ssh -i ${var.keyname} ${var.sshuser}@${aws_instance.example.public_ip}"
  value = "ssh -i ${var.keyname} ubuntu@${aws_instance.example.public_ip}"
  description = "The IP address used to connect to the public Bastion instance"
}

output "public_ip" {
  value       = "curl http://${aws_instance.example.public_ip}:8080"
  description = "The public IP of the web server"
}

output "route_table" {
  value       = "aws_route_table.my_vpc_eu_west_1a_public.id"
  description = "The route table identifier"
}

