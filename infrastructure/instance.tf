# instance.tf

# Fetch the latest Ubuntu AMI using a data source
data "aws_ami" "fast_api_website" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# create static website instance 
resource "aws_instance" "fast_api_website_instance" {
  ami             = data.aws_ami.fast_api_website.id
  instance_type   = var.instance_type_fast_api_website
  subnet_id       = aws_subnet.fast_api_website_subnet.id
  key_name        = aws_key_pair.fast_api_website_keypair.key_name
  security_groups = [aws_security_group.fast_api_website_security_group.id]
  depends_on      = [aws_key_pair.fast_api_website_keypair, aws_subnet.fast_api_website_subnet, aws_security_group.fast_api_website_security_group]

  user_data = filebase64("install.sh")

  root_block_device {
    volume_type = "gp2"
    volume_size = 15  
  }


  tags = {
    Name = "${var.project_name}_instance"
  }

}
















