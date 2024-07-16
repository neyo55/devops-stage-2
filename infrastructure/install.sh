#!/bin/bash

# install.sh

set -e  # Exit the script if any command fails

LOGFILE="/home/ubuntu/hng-devops-project/setup.log"
exec > >(tee -a "$LOGFILE") 2>&1  # Redirect stdout and stderr to the log file

# Ensure the log directory exists
sudo mkdir -p /home/ubuntu/hng-devops-project
sudo chown -R ubuntu:ubuntu /home/ubuntu/hng-devops-project

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

# # Install PostgreSQL
# echo "Installing PostgreSQL..."
# sudo apt-get install -y postgresql postgresql-contrib

# # Start PostgreSQL service
# echo "Starting PostgreSQL service..."
# sudo systemctl start postgresql
# sudo systemctl enable postgresql

# # Set up PostgreSQL user and database
# echo "Setting up PostgreSQL user and database..."
# sudo -u postgres psql -c "CREATE USER neyo55 WITH PASSWORD 'app00321';"
# sudo -u postgres psql -c "CREATE DATABASE neyo_db OWNER neyo55;"
# sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE neyo_db TO neyo55;"

# # Install NVM (Node Version Manager)
# echo "Installing NVM..."
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
# export NVM_DIR="$HOME/.nvm"

# # shellcheck disable=SC1090
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# # Install specific Node.js and npm versions
# echo "Installing Node.js v20.5.0 and npm v10.8.1..."
# nvm install 20.5.0
# nvm use 20.5.0
# npm install -g npm@10.8.1

# # Verify Node.js and npm installation
# echo "Verifying Node.js and npm installation..."
# node -v || { echo "Node.js installation failed"; exit 1; }
# npm -v || { echo "npm installation failed"; exit 1; }

# # Remove old Poetry if exists
# echo "Removing old Poetry installation if exists..."
# sudo apt-get remove --purge -y poetry || true

# # Install Poetry using the recommended installer
# echo "Installing Poetry..."
# curl -sSL https://install.python-poetry.org | python3 -

# # Add Poetry to PATH
# echo "Adding Poetry to PATH..."
# echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
# source ~/.bashrc

# # Verify Poetry installation
# echo "Verifying Poetry installation..."
# poetry --version || { echo "Poetry installation failed"; exit 1; }

# # Install project dependencies using Poetry
# echo "Installing Poetry dependencies..."
# sudo apt install -y python3-poetry

echo "Setup script completed successfully!"




















# #!/usr/bin/env bash

# # Update package information, ensure that APT works with the https method, and that CA certificates are installed.
# sudo apt-get update
# sudo apt-get install -y \
#     ca-certificates \
#     curl \
#     gnupg \
#     lsb-release \
#     software-properties-common

# # Install NGINX
# # sudo apt-get install -y nginx

# # Add Docker’s official GPG key.
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# # Set up the stable repository.
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# # Install Docker Engine.
# sudo apt-get update
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# # Verify Docker installation.
# sudo docker run hello-world

# # Create docker group
# sudo groupadd docker

# # Create docker user
# #sudo useradd -m docker

# # Add Docker user to sudo group
# sudo usermod -aG docker $USER

# # Install Docker Compose
# sudo rm /usr/local/bin/docker-compose  # Remove existing binary if needed
# sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose

# # Verify Docker Compose installation.
# docker-compose --version

# # Install Git
# sudo apt-get install -y git

# # Verify Git installation
# git --version


# # Install PostgreSQL
# sudo apt-get install -y postgresql postgresql-contrib

# # Start PostgreSQL service
# sudo systemctl start postgresql
# sudo systemctl enable postgresql

# # Set up PostgreSQL user and database
# sudo -u postgres psql -c "CREATE USER neyo55 WITH PASSWORD 'app00321';"
# sudo -u postgres psql -c "CREATE DATABASE neyo_db OWNER neyo;"
# sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE neyo_db TO neyo;"

