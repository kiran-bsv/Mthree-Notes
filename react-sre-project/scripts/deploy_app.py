#!/usr/bin/env python3

"""
React SRE Application Deployment Script
Deploys the React SRE app to Minikube with proper monitoring.
"""

import argparse
import os
import subprocess
import sys
import time
from datetime import datetime

# Constants
PROJECT_ROOT = os.path.expanduser("/home/kiran/Desktop/Mthree-Notes/react-sre-project")
REACT_APP_DIR = os.path.join(PROJECT_ROOT, "sre-react-app")
K8S_DIR = os.path.join(PROJECT_ROOT, "kubernetes")
MONITORING_DIR = os.path.join(PROJECT_ROOT, "monitoring")
DEPLOY_TIMEOUT = 300  # 5 minutes
KUBECTL_CMD = "kubectl"  # Use kubectl instead of kubectly

def log(level, message):
    """Log messages with timestamp and level."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    levels = {
        "INFO": "\033[92m",  # Green
        "WARN": "\033[93m",  # Yellow
        "ERROR": "\033[91m",  # Red
        "DEBUG": "\033[94m",  # Blue
    }
    
    color = levels.get(level, "\033[0m")
    reset = "\033[0m"
    print(f"{color}[{level}]{reset} {timestamp} - {message}")

def run_command(command, timeout=60, retry=1, shell=False, cwd = None):
    """Run a shell command with timeout and retry logic."""
    for attempt in range(retry):
        try:
            log("DEBUG", f"Running command: {command if shell else ' '.join(command)}")
            
            if shell:
                result = subprocess.run(
                    command,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    timeout=timeout,
                    shell=True,
                    cwd = cwd
                )
            else:
                result = subprocess.run(
                    command,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    timeout=timeout,
                    cwd = cwd
                )
            
            if result.returncode == 0:
                return result.stdout.strip()
            else:
                log("WARN", f"Command failed (attempt {attempt+1}/{retry}): {result.stderr}")
                if attempt < retry - 1:
                    time.sleep(5)
        except subprocess.TimeoutExpired:
            log("WARN", f"Command timed out after {timeout}s (attempt {attempt+1}/{retry})")
            if attempt < retry - 1:
                time.sleep(5)
    
    log("ERROR", f"Command failed after {retry} attempts: {command if shell else ' '.join(command)}")
    return None

def check_minikube_status():
    """Check if Minikube is running."""
    status = run_command(["minikube", "status", "-o", "json"], timeout=10)
    
    if status:
        try:
            import json
            status_json = json.loads(status)
            return status_json.get("Host", "") == "Running"
        except json.JSONDecodeError:
            return "Running" in status
    
    return False

def build_react_app():
    """Build the React application."""
    log("INFO", "Building React application...")
    
    if not os.path.exists(REACT_APP_DIR):
        log("ERROR", f"React app directory does not exist: {REACT_APP_DIR}")
        return False
    
    # Install dependencies
    log("INFO", "Installing npm dependencies...")
    result = run_command(["npm", "install", "--legacy-peer-deps"], timeout=300, cwd=REACT_APP_DIR)
    if result is None:
        log("ERROR", "Failed to install npm dependencies")
        return False
    
    # Build the app
    log("INFO", "Building React application...")
    result = run_command(["npm", "run", "build"], timeout=300, cwd=REACT_APP_DIR)
    if result is None:
        log("ERROR", "Failed to build React application")
        return False
    
    log("INFO", "React application built successfully")
    return True

def build_docker_image():
    """Build Docker image for the React app."""
    log("INFO", "Building Docker image...")
    
    if not os.path.exists(os.path.join(REACT_APP_DIR, "Dockerfile")):
        log("ERROR", "Dockerfile not found in React app directory")
        return False
    
    # Build the image
    result = run_command(
        ["docker", "build", "-t", "react-sre-app:latest", "."],
        timeout=300,
        cwd=REACT_APP_DIR
    )
    if result is None:
        log("ERROR", "Failed to build Docker image")
        return False
    
    # Load the image into Minikube
    log("INFO", "Loading Docker image into Minikube...")
    result = run_command(
        ["minikube", "image", "load", "react-sre-app:latest"],
        timeout=120
    )
    if result is None:
        log("ERROR", "Failed to load Docker image into Minikube")
        return False
    
    log("INFO", "Docker image built and loaded successfully")
    return True

# def create_namespaces():
#     """Create necessary Kubernetes namespaces."""
#     log("INFO", "Creating Kubernetes namespaces...")
    
#     namespaces = ["react-sre-app", "monitoring"]
#     for namespace in namespaces:
#         result = run_command(
#             [KUBECTL_CMD, "create", "namespace", namespace, "--dry-run=client", "-o", "yaml"],
#             timeout=10
#         )
#         if result is None:
#             log("ERROR", f"Failed to generate namespace YAML for {namespace}")
#             return False
        
#         # Apply with kubectl
#         apply_result = run_command(
#             # f"{KUBECTL_CMD} create namespace {namespace} --dry-run=client -o yaml | {KUBECTL_CMD} apply -f -",
#             f"{KUBECTL_CMD} apply -f -",
#             input = result,
#             timeout=10,
#             shell=True,
#             retry=3,
#         )
#         if apply_result is None:
#             log("ERROR", f"Failed to create namespace {namespace}")
#             return False

#     # namespace_yaml = os.path.join(PROJECT_ROOT, "kubernetes", "base", "namespace.yaml")

#     # if not os.path.exists(namespace_yaml):
#     #     log("ERROR", f"Namespace YAML file not found: {namespace_yaml}")
#     #     return False

#     # # Apply the namespace YAML
#     # apply_result = run_command(
#     #     [KUBECTL_CMD, "apply", "-f", namespace_yaml],
#     #     timeout=30,
#     #     retry=3
#     # )
#     # apply_monitoring_result = run_command(
#     #     f"{KUBECTL_CMD} create namespace monitoring --dry-run=client -o yaml" ,
#     #     timeout=30,
#     #     retry=3
#     # )
#     # print("apply_monitoring_result\n:", apply_monitoring_result)

#     if apply_result is None:
#         log("ERROR", "Failed to create namespaces from YAML")
#         return False
    
#     # if apply_monitoring_result is None:
#     #     log("ERROR", "Failed to create namespaces from YAML")
#     #     return False
    
#     log("INFO", "Kubernetes namespaces created successfully")
#     return True

def create_namespaces():
    """Create necessary Kubernetes namespaces."""
    log("INFO", "Creating Kubernetes namespaces...")
    
    namespaces = ["react-sre-app", "monitoring"]
    for namespace in namespaces:
        # Step 1: Generate namespace YAML
        result = run_command(
            [KUBECTL_CMD, "create", "namespace", namespace, "--dry-run=client", "-o", "yaml"],
            timeout=10
        )
        if result is None:
            log("ERROR", f"Failed to generate namespace YAML for {namespace}")
            return False

        # Step 2: Apply it using subprocess directly, feeding YAML to stdin
        try:
            log("DEBUG", f"Applying namespace YAML for {namespace}")
            apply_proc = subprocess.run(
                [KUBECTL_CMD, "apply", "-f", "-"],
                input=result,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=30
            )
            if apply_proc.returncode != 0:
                log("ERROR", f"Failed to create namespace {namespace}: {apply_proc.stderr}")
                return False
        except subprocess.TimeoutExpired:
            log("ERROR", f"Timeout while applying namespace {namespace}")
            return False

    log("INFO", "Kubernetes namespaces created successfully")
    return True

def deploy_monitoring():
    """Deploy Prometheus and Grafana for monitoring."""
    log("INFO", "Deploying monitoring stack...")
    
    # Deploy Prometheus
    log("INFO", "Deploying Prometheus...")
    prometheus_yaml = os.path.join(MONITORING_DIR, "prometheus-k8s.yaml")
    if not os.path.exists(prometheus_yaml):
        log("ERROR", f"Prometheus Kubernetes YAML not found: {prometheus_yaml}")
        return False

    result = run_command(
        [KUBECTL_CMD, "apply", "-f", prometheus_yaml],
        timeout=30,
        retry=3
    )
    if result is None:
        log("ERROR", "Failed to deploy Prometheus")
        return False
    
    # Deploy Grafana
    log("INFO", "Deploying Grafana...")
    grafana_yaml = os.path.join(MONITORING_DIR, "grafana-k8s.yaml")
    if not os.path.exists(grafana_yaml):
        log("ERROR", f"Grafana Kubernetes YAML not found: {grafana_yaml}")
        return False
    
    result = run_command(
        [KUBECTL_CMD, "apply", "-f", grafana_yaml],
        timeout=30,
        retry=3
    )
    if result is None:
        log("ERROR", "Failed to deploy Grafana")
        return False
    
    # Wait for Prometheus and Grafana to be ready
    log("INFO", "Waiting for monitoring stack to be ready...")
    start_time = time.time()
    prometheus_ready = False
    grafana_ready = False
    
    while time.time() - start_time < DEPLOY_TIMEOUT:
        if not prometheus_ready:
            prom_status = run_command(
                [KUBECTL_CMD, "get", "pods", "-n", "monitoring", "-l", "app=prometheus", "-o", "jsonpath='{.items[0].status.phase}'"],
                timeout=10
            )
            if prom_status and "Running" in prom_status:
                prometheus_ready = True
                log("INFO", "Prometheus is ready")
        
        if not grafana_ready:
            graf_status = run_command(
                [KUBECTL_CMD, "get", "pods", "-n", "monitoring", "-l", "app=grafana", "-o", "jsonpath='{.items[0].status.phase}'"],
                timeout=10
            )
            if graf_status and "Running" in graf_status:
                grafana_ready = True
                log("INFO", "Grafana is ready")
        
        if prometheus_ready and grafana_ready:
            log("INFO", "Monitoring stack deployed successfully")
            return True
        
        elapsed = int(time.time() - start_time)
        log("INFO", f"Waiting for monitoring stack... ({elapsed}s elapsed)")
        time.sleep(10)
    
    log("ERROR", f"Monitoring stack deployment timed out after {DEPLOY_TIMEOUT}s")
    return False

def deploy_application(env="dev"):
    """Deploy the React application to Kubernetes."""
    log("INFO", f"Deploying React application to {env} environment...")
    
    # Apply Kubernetes configuration using kustomize
    kustomize_dir = os.path.join(K8S_DIR, "overlays", env)
    if not os.path.exists(kustomize_dir):
        log("ERROR", f"Kubernetes overlay directory not found: {kustomize_dir}")
        return False
    
    result = run_command(
        [KUBECTL_CMD, "apply", "-k", kustomize_dir],
        timeout=60,
        retry=3
    )
    if result is None:
        log("ERROR", f"Failed to deploy application to {env} environment")
        return False
    
    # Wait for application to be ready
    log("INFO", "Waiting for application to be ready...")
    start_time = time.time()
    while time.time() - start_time < DEPLOY_TIMEOUT:
        app_status = run_command(
            [KUBECTL_CMD, "get", "pods", "-n", "react-sre-app", "-l", f"app=react-sre-app", "-o", "jsonpath='{.items[*].status.phase}'"],
            timeout=10
        )
        
        if app_status and "Running" in app_status and "Pending" not in app_status:
            log("INFO", "Application is ready")
            return True
        
        elapsed = int(time.time() - start_time)
        log("INFO", f"Waiting for application... ({elapsed}s elapsed)")
        time.sleep(10)
    
    log("ERROR", f"Application deployment timed out after {DEPLOY_TIMEOUT}s")
    return False

def setup_port_forwarding():
    """Set up port forwarding for the application and monitoring tools."""
    log("INFO", "Setting up port forwarding...")
    
    # Port forward for React app
    app_forward = subprocess.Popen(
        [KUBECTL_CMD, "port-forward", "svc/dev-react-sre-app", "3000:80", "-n", "react-sre-app"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )
    
    # Port forward for Prometheus
    prom_forward = subprocess.Popen(
        [KUBECTL_CMD, "port-forward", "svc/prometheus", "9090:9090", "-n", "monitoring"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )
    
    # Port forward for Grafana
    graf_forward = subprocess.Popen(
        [KUBECTL_CMD, "port-forward", "svc/grafana", "8081:3000", "-n", "monitoring"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )
    
    log("INFO", "Port forwarding set up successfully")
    log("INFO", "Application available at http://localhost:3000")
    log("INFO", "Prometheus available at http://localhost:9090")
    log("INFO", "Grafana available at http://localhost:8081 (admin/admin)")
    
    try:
        log("INFO", "Press Ctrl+C to stop port forwarding")
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        log("INFO", "Stopping port forwarding...")
        app_forward.terminate()
        prom_forward.terminate()
        graf_forward.terminate()

def main():
    """Main function to parse arguments and execute deployment."""
    parser = argparse.ArgumentParser(description="React SRE Application Deployment Script")
    parser.add_argument("--env", choices=["dev", "prod"], default="dev",
                        help="Environment to deploy to (default: dev)")
    parser.add_argument("--skip-build", action="store_true",
                        help="Skip building the React app")
    parser.add_argument("--skip-monitoring", action="store_true",
                        help="Skip deploying Prometheus and Grafana")
    parser.add_argument("--port-forward", action="store_true",
                        help="Set up port forwarding after deployment")
    
    args = parser.parse_args()
    
    # Check if Minikube is running
    if not check_minikube_status():
        log("ERROR", "Minikube is not running. Please start it first.")
        return False
    
    # Build and deploy
    success = True
    
    # Create Kubernetes namespaces
    if not create_namespaces():
        return False
    
    # Build React app and Docker image
    if not args.skip_build:
        if not build_react_app():
            return False
        if not build_docker_image():
            return False
    
    # Deploy monitoring stack
    if not args.skip_monitoring:
        if not deploy_monitoring():
            success = False
    
    # Deploy application
    if not deploy_application(args.env):
        success = False
    
    # Set up port forwarding if requested
    if args.port_forward and success:
        setup_port_forwarding()
    
    if success:
        log("INFO", "Deployment completed successfully")
    else:
        log("ERROR", "Deployment completed with errors")
    
    return success

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
