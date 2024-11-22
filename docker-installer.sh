#!/bin/bash

# Exit on any error
set -e

# Function to print messages
print_message() {
    echo "----------------------------------------"
    echo "$1"
    echo "----------------------------------------"
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Install Docker and Docker Compose
install_docker() {
    print_message "Updating package list and installing prerequisites..."
    apt update
    apt install -y apt-transport-https ca-certificates curl gnupg

    print_message "Adding Docker's official GPG key..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    print_message "Adding Docker repository..."
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

    print_message "Updating package list and installing Docker..."
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    print_message "Starting and enabling Docker service..."
    systemctl start docker
    systemctl enable docker
}

# Main installation process
print_message "Starting Docker installation..."

# Perform installation
install_docker

# Verify installation
print_message "Verifying installation..."
docker --version
docker compose version

print_message "Docker installation completed successfully!"
print_message "You can run 'docker run hello-world' to test the installation"

# Optional: Add current user to docker group
read -p "Do you want to add current user to the docker group? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    USER=$(logname)
    usermod -aG docker $USER
    print_message "Added $USER to docker group. Please log out and back in for this to take effect."
fi