# # Install Node.js and npm
# curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
# sudo apt-get install -y nodejs

# # Verify Node.js and npm installation
# node -v
# npm -v

# node -v
# npm -v
# v20.5.0
# 10.8.1


# # Remove old Poetry if exists
# sudo apt-get remove --purge -y poetry

# # Install Poetry using the recommended installer
# curl -sSL https://install.python-poetry.org | python3 -

# # Add Poetry to PATH
# echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc


# # Specify the location of the source file
# # shellcheck source=/home/ubuntu/.bashrc
# source ~/.bashrc

# # Verify Poetry installation
# poetry --version

# # Install project dependencies using Poetry
# sudo apt install python3-poetry

# # Install dependencies using poetry
# poetry install

# # Create directory on ubuntu/home
# mkdir -p /home/ubuntu/hng-devops-project

# # Chnage the ownership of the directory
# sudo chown -R ubuntu:ubuntu /home/ubuntu/hng-devops-project
























# #!/usr/bin/env bash

# ###########################################################
# # This script automates the setup of dependencies for     #
# # the HNG DevOps project, including Docker, PostgreSQL,   #
# # Node.js, npm, Poetry, and project directory setup.      #
# ###########################################################

# set -euo pipefail

# # Function to log messages
# log() {
#     echo "$(date +'%Y-%m-%d %H:%M:%S') - $*"
# }

# # Function to log errors
# log_error() {
#     echo "$(date +'%Y-%m-%d %H:%M:%S') - ERROR: $*" >&2
# }

# # Error handling trap
# trap 'log_error "Error occurred at line $LINENO"; exit 1' ERR

# # Update package information, ensure that APT works with the https method, and that CA certificates are installed.
# log "Updating package information and installing essential packages"
# sudo apt-get update
# sudo apt-get install -y \
#     ca-certificates \
#     curl \
#     gnupg \
#     lsb-release \
#     software-properties-common

# # Install Docker
# log "Installing Docker Engine and Docker Compose"
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# # Verify Docker installation
# sudo docker run hello-world

# # Add current user to the docker group
# log "Adding current user to the Docker group"
# sudo groupadd docker  # Create docker group if it doesn't exist
# sudo usermod -aG docker $USER

# # Install Docker Compose
# sudo rm -f /usr/local/bin/docker-compose  # Remove existing binary if needed
# sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose

# # Verify Docker Compose installation
# docker-compose --version

# # Install Git
# log "Installing Git"
# sudo apt-get install -y git

# # Verify Git installation
# git --version

# # Install PostgreSQL
# log "Installing PostgreSQL"
# sudo apt-get install -y postgresql postgresql-contrib

# # Start PostgreSQL service
# log "Starting PostgreSQL service"
# sudo systemctl start postgresql
# sudo systemctl enable postgresql

# # Set up PostgreSQL user and database
# log "Setting up PostgreSQL user and database"
# sudo -u postgres psql -c "CREATE USER neyo55 WITH PASSWORD 'app00321';"
# sudo -u postgres psql -c "CREATE DATABASE neyo_db OWNER neyo55;"
# sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE neyo_db TO neyo55;"

# # Install Node.js and npm
# log "Installing Node.js and npm"
# curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
# sudo apt-get install -y nodejs

# # Verify Node.js and npm installation
# node -v
# npm -v

# # Install Poetry
# log "Installing Poetry"
# curl -sSL https://install.python-poetry.org | python3 -

# # Add Poetry to PATH
# echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
# source ~/.bashrc

# # Verify Poetry installation
# poetry --version

# # Install project dependencies using Poetry
# log "Installing project dependencies using Poetry"
# poetry install

# # Create project directory
# log "Creating project directory"
# mkdir -p /home/ubuntu/hng-devops-project

# # Change ownership of the project directory
# log "Changing ownership of the project directory"
# sudo chown -R ubuntu:ubuntu /home/ubuntu/hng-devops-project

# log "Setup script completed successfully!"














