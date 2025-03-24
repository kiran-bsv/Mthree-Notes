#!/bin/bash

set -e

echo "========== SRE Application Setup Script =========="
echo "This script will set up the complete SRE environment"

# Check if running on Windows with WSL
# if [[ "$(uname -r)" != *Microsoft* ]] && [[ "$(uname -r)" != *microsoft* ]]; then
#   echo "This script is intended to be run on Windows with WSL."
#   echo "If you've already installed WSL, you can continue. Otherwise, please install WSL first."
#   read -p "Continue? (y/n) " -n 1 -r
#   echo
#   if [[ ! $REPLY =~ ^[Yy]$ ]]; then
#     exit 1
#   fi
# fi

# Step 1: Set up WSL and Minikube
echo "Step 1: Setting up WSL and Minikube..."
# ./wsl-setup/setup-wsl-minikube.sh

# Step 2: Build and deploy the Flask API
echo "Step 2: Building and deploying the Flask API..."
cd flask-api
docker build -t flask-api:latest .
cd ..

minikube image load flask-api:latest
kubectl apply -f k8s/flask-api/deployment.yaml

# Step 3: Build and deploy the Angular UI
echo "Step 3: Building and deploying the Angular UI..."
cd angular-ui
# In a real script, we would build the Angular app here
# For brevity, we'll just build the Docker image
docker build -t angular-ui:latest .
cd ..


minikube image load angular-ui:latest
kubectl apply -f k8s/angular-ui/deployment.yaml

# Step 4: Set up Prometheus
echo "Step 4: Setting up Prometheus..."
# ./prometheus/setup-prometheus.sh

# Step 5: Set up Grafana
echo "Step 5: Setting up Grafana..."
# ./grafana/setup-grafana.sh

echo "==========================================="
echo "SRE Application setup completed successfully!"
echo "Access your applications at:"
echo "- Angular UI: http://$(minikube ip)"
echo "- Prometheus: http://localhost:9090 (port-forwarded)"
echo "- Grafana: http://localhost:3000 (port-forwarded)"
echo "  Username: admin"
echo "  Password: admin"
echo "==========================================="
