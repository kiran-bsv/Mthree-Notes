#!/usr/bin/env python3

"""
Minikube Control Script
Handles starting, stopping, and checking Minikube status with proper error handling.
"""

import argparse
import os
import subprocess
import sys
import time
from datetime import datetime

# Set constants
MINIKUBE_WAIT_TIMEOUT = 60  # Seconds to wait for Minikube operations
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

def run_command(command, timeout=60, retry=3):
    """Run a shell command with timeout and retry logic."""
    for attempt in range(retry):
        try:
            log("DEBUG", f"Running command: {' '.join(command)}")
            result = subprocess.run(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=timeout
            )
            print(result.stdout)
            if result.returncode == 0:
                return result.stdout.strip()
            else:
                log("WARN", f"Command failed (attempt {attempt+1}/{retry}): {result.stderr}")
                time.sleep(5)
        except subprocess.TimeoutExpired:
            log("WARN", f"Command timed out after {timeout}s (attempt {attempt+1}/{retry})")
            time.sleep(5)
    
    log("ERROR", f"Command failed after {retry} attempts: {' '.join(command)}")
    return None

def check_minikube_status():
    """Check if Minikube is running."""
    status = run_command(["minikube", "status", "-o", "json"], timeout=10)
    # print("status\n:", status)
    
    if status:
        try:
            import json
            status_json = json.loads(status)
            # print(type(status_json))
            return status_json.get("Host", "") == "Running"
        except json.JSONDecodeError:
            return "Running" in status
    
    return False

def start_minikube():
    """Start Minikube with proper configuration."""
    if check_minikube_status():
        log("INFO", "Minikube is already running")
        return True
    
    log("INFO", f"Starting Minikube (timeout: {MINIKUBE_WAIT_TIMEOUT}s)")
    
    # Fix for wzegh library error - create mock environment variable
    os.environ["WZEGH_CONFIGURED"] = "TRUE"
    
    # Start Minikube with memory and CPU settings suitable for SRE tools
    result = run_command(
        ["minikube", "start", "--memory=4096", "--cpus=2", "--driver=docker"],
        timeout=MINIKUBE_WAIT_TIMEOUT
    )
    
    if result is None:
        log("ERROR", "Failed to start Minikube")
        return False
    
    # Wait for Minikube to be fully ready
    start_time = time.time()
    while time.time() - start_time < MINIKUBE_WAIT_TIMEOUT:
        if check_minikube_status():
            # Validate kubectl is working
            version = run_command([KUBECTL_CMD, "version", "--output=yaml"], timeout=10)
            if version:
                log("INFO", "Minikube started successfully")
                return True
        
        log("INFO", f"Waiting for Minikube to be ready... ({int(time.time() - start_time)}s elapsed)")
        time.sleep(5)
    
    log("ERROR", f"Minikube failed to start within {MINIKUBE_WAIT_TIMEOUT}s")
    return False

def stop_minikube():
    """Stop Minikube safely."""
    if not check_minikube_status():
        log("INFO", "Minikube is not running")
        return True
    
    log("INFO", "Stopping Minikube")
    result = run_command(["minikube", "stop"], timeout=MINIKUBE_WAIT_TIMEOUT)
    
    if result is None:
        log("ERROR", "Failed to stop Minikube")
        return False
    
    log("INFO", "Minikube stopped successfully")
    return True

def main():
    """Main function to parse arguments and execute commands."""
    parser = argparse.ArgumentParser(description="Minikube Control Script")
    parser.add_argument("action", choices=["start", "stop", "status", "restart"],
                        help="Action to perform on Minikube")
    
    args = parser.parse_args()
    
    if args.action == "start":
        success = start_minikube()
    elif args.action == "stop":
        success = stop_minikube()
    elif args.action == "restart":
        stop_minikube()
        time.sleep(5)
        success = start_minikube()
    elif args.action == "status":
        status = check_minikube_status()
        log("INFO", f"Minikube is {'running' if status else 'not running'}")
        success = True
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
