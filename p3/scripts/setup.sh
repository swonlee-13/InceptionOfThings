#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo privileges"
    exit 1
fi

echo "Starting setup..."

# first of all, open /etc/resolv.conf and add "namespace 8.8.8.8" if doesn't exist.
if ! grep -q "^nameserver 8.8.8.8" /etc/resolv.conf; then
  echo "nameserver 8.8.8.8"  >> /etc/resolv.conf
fi

# Exit script on error
set -e

# Update apt packages list
echo "Updating apt packages list..."
sudo apt-get update

# Install ca-certificates and curl for adding Docker's GPG key
echo "Installing ca-certificates and curl..."
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc


# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker Engine, CLI, and plugins
echo "Installing Docker Engine, CLI, and plugins..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to the Docker group
echo "Adding current user to the Docker group..."
sudo usermod -aG docker $USER
echo "NOTE: You will need to log out and back in for this change to take effect."

# Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

# Install for K3D
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# Install for ArgoCD-cli
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/
