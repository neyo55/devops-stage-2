

---

# Dockerized Full Stack Web Application Deployment

## Table of Contents
- [Dockerized Full Stack Web Application Deployment](#dockerized-full-stack-web-application-deployment)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Terraform Setup](#terraform-setup)
    - [Provider Configuration](#provider-configuration)
      - [This is the provider configuration file to declare the region and the profile to use.](#this-is-the-provider-configuration-file-to-declare-the-region-and-the-profile-to-use)
    - [Network Configuration](#network-configuration)
      - [This is file that contains the vpc, subnet, internet gateway, and route table setup.](#this-is-file-that-contains-the-vpc-subnet-internet-gateway-and-route-table-setup)
    - [Instance Setup](#instance-setup)
      - [This is the file that declares the instance setup details and user data for the 'install.sh' file](#this-is-the-file-that-declares-the-instance-setup-details-and-user-data-for-the-installsh-file)
    - [Key Pair Configuration](#key-pair-configuration)
      - [This file contains the key pair setup details and export the copy of the keypair to a directory in the root folder named 'file' for ssh access to the instance.](#this-file-contains-the-key-pair-setup-details-and-export-the-copy-of-the-keypair-to-a-directory-in-the-root-folder-named-file-for-ssh-access-to-the-instance)
    - [Security Group Configuration](#security-group-configuration)
      - [This is the file that contains the security group setup details for the network.](#this-is-the-file-that-contains-the-security-group-setup-details-for-the-network)
    - [Variables](#variables)
      - [This file contains the variables that are used in the other files to make the infrastructure setup adjustable.](#this-file-contains-the-variables-that-are-used-in-the-other-files-to-make-the-infrastructure-setup-adjustable)
      - [This is the .tfvars file that contains the values for the variables declared in the variables.tf file](#this-is-the-tfvars-file-that-contains-the-values-for-the-variables-declared-in-the-variablestf-file)
    - [Outputs](#outputs)
      - [This output file displays the public IP of the instance after the terraform configuration has been applied.](#this-output-file-displays-the-public-ip-of-the-instance-after-the-terraform-configuration-has-been-applied)
    - [Details of Installation Script](#details-of-installation-script)
    - [The final part of the infrastructure setup](#the-final-part-of-the-infrastructure-setup)
    - [Application Setup](#application-setup)
    - [Continue to the readme of the root directory of fastapi-project directory](#continue-to-the-readme-of-the-root-directory-of-fastapi-project-directory)

## Overview
This project involves deploying a full-stack web application using Docker containers. The infrastructure is provisioned on AWS using Terraform, and the application is deployed on an Ubuntu EC2 instance. The project includes setting up the necessary network configurations, creating a key pair, defining security groups, and installing Docker and Docker Compose on the EC2 instance using the bash script file attached to this setup.

## Terraform Setup

### Provider Configuration

#### This is the provider configuration file to declare the region and the profile to use.
**provider.tf**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "default"
}
```

### Network Configuration

#### This is file that contains the vpc, subnet, internet gateway, and route table setup.
**network.tf**
```hcl
resource "aws_vpc" "fast_api_website_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.project_name}_vpc"
  }
}

resource "aws_subnet" "fast_api_website_subnet" {
  vpc_id                  = aws_vpc.fast_api_website_vpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}_subnet"
  }
}

resource "aws_internet_gateway" "fast_api_website_igw" {
  vpc_id = aws_vpc.fast_api_website_vpc.id

  tags = {
    Name = "${var.project_name}_internet_gateway"
  }
}

resource "aws_route_table" "fast_api_website_route_table" {
  vpc_id = aws_vpc.fast_api_website_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fast_api_website_igw.id
  }

  tags = {
    Name = "${var.project_name}_route_table"
  }
}

resource "aws_route_table_association" "static_website_route_table_association" {
  subnet_id      = aws_subnet.fast_api_website_subnet.id
  route_table_id = aws_route_table.fast_api_website_route_table.id
}
```

### Instance Setup

#### This is the file that declares the instance setup details and user data for the 'install.sh' file
**instance.tf**
```hcl
data "aws_ami" "fast_api_website" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

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
```

### Key Pair Configuration

#### This file contains the key pair setup details and export the copy of the keypair to a directory in the root folder named 'file' for ssh access to the instance.
**keypair.tf**
```hcl
resource "local_file" "private_key" {
  content  = tls_private_key.my_private_key.private_key_pem
  filename = "${path.module}/file/fastapi-key.pem"
}

resource "aws_key_pair" "fast_api_website_keypair" {
  key_name   = var.fast_api_website_keypair_name
  public_key = tls_private_key.my_private_key.public_key_openssh
}

resource "tls_private_key" "my_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
```

### Security Group Configuration

#### This is the file that contains the security group setup details for the network.
**security-group.tf**
```hcl
resource "aws_security_group" "fast_api_website_security_group" {
  name        = "static_website_security_group"
  description = "Allow traffic"
  vpc_id      = aws_vpc.fast_api_website_vpc.id

  ingress {
    description = "WEBSITE_SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WEBSITE_HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WEBSITE_HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WEBSITE_HTTP"
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WEBSITE_HTTP"
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WEBSITE_HTTP"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WEBSITE_HTTP"
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WEBSITE_HTTP"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WEBSITE_HTTP"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WEBSITE_HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}_security_group"
  }
}
```

### Variables

#### This file contains the variables that are used in the other files to make the infrastructure setup adjustable.
**variables.tf**
```hcl
variable "region" {}

variable "project_name" {}

variable "vpc_cidr_block" {}

variable "subnet_cidr_block" {}

variable "availability_zone" {}

variable "fast_api_website_keypair_name" {}

variable "instance_type_fast_api_website" {}
```
#### This is the .tfvars file that contains the values for the variables declared in the variables.tf file
**terraform.tfvars**
```hcl
region = "eu-west-1"
project_name = "Full_Stack_FastAPI_Project"
vpc_cidr_block = "10.0.0.0/16"
subnet_cidr_block = "10.0.1.0/24"
availability_zone = "eu-west-1a"
fast_api_website_keypair_name = "fastapi-key"
instance_type_fast_api_website = "t2.medium"
```

### Outputs

#### This output file displays the public IP of the instance after the terraform configuration has been applied.
**output.tf**
```hcl
output "fast_api_website_instance_public_ip" {
  value = aws_instance.fast_api_website_instance.public_ip
}
```

### Details of Installation Script 

**install.sh**
```bash
#!/bin/bash

# install.sh

set -e  # Exit the script if any command fails

LOGFILE="/home/ubuntu/fastapi-project/setup.log"
exec > >(tee -a "$LOGFILE") 2>&1  # Redirect stdout and stderr to the log file

# Ensure the log directory exists
sudo mkdir -p /home/ubuntu/fastapi-project
sudo chown -R ubuntu:ubuntu /home/ubuntu/fastapi-project

# Update package information and install required packages
echo "Updating package information..."
sudo apt-get update

echo "Installing required packages..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Create a docker user, add to sudoers, create docker group, and set up permissions
echo "Creating docker user and adding to groups..."
sudo useradd -m docker
sudo usermod -aG sudo docker
sudo groupadd docker || true
sudo usermod -aG docker docker

# Add Docker’s official GPG key
echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo "Setting up Docker stable repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
echo "Installing Docker Engine..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Verify Docker installation
echo "Verifying Docker installation..."
sudo docker run hello-world || { echo "Docker installation failed"; exit 1; }

# Install Docker Compose
echo "Installing Docker Compose..."
sudo rm /usr/local/bin/docker-compose || true  # Remove existing binary if needed
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
echo "Verifying Docker Compose installation..."
docker-compose --version || { echo "Docker Compose installation failed"; exit 1; }

# Install Git
echo "Installing Git..."
sudo apt-get install -y git

# Verify Git installation
echo "Verifying Git installation..."
git --version || { echo "Git installation failed"; exit 1; }

echo "Setup script completed successfully!"
```
### The final part of the infrastructure setup

After all files are configured or adjusted proparly, run the following commands to apply the configuration to the AWS cloud:

```bash
terraform init
terraform validate
terraform plan
terraform apply --auto-approve
```
Copy the public IP address of the instance that was outputed and 'cd' to the directory named 'file' for ssh access to the instance and remember to give the keypair permission to access the instance before using the ssh command.

```bash
chmod 400 fastapi-key.pem
```
```bash
ssh -i fastapi-key.pem ubuntu@<instance-public-ip>
```

### Application Setup
Once the infrastructure is ready, change directory to the fastapi-project directory to set up and run the application:

```bash
cd /fastapi-project
```

### Continue to the readme of the root directory of fastapi-project directory
