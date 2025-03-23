#!/bin/bash

# Master deployment script for React SRE Application
# Executes all steps in sequence to deploy the complete application

# Set strict error handling
set -e

# Define color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project directories
PROJECT_ROOT="$HOME/Desktop/Mthree-Notes/react-sre-project"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

# Function for logging with timestamps
log() {
  local level=$1
  local message=$2
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  
  case $level in
    "INFO")
      echo -e "${GREEN}[INFO]${NC} $timestamp - $message"
      ;;
    "WARN")
      echo -e "${YELLOW}[WARN]${NC} $timestamp - $message"
      ;;
    "ERROR")
      echo -e "${RED}[ERROR]${NC} $timestamp - $message"
      ;;
    *)
      echo -e "${BLUE}[$level]${NC} $timestamp - $message"
      ;;
  esac
}

# Check if we're running in WSL
check_wsl() {
  if ! grep -q Microsoft /proc/version; then
    log "ERROR" "This script must be run within WSL"
    # exit 1
  fi
  
  log "INFO" "WSL detected, continuing with deployment"
}

# Main deployment process
main() {
  log "INFO" "Starting React SRE Application deployment"
  
  # Check WSL environment
  # check_wsl
  
  # Make scripts executable
  chmod +x "$SCRIPTS_DIR/minikube_control.py" "$SCRIPTS_DIR/deploy_app.py"
  
  # Activate Python virtual environment if it exists
  if [ -f "$PROJECT_ROOT/venv/bin/activate" ]; then
    log "INFO" "Activating Python virtual environment"
    source "$PROJECT_ROOT/venv/bin/activate"
  fi
  
  # Set environment variable for wzegh library
  export WZEGH_CONFIGURED="TRUE"
  
  # Start Minikube
  log "INFO" "Starting Minikube"
  python3 "$SCRIPTS_DIR/minikube_control.py" start
  
  # Wait for Minikube to be fully ready
  log "INFO" "Waiting for Minikube to be fully ready"
  sleep 10
  
  # Deploy the application with monitoring
  log "INFO" "Deploying React SRE Application with monitoring"
  python3 "$SCRIPTS_DIR/deploy_app.py" --env=dev --port-forward
  
  log "INFO" "Deployment completed successfully"
}

# Run the main function
main
