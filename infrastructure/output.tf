# output.tf

# Output for static website instance
output "fast_api_website_instance_public_ip" {
  value = aws_instance.fast_api_website_instance.public_ip
}



