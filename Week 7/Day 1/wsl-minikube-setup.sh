#!/bin/bash

set -e

echo "========== WSL & Minikube Setup Script =========="
echo "This script will install and configure WSL, Docker, and Minikube"

# Check if running on Windows
# if [[ "$(uname -r)" != *Microsoft* ]] && [[ "$(uname -r)" != *microsoft* ]]; then
#   echo "This script must be run on Windows with WSL support."
#   echo "Please run from Windows PowerShell with Admin privileges:"
#   echo "  1. Open PowerShell as Administrator"
#   echo "  2. Run: wsl --install"
#   echo "  3. Restart your computer"
#   echo "  4. After restart, the WSL installation will complete"
#   echo "  5. Then run this script again within the WSL environment"
#   exit 1
# fi

# Update & upgrade packages
echo "Updating and upgrading packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# Install Docker
echo "Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $USER
  echo "Docker installed successfully. You may need to log out and back in for group changes to take effect."
else
  echo "Docker is already installed."
fi

# Install kubectl
echo "Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
  echo "kubectl installed successfully."
else
  echo "kubectl is already installed."
fi

# Install Minikube
echo "Installing Minikube..."
if ! command -v minikube &> /dev/null; then
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  rm minikube-linux-amd64
  echo "Minikube installed successfully."
else
  echo "Minikube is already installed."
fi

# Start Minikube
echo "Starting Minikube with limited resources to save space..."
minikube start --driver=docker --cpus=2 --memory=2048 --disk-size=10g

# Enable required addons
echo "Enabling Minikube addons..."
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard

# Create a namespace for our applications
echo "Creating kubernetes namespace for SRE applications..."
kubectl create namespace sre-monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "==========================================="
echo "WSL and Minikube setup completed successfully!"
echo "Minikube status:"
minikube status
echo "==========================================="
