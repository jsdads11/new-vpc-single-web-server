output "public_ip" {
  #value       = aws_instance.example.public_ip
  value       = "curl http://${aws_instance.example.public_ip}:8080"
  description = "The public IP of the web server"
}

