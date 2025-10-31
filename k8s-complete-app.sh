#!/bin/bash
# ===================================================================================================
# KUBERNETES ZERO TO HERO - COMPLETE APPLICATION WITH VOLUME MOUNTING
# ===================================================================================================
# This script creates a comprehensive Kubernetes application that demonstrates:
#  - Volume mounting from host (/mnt/c/kubernetes) to pods
#  - ConfigMaps for application configuration
#  - Secrets for sensitive data
#  - Deployments with replica management
#  - Services with different access types
#  - Ingress for URL-based routing
#  - Health checks and probes
#  - Resource management
#  - Namespaces for logical separation
# ===================================================================================================

# Color definitions for better terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}             KUBERNETES ZERO TO HERO - MASTER SCRIPT                  ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# ===== STEP 1: SET UP HOST DIRECTORIES =====
echo -e "${MAGENTA}[STEP 1] SETTING UP HOST DIRECTORIES${NC}"
echo -e "${CYAN}Creating and setting proper permissions for /mnt/c/kubernetes directory...${NC}"

# First, create the host directory structure and set proper permissions
# This is where our volume will be mounted from
mkdir -p /mnt/c/kubernetes/{data,config,logs}

# Set permissions to ensure Kubernetes pods can access this directory
# chmod 777 is used here for demonstration purposes, in production you'd use more restrictive permissions
chmod -R 777 /mnt/c/kubernetes

# Create some sample files in the data directory for our app to read
echo "This is a sample configuration file for our Kubernetes app" > /mnt/c/kubernetes/config/sample-config.txt
echo "Hello from the mounted volume!" > /mnt/c/kubernetes/data/hello.txt
echo "This file demonstrates volume mounting in Kubernetes" > /mnt/c/kubernetes/data/info.txt

# Create a directory for logs that the application will write to
mkdir -p /mnt/c/kubernetes/logs
chmod 777 /mnt/c/kubernetes/logs

echo -e "${GREEN}✓ Host directories setup complete${NC}"
echo -e "${YELLOW}Created and configured directories under /mnt/c/kubernetes${NC}"

# ===== STEP 2: SET UP PROJECT DIRECTORY STRUCTURE =====
echo -e "${MAGENTA}[STEP 2] SETTING UP PROJECT DIRECTORY STRUCTURE${NC}"

# Define project directory - this is where all our files will be stored
PROJECT_DIR=~/k8s-master-app
echo -e "${CYAN}Creating project directory at ${PROJECT_DIR}...${NC}"

# Create the directory structure for our project
mkdir -p ${PROJECT_DIR}/{app,k8s/{base,volumes,networking,config,monitoring},scripts}

echo -e "${GREEN}✓ Project directory structure created${NC}"

# ===== STEP 3: CREATE APPLICATION FILES =====
echo -e "${MAGENTA}[STEP 3] CREATING APPLICATION FILES${NC}"
echo -e "${CYAN}Building a Flask application that demonstrates volume mounting...${NC}"

# Create a Python Flask application that works with files in the mounted volume
cat > ${PROJECT_DIR}/app/app.py << 'EOL'
#!/usr/bin/env python3
"""
Kubernetes Master Application
=============================

This Flask application demonstrates:
1. Reading from and writing to mounted volumes
2. Working with environment variables (from ConfigMaps and Secrets)
3. Health checking
4. Resource usage reporting
5. Metrics collection

This showcases how a containerized application interacts with Kubernetes features.
"""
from flask import Flask, jsonify, render_template_string, request, redirect, url_for
import os
import socket
import datetime
import json
import logging
import uuid
import platform
import psutil  # For resource usage statistics
import time
import threading
import sys

# Initialize Flask application
app = Flask(__name__)

# Set up logging to print to console and file
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler(os.environ.get('LOG_PATH', '/app/app.log'))
    ]
)
logger = logging.getLogger('k8s-master-app')

# Read configuration from environment variables (from ConfigMaps)
APP_NAME = os.environ.get('APP_NAME', 'k8s-master-app')
APP_VERSION = os.environ.get('APP_VERSION', '1.0.0')
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'development')
DATA_PATH = os.environ.get('DATA_PATH', '/data')
CONFIG_PATH = os.environ.get('CONFIG_PATH', '/config')
LOG_PATH = os.environ.get('LOG_PATH', '/logs')

# Read secrets from environment variables (from Secrets)
# In a real app, these would be more sensitive values like API keys
SECRET_KEY = os.environ.get('SECRET_KEY', 'default-dev-key')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'default-password')

# Generate a unique instance ID to demonstrate statelessness
INSTANCE_ID = str(uuid.uuid4())[:8]

# Track request count and application metrics
request_count = 0
start_time = time.time()
metrics = {
    'requests': 0,
    'errors': 0,
    'data_reads': 0,
    'data_writes': 0
}

# Simulate application load for resource usage demonstration
def background_worker():
    """
    Simulate background work to demonstrate resource usage.
    In a real app, this might be processing tasks, etc.
    """
    logger.info("Background worker started")
    counter = 0
    while True:
        # Simple CPU work - calculate prime numbers
        counter += 1
        if counter % 1000 == 0:
            # Log occasionally to show activity
            logger.debug(f"Background worker tick: {counter}")
        time.sleep(0.1)  # Don't use too much CPU

# Start the background worker
worker_thread = threading.Thread(target=background_worker, daemon=True)
worker_thread.start()

@app.route('/')
def index():
    """Main page showing application status and mounted volume information"""
    global request_count, metrics
    request_count += 1
    metrics['requests'] += 1
    
    # Log the request
    logger.info(f"Request to index page from {request.remote_addr}")
    
    # Get system information
    system_info = {
        'hostname': socket.gethostname(),
        'platform': platform.platform(),
        'python_version': platform.python_version(),
        'cpu_count': psutil.cpu_count(),
        'memory': f"{psutil.virtual_memory().total / (1024 * 1024):.1f} MB",
        'uptime': f"{time.time() - start_time:.1f} seconds"
    }
    
    # Get resource usage
    resource_usage = {
        'cpu_percent': psutil.cpu_percent(),
        'memory_percent': psutil.virtual_memory().percent,
        'disk_usage': f"{psutil.disk_usage('/').percent}%"
    }
    
    # Get information about mounted volumes
    volumes = {}
    
    # Check data volume
    try:
        data_files = os.listdir(DATA_PATH)
        volumes['data'] = {
            'path': DATA_PATH,
            'files': data_files,
            'status': 'mounted' if data_files else 'empty'
        }
        metrics['data_reads'] += 1
    except Exception as e:
        volumes['data'] = {
            'path': DATA_PATH,
            'error': str(e),
            'status': 'error'
        }
        metrics['errors'] += 1
    
    # Check config volume
    try:
        config_files = os.listdir(CONFIG_PATH)
        volumes['config'] = {
            'path': CONFIG_PATH,
            'files': config_files,
            'status': 'mounted' if config_files else 'empty'
        }
    except Exception as e:
        volumes['config'] = {
            'path': CONFIG_PATH,
            'error': str(e),
            'status': 'error'
        }
        metrics['errors'] += 1
    
    # Check logs volume
    try:
        logs_files = os.listdir(LOG_PATH)
        volumes['logs'] = {
            'path': LOG_PATH,
            'files': logs_files,
            'status': 'mounted' if logs_files else 'empty'
        }
    except Exception as e:
        volumes['logs'] = {
            'path': LOG_PATH,
            'error': str(e),
            'status': 'error'
        }
        metrics['errors'] += 1
    
    # Build HTML content using a template
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>{{ app_name }} - Kubernetes Master App</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { 
                font-family: Arial, sans-serif; 
                line-height: 1.6; 
                margin: 0; 
                padding: 20px; 
                background-color: #f5f5f5;
                color: #333;
            }
            h1, h2, h3 { color: #2c3e50; }
            .container { 
                max-width: 1000px; 
                margin: 0 auto; 
                background-color: white;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            .info-box { 
                background-color: #f8f9fa; 
                border-radius: 5px; 
                padding: 15px; 
                margin-bottom: 20px; 
                border-left: 4px solid #3498db;
            }
            .success { color: #27ae60; }
            .error { color: #e74c3c; }
            .warning { color: #f39c12; }
            .info { color: #3498db; }
            .file-list { 
                background-color: #f9f9f9; 
                border-radius: 5px; 
                padding: 10px; 
                border: 1px solid #ddd;
            }
            .file-item {
                display: flex;
                justify-content: space-between;
                padding: 5px 10px;
                border-bottom: 1px solid #eee;
            }
            .file-item:last-child {
                border-bottom: none;
            }
            .nav-links {
                display: flex;
                gap: 10px;
                margin-top: 20px;
            }
            .nav-link {
                display: inline-block;
                padding: 8px 16px;
                background-color: #3498db;
                color: white;
                text-decoration: none;
                border-radius: 4px;
                font-weight: bold;
                transition: background-color 0.3s;
            }
            .nav-link:hover {
                background-color: #2980b9;
            }
            .metrics {
                display: flex;
                gap: 10px;
                flex-wrap: wrap;
            }
            .metric-card {
                flex: 1;
                min-width: 120px;
                background-color: #fff;
                padding: 15px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                text-align: center;
            }
            .metric-value {
                font-size: 24px;
                font-weight: bold;
                margin: 10px 0;
                color: #3498db;
            }
            .metric-label {
                font-size: 14px;
                color: #7f8c8d;
            }
            .badge {
                display: inline-block;
                padding: 3px 8px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: bold;
                color: white;
                background-color: #95a5a6;
            }
            .badge-primary { background-color: #3498db; }
            .badge-success { background-color: #27ae60; }
            .badge-warning { background-color: #f39c12; }
            .badge-danger { background-color: #e74c3c; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>{{ app_name }} <span class="badge badge-primary">v{{ app_version }}</span></h1>
            <p>A comprehensive Kubernetes demonstration application</p>
            
            <div class="info-box">
                <h2>Pod Information</h2>
                <p><strong>Instance ID:</strong> {{ instance_id }}</p>
                <p><strong>Hostname:</strong> {{ system_info.hostname }}</p>
                <p><strong>Environment:</strong> <span class="badge badge-success">{{ environment }}</span></p>
                <p><strong>Request count:</strong> {{ request_count }}</p>
                <p><strong>Platform:</strong> {{ system_info.platform }}</p>
                <p><strong>Uptime:</strong> {{ system_info.uptime }}</p>
            </div>
            
            <div class="info-box">
                <h2>Resource Usage</h2>
                <div class="metrics">
                    <div class="metric-card">
                        <div class="metric-label">CPU Usage</div>
                        <div class="metric-value">{{ resource_usage.cpu_percent }}%</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Memory</div>
                        <div class="metric-value">{{ resource_usage.memory_percent }}%</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Disk</div>
                        <div class="metric-value">{{ resource_usage.disk_usage }}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Requests</div>
                        <div class="metric-value">{{ metrics.requests }}</div>
                    </div>
                </div>
            </div>
            
            <div class="info-box">
                <h2>Mounted Volumes</h2>
                
                <h3>Data Volume</h3>
                <p><strong>Path:</strong> {{ volumes.data.path }}</p>
                <p><strong>Status:</strong> 
                    {% if volumes.data.status == 'mounted' %}
                        <span class="success">Successfully mounted</span>
                    {% elif volumes.data.status == 'empty' %}
                        <span class="warning">Mounted but empty</span>
                    {% else %}
                        <span class="error">Error: {{ volumes.data.error }}</span>
                    {% endif %}
                </p>
                
                {% if volumes.data.files %}
                <div class="file-list">
                    <h4>Files:</h4>
                    {% for file in volumes.data.files %}
                    <div class="file-item">
                        <span>{{ file }}</span>
                        <a href="/view-file?path={{ volumes.data.path }}/{{ file }}" class="nav-link">View</a>
                    </div>
                    {% endfor %}
                </div>
                {% endif %}
                
                <h3>Config Volume</h3>
                <p><strong>Path:</strong> {{ volumes.config.path }}</p>
                <p><strong>Status:</strong> 
                    {% if volumes.config.status == 'mounted' %}
                        <span class="success">Successfully mounted</span>
                    {% elif volumes.config.status == 'empty' %}
                        <span class="warning">Mounted but empty</span>
                    {% else %}
                        <span class="error">Error: {{ volumes.config.error }}</span>
                    {% endif %}
                </p>
                
                {% if volumes.config.files %}
                <div class="file-list">
                    <h4>Files:</h4>
                    {% for file in volumes.config.files %}
                    <div class="file-item">
                        <span>{{ file }}</span>
                        <a href="/view-file?path={{ volumes.config.path }}/{{ file }}" class="nav-link">View</a>
                    </div>
                    {% endfor %}
                </div>
                {% endif %}
                
                <h3>Logs Volume</h3>
                <p><strong>Path:</strong> {{ volumes.logs.path }}</p>
                <p><strong>Status:</strong> 
                    {% if volumes.logs.status == 'mounted' %}
                        <span class="success">Successfully mounted</span>
                    {% elif volumes.logs.status == 'empty' %}
                        <span class="warning">Mounted but empty</span>
                    {% else %}
                        <span class="error">Error: {{ volumes.logs.error }}</span>
                    {% endif %}
                </p>
                
                {% if volumes.logs.files %}
                <div class="file-list">
                    <h4>Files:</h4>
                    {% for file in volumes.logs.files %}
                    <div class="file-item">
                        <span>{{ file }}</span>
                        <a href="/view-file?path={{ volumes.logs.path }}/{{ file }}" class="nav-link">View</a>
                    </div>
                    {% endfor %}
                </div>
                {% endif %}
            </div>
            
            <div class="info-box">
                <h2>Actions</h2>
                <div class="nav-links">
                    <a href="/create-file" class="nav-link">Create a File</a>
                    <a href="/api/info" class="nav-link">API Info</a>
                    <a href="/api/health" class="nav-link">Health Check</a>
                    <a href="/api/metrics" class="nav-link">Metrics</a>
                </div>
            </div>
            
            <div class="info-box">
                <h2>Environment Variables</h2>
                <p><strong>APP_NAME:</strong> {{ app_name }}</p>
                <p><strong>APP_VERSION:</strong> {{ app_version }}</p>
                <p><strong>ENVIRONMENT:</strong> {{ environment }}</p>
                <p><strong>DATA_PATH:</strong> {{ data_path }}</p>
                <p><strong>CONFIG_PATH:</strong> {{ config_path }}</p>
                <p><strong>LOG_PATH:</strong> {{ log_path }}</p>
                <p><strong>SECRET_KEY:</strong> {{ secret_key|truncate(10, True, '...') }}</p>
            </div>
        </div>
    </body>
    </html>
    """
    
    # Render the template with our data
    return render_template_string(
        html_content,
        app_name=APP_NAME,
        app_version=APP_VERSION,
        environment=ENVIRONMENT,
        instance_id=INSTANCE_ID,
        system_info=system_info,
        resource_usage=resource_usage,
        volumes=volumes,
        request_count=request_count,
        metrics=metrics,
        data_path=DATA_PATH,
        config_path=CONFIG_PATH,
        log_path=LOG_PATH,
        secret_key=SECRET_KEY
    )

@app.route('/view-file')
def view_file():
    """View the contents of a file from a mounted volume"""
    global metrics
    
    # Get the file path from the query parameters
    file_path = request.args.get('path', '')
    
    # Security check to prevent directory traversal attacks
    # Only allow access to our mounted volumes
    allowed_paths = [DATA_PATH, CONFIG_PATH, LOG_PATH]
    valid_path = False
    
    for path in allowed_paths:
        if file_path.startswith(path):
            valid_path = True
            break
    
    if not valid_path:
        metrics['errors'] += 1
        return "Access denied: Invalid path", 403
    
    # Try to read the file
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Record the successful read
        metrics['data_reads'] += 1
        logger.info(f"File viewed: {file_path}")
        
        # Simple HTML to display the file content
        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>File: {os.path.basename(file_path)}</title>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; padding: 20px; }}
                pre {{ background-color: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }}
                .nav-link {{
                    display: inline-block;
                    padding: 8px 16px;
                    background-color: #3498db;
                    color: white;
                    text-decoration: none;
                    border-radius: 4px;
                    font-weight: bold;
                }}
            </style>
        </head>
        <body>
            <h1>File: {os.path.basename(file_path)}</h1>
            <p>Path: {file_path}</p>
            <pre>{content}</pre>
            <a href="/" class="nav-link">Back to Home</a>
        </body>
        </html>
        """
        return html
    except Exception as e:
        metrics['errors'] += 1
        logger.error(f"Error viewing file {file_path}: {str(e)}")
        return f"Error reading file: {str(e)}", 500

@app.route('/create-file', methods=['GET', 'POST'])
def create_file():
    """Create a new file in the mounted data volume"""
    global metrics
    
    if request.method == 'POST':
        filename = request.form.get('filename', '')
        content = request.form.get('content', '')
        
        # Only allow creating files in the data directory
        file_path = os.path.join(DATA_PATH, filename)
        
        # For security, don't allow directory traversal
        if '..' in filename or '/' in filename:
            metrics['errors'] += 1
            return "Invalid filename. Directory traversal not allowed.", 400
        
        try:
            with open(file_path, 'w') as f:
                f.write(content)
            
            # Record the successful write
            metrics['data_writes'] += 1
            logger.info(f"File created: {file_path}")
            
            # Also write to the log volume to demonstrate multiple volume mounting
            log_message = f"File created: {filename} at {datetime.datetime.now().isoformat()}\n"
            with open(os.path.join(LOG_PATH, 'file_operations.log'), 'a') as log:
                log.write(log_message)
            
            return redirect('/')
        except Exception as e:
            metrics['errors'] += 1
            logger.error(f"Error creating file {file_path}: {str(e)}")
            return f"Error creating file: {str(e)}", 500
    else:
        # Show form for creating a file
        html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Create File</title>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; padding: 20px; }
                .form-group { margin-bottom: 15px; }
                label { display: block; margin-bottom: 5px; }
                input[type="text"], textarea {
                    width: 100%;
                    padding: 8px;
                    border: 1px solid #ddd;
                    border-radius: 4px;
                }
                textarea { height: 200px; }
                button {
                    padding: 8px 16px;
                    background-color: #3498db;
                    color: white;
                    border: none;
                    border-radius: 4px;
                    cursor: pointer;
                    font-weight: bold;
                }
                .nav-link {
                    display: inline-block;
                    padding: 8px 16px;
                    background-color: #95a5a6;
                    color: white;
                    text-decoration: none;
                    border-radius: 4px;
                    font-weight: bold;
                }
            </style>
        </head>
        <body>
            <h1>Create a New File</h1>
            <p>This file will be saved to the mounted data volume.</p>
            
            <form method="post">
                <div class="form-group">
                    <label for="filename">Filename:</label>
                    <input type="text" id="filename" name="filename" required placeholder="example.txt">
                </div>
                
                <div class="form-group">
                    <label for="content">Content:</label>
                    <textarea id="content" name="content" required placeholder="Enter file content here..."></textarea>
                </div>
                
                <div class="form-group">
                    <button type="submit">Create File</button>
                    <a href="/" class="nav-link">Cancel</a>
                </div>
            </form>
        </body>
        </html>
        """
        return html

@app.route('/api/info')
def api_info():
    """API endpoint returning application information"""
    return jsonify({
        'app_name': APP_NAME,
        'version': APP_VERSION,
        'environment': ENVIRONMENT,
        'instance_id': INSTANCE_ID,
        'hostname': socket.gethostname(),
        'request_count': request_count,
        'uptime_seconds': time.time() - start_time,
        'volumes': {
            'data': {
                'path': DATA_PATH,
                'mounted': os.path.exists(DATA_PATH) and os.access(DATA_PATH, os.R_OK)
            },
            'config': {
                'path': CONFIG_PATH,
                'mounted': os.path.exists(CONFIG_PATH) and os.access(CONFIG_PATH, os.R_OK)
            },
            'logs': {
                'path': LOG_PATH,
                'mounted': os.path.exists(LOG_PATH) and os.access(LOG_PATH, os.R_OK)
            }
        },
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/api/health')
def health_check():
    """Health check endpoint for Kubernetes liveness and readiness probes"""
    # Check if we can access our mounted volumes
    data_ok = os.path.exists(DATA_PATH) and os.access(DATA_PATH, os.R_OK)
    config_ok = os.path.exists(CONFIG_PATH) and os.access(CONFIG_PATH, os.R_OK)
    logs_ok = os.path.exists(LOG_PATH) and os.access(LOG_PATH, os.W_OK)
    
    # For a real application, you might check database connections, 
    # cache availability, etc.
    
    # Overall health status
    is_healthy = data_ok and config_ok and logs_ok
    
    # Log health check results
    logger.info(f"Health check: {'PASS' if is_healthy else 'FAIL'}")
    
    response = {
        'status': 'healthy' if is_healthy else 'unhealthy',
        'checks': {
            'data_volume': 'accessible' if data_ok else 'inaccessible',
            'config_volume': 'accessible' if config_ok else 'inaccessible',
            'logs_volume': 'writable' if logs_ok else 'not writable'
        },
        'timestamp': datetime.datetime.now().isoformat(),
        'hostname': socket.gethostname()
    }
    
    # Set the HTTP status code based on health
    status_code = 200 if is_healthy else 503
    
    return jsonify(response), status_code

@app.route('/api/metrics')
def get_metrics():
    """API endpoint for application metrics - useful for monitoring systems"""
    # Get basic resource usage stats
    cpu_percent = psutil.cpu_percent()
    memory_info = psutil.virtual_memory()
    disk_info = psutil.disk_usage('/')
    
    # Collect all metrics
    all_metrics = {
        'system': {
            'cpu_percent': cpu_percent,
            'memory_used_percent': memory_info.percent,
            'memory_used_mb': memory_info.used / (1024 * 1024),
            'memory_total_mb': memory_info.total / (1024 * 1024),
            'disk_used_percent': disk_info.percent,
            'disk_used_gb': disk_info.used / (1024**3),
            'disk_total_gb': disk_info.total / (1024**3)
        },
        'application': {
            'uptime_seconds': time.time() - start_time,
            'total_requests': metrics['requests'],
            'data_reads': metrics['data_reads'],
            'data_writes': metrics['data_writes'],
            'errors': metrics['errors']
        },
        'instance': {
            'id': INSTANCE_ID,
            'hostname': socket.gethostname()
        },
        'timestamp': datetime.datetime.now().isoformat()
    }
    
    # Log metrics collection for demonstration
    logger.debug(f"Metrics collected: CPU: {cpu_percent}%, Memory: {memory_info.percent}%")
    
    return jsonify(all_metrics)

# For local testing - this won't run in Kubernetes
if __name__ == '__main__':
    print(f"Starting {APP_NAME} v{APP_VERSION} in {ENVIRONMENT} mode")
    app.run(host='0.0.0.0', port=5000, debug=True)
EOL

# Create requirements.txt with necessary dependencies
cat > ${PROJECT_DIR}/app/requirements.txt << 'EOL'
Flask==2.2.3
Werkzeug==2.2.3
psutil==5.9.5
EOL

# Create a Dockerfile for the application
cat > ${PROJECT_DIR}/app/Dockerfile << 'EOL'
# Use Python 3.9 slim image as base
# This gives us a small image size while still providing Python functionality
FROM python:3.9-slim

# Add metadata to the image
LABEL maintainer="k8s-zero-hero@example.com"
LABEL version="1.0.0"
LABEL description="Kubernetes Zero to Hero Master Application"

# Set working directory inside the container
# This is where our application code will live
WORKDIR /app

# Install system dependencies
# We need curl for health checks and debugging
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create volume mount points with proper permissions
# These directories will be where our host volumes are mounted
RUN mkdir -p /data /config /logs && \
    chmod 777 /data /config /logs

# Copy requirements file and install dependencies
# We do this before copying the rest of the code to leverage Docker's layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .
RUN chmod +x app.py

# Expose the port the app will run on
EXPOSE 5000

# Add custom health check script
RUN echo '#!/bin/sh' > /healthcheck.sh && \
    echo 'curl -s http://localhost:5000/api/health || exit 1' >> /healthcheck.sh && \
    chmod +x /healthcheck.sh

# Set up a non-root user for security
RUN useradd -m appuser && \
    chown -R appuser:appuser /app /data /config /logs

# Switch to the non-root user
USER appuser

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_NAME="K8s Master App" \
    APP_VERSION="1.0.0" \
    ENVIRONMENT="production" \
    DATA_PATH="/data" \
    CONFIG_PATH="/config" \
    LOG_PATH="/logs"

# Start the application
CMD ["python", "app.py"]

# Add HEALTHCHECK instruction to check container health
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD /healthcheck.sh
EOL

echo -e "${GREEN}✓ Application files created${NC}"

# ===== STEP 4: CREATE KUBERNETES MANIFEST FILES =====
echo -e "${MAGENTA}[STEP 4] CREATING KUBERNETES MANIFESTS${NC}"
echo -e "${CYAN}Creating Kubernetes configuration files...${NC}"

# Create namespace.yaml
# Namespaces provide isolation between resources in a Kubernetes cluster
cat > ${PROJECT_DIR}/k8s/base/namespace.yaml << 'EOL'
# Namespace: Virtual clusters within a Kubernetes cluster
# Purpose: Isolate resources, control access, and organize applications
#
# In our case, we use a namespace to isolate our application from others in the cluster.
# This is similar to having separate apartments in a building - each with their own space.
apiVersion: v1
kind: Namespace
metadata:
  name: k8s-demo
  labels:
    name: k8s-demo
    environment: demo
    app: k8s-master
EOL

# Create configmap.yaml
# ConfigMaps store non-sensitive configuration data
cat > ${PROJECT_DIR}/k8s/config/configmap.yaml << 'EOL'
# ConfigMap: Store non-sensitive configuration data
# Purpose: Decouple configuration from container images
#
# ConfigMaps are like recipe books for your application - they tell the app
# how it should behave without having to rebuild the container image.
# This makes your containers more portable and easier to configure.
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: k8s-demo
data:
  # These key-value pairs will be available as environment variables in the pods
  APP_NAME: "Kubernetes Zero to Hero"
  APP_VERSION: "1.0.0"
  ENVIRONMENT: "demo"
  DATA_PATH: "/data"
  CONFIG_PATH: "/config"
  LOG_PATH: "/logs"
  # You can also store configuration files directly in the ConfigMap
  app-settings.json: |
    {
      "logLevel": "info",
      "enableMetrics": true,
      "maxFileSizeMB": 10
    }
EOL

# Create secret.yaml
# Secrets store sensitive configuration data
cat > ${PROJECT_DIR}/k8s/config/secret.yaml << 'EOL'
# Secret: Store sensitive configuration data
# Purpose: Securely store credentials, tokens, keys, etc.
#
# Secrets are like ConfigMaps but for sensitive data. They're encoded (not encrypted)
# by default, but Kubernetes prevents them from being casually viewed.
# In production, you'd want to use a proper secret management system like Vault.
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: k8s-demo
type: Opaque
data:
  # Values must be base64 encoded
  # echo -n "dev-secret-key-12345" | base64
  SECRET_KEY: ZGV2LXNlY3JldC1rZXktMTIzNDU=
  # echo -n "password123" | base64
  DB_PASSWORD: cGFzc3dvcmQxMjM=
EOL

# Create persistent volume and claim for host directory
# PVs and PVCs handle storage in Kubernetes
cat > ${PROJECT_DIR}/k8s/volumes/volumes.yaml << EOL
# PersistentVolume: Actual storage in the cluster
# Purpose: Represent actual storage resources available to the cluster
#
# PVs are like storage lockers in an apartment building - they exist independently
# of the tenants (pods) and have their own lifecycle. They represent actual physical
# or network storage.
apiVersion: v1
kind: PersistentVolume
metadata:
  name: k8s-data-pv
  labels:
    type: local
    app: k8s-master
spec:
  storageClassName: standard
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/mnt/c/kubernetes/data"
    type: DirectoryOrCreate
---
# PersistentVolume for config
apiVersion: v1
kind: PersistentVolume
metadata:
  name: k8s-config-pv
  labels:
    type: local
    app: k8s-master
spec:
  storageClassName: standard
  capacity:
    storage: 500Mi
  accessModes:
    - ReadOnlyMany
  hostPath:
    path: "/mnt/c/kubernetes/config"
    type: DirectoryOrCreate
---
# PersistentVolume for logs
apiVersion: v1
kind: PersistentVolume
metadata:
  name: k8s-logs-pv
  labels:
    type: local
    app: k8s-master
spec:
  storageClassName: standard
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/mnt/c/kubernetes/logs"
    type: DirectoryOrCreate
---
# PersistentVolumeClaim: Request for storage by a pod
# Purpose: Request storage resources with specific properties
#
# PVCs are like rental agreements for storage lockers - they represent a request
# for a specific type of storage with certain characteristics.
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
  namespace: k8s-demo
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  selector:
    matchLabels:
      type: local
      app: k8s-master
---
# PVC for config
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: config-pvc
  namespace: k8s-demo
spec:
  storageClassName: standard
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 500Mi
  selector:
    matchLabels:
      type: local
      app: k8s-master
---
# PVC for logs
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: logs-pvc
  namespace: k8s-demo
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  selector:
    matchLabels:
      type: local
      app: k8s-master
EOL

# Create deployment.yaml
# Deployments manage the desired state of your application
cat > ${PROJECT_DIR}/k8s/base/deployment.yaml << 'EOL'
# Deployment: Declaratively manages a set of pods
# Purpose: Ensure pods are running and updated according to a desired state
#
# Deployments are like restaurant managers who ensure there are always enough
# chefs (pods) working in the kitchen. If a chef quits or gets sick, the manager
# hires a new one to maintain the desired staffing level.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: k8s-master-app
  namespace: k8s-demo
  labels:
    app: k8s-master
spec:
  # Number of identical pod replicas to maintain
  replicas: 2
  
  # Strategy defines how pods should be updated
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1  # Maximum number of pods that can be unavailable during update
      maxSurge: 1        # Maximum number of pods that can be created over desired number
  
  # Selector defines how the Deployment finds which Pods to manage
  selector:
    matchLabels:
      app: k8s-master
  
  # Pod template defines what each Pod should look like
  template:
    metadata:
      labels:
        app: k8s-master
      annotations:
        prometheus.io/scrape: "true"  # Tell Prometheus to scrape this pod for metrics
        prometheus.io/path: "/api/metrics"
        prometheus.io/port: "5000"
    spec:
      # Container specifications
      containers:
      - name: k8s-master-app
        image: k8s-master-app:latest
        imagePullPolicy: Never  # Use local image (for Minikube)
        
        # Ports to expose from the container
        ports:
        - containerPort: 5000
          name: http
        
        # Environment variables from ConfigMap
        envFrom:
        - configMapRef:
            name: app-config
        
        # Environment variables from Secret
        - secretRef:
            name: app-secrets
        
        # Volume mounts connect the container to volumes
        volumeMounts:
        - name: data-volume
          mountPath: /data
          readOnly: false
        - name: config-volume
          mountPath: /config
          readOnly: true
        - name: logs-volume
          mountPath: /logs
          readOnly: false
        
        # Resource limits and requests
        # These help Kubernetes schedule pods efficiently
        resources:
          requests:
            cpu: "100m"     # 0.1 CPU core
            memory: "128Mi"  # 128 MB of memory
          limits:
            cpu: "500m"     # 0.5 CPU core
            memory: "512Mi"  # 512 MB of memory
        
        # Liveness probe checks if the container is alive
        # If it fails, Kubernetes will restart the container
        livenessProbe:
          httpGet:
            path: /api/health
            port: http
          initialDelaySeconds: 30
          periodSeconds: 30
          timeoutSeconds: 5
          failureThreshold: 3
        
        # Readiness probe checks if the container is ready to serve traffic
        # If it fails, Kubernetes won't send traffic to it
        readinessProbe:
          httpGet:
            path: /api/health
            port: http
          initialDelaySeconds: 15
          periodSeconds: 10
          timeoutSeconds: 3
        
        # Startup probe gives the container time to initialize
        # This helps prevent premature restarts during slow startups
        startupProbe:
          httpGet:
            path: /api/health
            port: http
          initialDelaySeconds: 5
          periodSeconds: 5
          failureThreshold: 12  # Allow 1 minute (12 * 5s) for startup
      
      # Volumes define storage that can be mounted into containers
      volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: data-pvc
      - name: config-volume
        persistentVolumeClaim:
          claimName: config-pvc
      - name: logs-volume
        persistentVolumeClaim:
          claimName: logs-pvc
EOL

# Create service.yaml
# Services expose your application to the network
cat > ${PROJECT_DIR}/k8s/networking/service.yaml << 'EOL'
# Service: Stable endpoint to access pods
# Purpose: Provide a stable IP and DNS name to access a set of pods
#
# Services are like a restaurant's phone number - customers call one number
# and get connected to available staff. It doesn't matter which specific
# employee answers, and employees can change without affecting the phone number.
apiVersion: v1
kind: Service
metadata:
  name: k8s-master-app
  namespace: k8s-demo
  labels:
    app: k8s-master
  annotations:
    service.beta.kubernetes.io/description: "Exposes the K8s Master App"
spec:
  # Type: 
  # - ClusterIP (default): Internal only
  # - NodePort: Exposes on Node IP at a static port
  # - LoadBalancer: Exposes externally using cloud provider's load balancer
  type: NodePort
  
  # Selector determines which pods this service will route traffic to
  selector:
    app: k8s-master
  
  # Port mappings
  ports:
  - name: http
    port: 80             # Port exposed by the service inside the cluster
    targetPort: 5000     # Port the container accepts traffic on
    nodePort: 30080      # Port on the node (range 30000-32767)
    protocol: TCP

  # Session affinity: Determines if connections from a client go to the same pod
  sessionAffinity: None
EOL

# Create ingress.yaml
# Ingress provides HTTP routing to services
cat > ${PROJECT_DIR}/k8s/networking/ingress.yaml << 'EOL'
# Ingress: HTTP/HTTPS routing rules
# Purpose: Route external HTTP/S traffic to internal services
#
# Ingress is like the maitre d' at a restaurant - they examine what each
# customer is asking for and direct them to the appropriate section or table.
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: k8s-master-ingress
  namespace: k8s-demo
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    kubernetes.io/ingress.class: "nginx"
spec:
  # TLS configuration (commented out for demo)
  # tls:
  # - hosts:
  #   - k8s-master.example.com
  #   secretName: tls-secret
  rules:
  - host: k8s-master.local  # Add this to your /etc/hosts file: 127.0.0.1 k8s-master.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: k8s-master-app
            port:
              number: 80
  # Default backend for requests that don't match any rules
  # defaultBackend:
  #   service:
  #     name: default-http-backend
  #     port:
  #       number: 80
EOL

# Create HorizontalPodAutoscaler for auto-scaling
# HPA automatically scales pods based on resource usage
cat > ${PROJECT_DIR}/k8s/monitoring/hpa.yaml << 'EOL'
# HorizontalPodAutoscaler: Automatically scale pods based on metrics
# Purpose: Dynamically adjust number of pods based on CPU/memory usage
#
# HPA is like a restaurant manager who adds or removes staff based on
# how busy the restaurant is. More customers = more staff needed.
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: k8s-master-hpa
  namespace: k8s-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: k8s-master-app
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 120
EOL

# Create ResourceQuota to limit resource usage in the namespace
cat > ${PROJECT_DIR}/k8s/monitoring/resourcequota.yaml << 'EOL'
# ResourceQuota: Limit resource usage in a namespace
# Purpose: Set hard limits on resource consumption
#
# ResourceQuota is like a family budget that ensures no single expense
# category uses up all available funds. It prevents one application from
# consuming all cluster resources.
apiVersion: v1
kind: ResourceQuota
metadata:
  name: k8s-demo-quota
  namespace: k8s-demo
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "10"
    services: "5"
    configmaps: "10"
    secrets: "10"
    persistentvolumeclaims: "5"
EOL

# Create NetworkPolicy for network segmentation
# NetworkPolicies specify how pods communicate with each other
cat > ${PROJECT_DIR}/k8s/networking/networkpolicy.yaml << 'EOL'
# NetworkPolicy: Define how pods communicate with each other
# Purpose: Create network security rules for pod communication
#
# NetworkPolicy is like security rules at a building - it defines
# who can talk to whom, and helps prevent unauthorized access.
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: k8s-master-network-policy
  namespace: k8s-demo
spec:
  podSelector:
    matchLabels:
      app: k8s-master
  # Allow ingress traffic from these sources
  ingress:
  - from:
    # Allow traffic from pods with app=k8s-master label
    - podSelector:
        matchLabels:
          app: k8s-master
    # Allow traffic from all pods in the k8s-demo namespace
    - namespaceSelector:
        matchLabels:
          name: k8s-demo
    ports:
    - protocol: TCP
      port: 5000
  # Allow egress traffic to these destinations
  egress:
  - to:
    # Allow traffic to pods with app=k8s-master label
    - podSelector:
        matchLabels:
          app: k8s-master
    ports:
    - protocol: TCP
      port: 5000
  # This enables policy enforcement for both ingress and egress
  policyTypes:
  - Ingress
  - Egress
EOL

echo -e "${GREEN}✓ Kubernetes manifests created${NC}"

# ===== STEP 5: CREATE DEPLOYMENT SCRIPT =====
echo -e "${MAGENTA}[STEP 5] CREATING DEPLOYMENT SCRIPTS${NC}"
echo -e "${CYAN}Creating scripts to deploy the application to Kubernetes...${NC}"

# Main deployment script
cat > ${PROJECT_DIR}/scripts/deploy.sh << 'EOL'
#!/bin/bash
# Deployment script for the Kubernetes Zero to Hero application
# This script automates the entire deployment process to Minikube

# Color definitions for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}             KUBERNETES ZERO TO HERO - DEPLOYMENT                     ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Step 1: Check prerequisites
echo -e "${MAGENTA}[STEP 1] CHECKING PREREQUISITES${NC}"

# Check for required tools
for tool in minikube kubectl docker; do
    if ! command_exists $tool; then
        echo -e "${RED}Error: $tool is not installed. Please install it and try again.${NC}"
        exit 1
    fi
    echo -e "${CYAN}✓ $tool is installed${NC}"
done

# Step 2: Ensure Minikube is running
echo -e "${MAGENTA}[STEP 2] ENSURING MINIKUBE IS RUNNING${NC}"

if ! minikube status | grep -q "host: Running"; then
    echo -e "${YELLOW}Minikube is not running. Starting Minikube...${NC}"
    
    # Start Minikube with appropriate configuration
    # We're mounting the host directory to make it available in Minikube
    minikube start --cpus=2 --memory=4096 --disk-size=20g --mount --mount-string="/mnt/c/kubernetes:/mnt/c/kubernetes"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to start Minikube. Exiting.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Minikube is already running${NC}"
    
    # Ensure the mount is active
    if ! minikube ssh -- "test -d /mnt/c/kubernetes"; then
        echo -e "${YELLOW}Mount point not active. Mounting /mnt/c/kubernetes...${NC}"
        minikube mount /mnt/c/kubernetes:/mnt/c/kubernetes &
        MOUNT_PID=$!
        sleep 3
    else
        echo -e "${GREEN}✓ Mount point is active${NC}"
    fi
fi

# Step 3: Enable required Minikube addons
echo -e "${MAGENTA}[STEP 3] ENABLING MINIKUBE ADDONS${NC}"

# Enable the ingress addon
echo -e "${CYAN}Enabling Ingress addon...${NC}"
minikube addons enable ingress

# Enable metrics server for HPA
echo -e "${CYAN}Enabling Metrics Server for auto-scaling...${NC}"
minikube addons enable metrics-server

# Enable dashboard for visualization
echo -e "${CYAN}Enabling Dashboard...${NC}"
minikube addons enable dashboard

# Step 4: Configure Docker to use Minikube's Docker daemon
echo -e "${MAGENTA}[STEP 4] CONFIGURING DOCKER TO USE MINIKUBE${NC}"
echo -e "${CYAN}This allows us to build images directly into Minikube's registry${NC}"

eval $(minikube docker-env)
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to configure Docker to use Minikube. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker configured to use Minikube's registry${NC}"

# Step 5: Build the Docker image
echo -e "${MAGENTA}[STEP 5] BUILDING DOCKER IMAGE${NC}"

echo -e "${CYAN}Building k8s-master-app:latest image...${NC}"
cd ~/k8s-master-app/app
docker build -t k8s-master-app:latest .

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to build Docker image. Exiting.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker image built successfully${NC}"
docker images | grep k8s-master-app

# Step 6: Apply Kubernetes manifests
echo -e "${MAGENTA}[STEP 6] DEPLOYING TO KUBERNETES${NC}"
cd ~/k8s-master-app

echo -e "${CYAN}Creating namespace...${NC}"
kubectl apply -f k8s/base/namespace.yaml

echo -e "${CYAN}Creating persistent volumes and claims...${NC}"
kubectl apply -f k8s/volumes/volumes.yaml

echo -e "${CYAN}Creating ConfigMap...${NC}"
kubectl apply -f k8s/config/configmap.yaml

echo -e "${CYAN}Creating Secret...${NC}"
kubectl apply -f k8s/config/secret.yaml

echo -e "${CYAN}Creating Deployment...${NC}"
kubectl apply -f k8s/base/deployment.yaml

echo -e "${CYAN}Creating Service...${NC}"
kubectl apply -f k8s/networking/service.yaml

echo -e "${CYAN}Creating Ingress...${NC}"
kubectl apply -f k8s/networking/ingress.yaml

echo -e "${CYAN}Creating NetworkPolicy...${NC}"
kubectl apply -f k8s/networking/networkpolicy.yaml

echo -e "${CYAN}Creating HorizontalPodAutoscaler...${NC}"
kubectl apply -f k8s/monitoring/hpa.yaml

echo -e "${CYAN}Creating ResourceQuota...${NC}"
kubectl apply -f k8s/monitoring/resourcequota.yaml

echo -e "${GREEN}✓ All Kubernetes resources applied${NC}"

# Step 7: Wait for deployment to be ready
echo -e "${MAGENTA}[STEP 7] WAITING FOR DEPLOYMENT TO BE READY${NC}"
echo -e "${CYAN}This may take a minute or two...${NC}"

echo "Waiting for deployment to be ready..."
kubectl -n k8s-demo rollout status deployment/k8s-master-app --timeout=180s

if [ $? -ne 0 ]; then
    echo -e "${RED}Deployment failed to become ready within the timeout period.${NC}"
    echo -e "${YELLOW}Checking pod status...${NC}"
    kubectl -n k8s-demo get pods
    
    echo -e "${YELLOW}Checking pod logs...${NC}"
    POD=$(kubectl -n k8s-demo get pods -l app=k8s-master -o name | head -1)
    if [ ! -z "$POD" ]; then
        kubectl -n k8s-demo logs $POD
    fi
else
    echo -e "${GREEN}✓ Deployment is ready${NC}"
fi

# Step 8: Set up port forwarding for easier access
echo -e "${MAGENTA}[STEP 8] SETTING UP PORT FORWARDING${NC}"
echo -e "${CYAN}This will make the application accessible on localhost${NC}"

# Check if port forwarding is already running
if pgrep -f "kubectl.*port-forward.*k8s-demo" > /dev/null; then
    echo -e "${YELLOW}Port forwarding is already running. Stopping it...${NC}"
    pkill -f "kubectl.*port-forward.*k8s-demo"
fi

# Start port forwarding in the background
kubectl -n k8s-demo port-forward svc/k8s-master-app 8080:80 &
PORT_FORWARD_PID=$!

# Give it a moment to start
sleep 2

# Check if port forwarding started successfully
if ! ps -p $PORT_FORWARD_PID > /dev/null; then
    echo -e "${RED}Failed to start port forwarding.${NC}"
else
    echo -e "${GREEN}✓ Port forwarding started on port 8080${NC}"
fi

# Step 9: Set up Ingress access
echo -e "${MAGENTA}[STEP 9] SETTING UP INGRESS ACCESS${NC}"

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo -e "${YELLOW}To access via Ingress, add this line to your /etc/hosts file:${NC}"
echo "$MINIKUBE_IP k8s-master.local"

# Step 10: Display access information
echo -e "${MAGENTA}[STEP 10] DEPLOYMENT COMPLETE${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}Kubernetes Zero to Hero application has been deployed!${NC}"
echo -e "${BLUE}======================================================================${NC}"

echo -e "${YELLOW}Your application is accessible via multiple methods:${NC}"
echo ""
echo -e "${CYAN}1. Port Forwarding:${NC}"
echo "   URL: http://localhost:8080"
echo "   (This is running in the background with PID $PORT_FORWARD_PID)"
echo ""
echo -e "${CYAN}2. NodePort:${NC}"
echo "   URL: http://$MINIKUBE_IP:30080"
echo ""
echo -e "${CYAN}3. Ingress:${NC}"
echo "   URL: http://k8s-master.local"
echo "   (Requires adding entry to /etc/hosts file as mentioned above)"
echo ""
echo -e "${CYAN}4. Minikube Service URL:${NC}"
MINIKUBE_SERVICE_URL=$(minikube service k8s-master-app -n k8s-demo --url)
echo "   URL: $MINIKUBE_SERVICE_URL"
echo ""

# Step 11: Display useful commands
echo -e "${BLUE}======================================================================${NC}"
echo -e "${YELLOW}USEFUL COMMANDS:${NC}"
echo -e "${BLUE}======================================================================${NC}"

echo -e "${CYAN}View the Kubernetes Dashboard:${NC}"
echo "   minikube dashboard"
echo ""
echo -e "${CYAN}View application logs:${NC}"
echo "   kubectl -n k8s-demo logs -l app=k8s-master"
echo ""
echo -e "${CYAN}Get a shell into a pod:${NC}"
echo "   kubectl -n k8s-demo exec -it $(kubectl -n k8s-demo get pods -l app=k8s-master -o name | head -1) -- /bin/bash"
echo ""
echo -e "${CYAN}View all resources in the namespace:${NC}"
echo "   kubectl -n k8s-demo get all"
echo ""
echo -e "${CYAN}Check pod resource usage:${NC}"
echo "   kubectl -n k8s-demo top pods"
echo ""
echo -e "${CYAN}Clean up all resources:${NC}"
echo "   ./scripts/cleanup.sh"
echo ""
echo -e "${CYAN}Stop port forwarding:${NC}"
echo "   kill $PORT_FORWARD_PID"
echo ""

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}DEPLOYMENT SUCCESSFUL!${NC}"
echo -e "${BLUE}======================================================================${NC}"
EOL

# Create cleanup script
cat > ${PROJECT_DIR}/scripts/cleanup.sh << 'EOL'
#!/bin/bash
# Cleanup script for Kubernetes Zero to Hero application
# This script removes all Kubernetes resources created for the application

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}             KUBERNETES ZERO TO HERO - CLEANUP                        ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# Step 1: Stop any port forwarding
echo -e "${CYAN}Stopping any port forwarding processes...${NC}"
pkill -f "kubectl -n k8s-demo port-forward" || true
echo -e "${GREEN}✓ Port forwarding stopped${NC}"

# Step 2: Delete all Kubernetes resources
echo -e "${CYAN}Deleting all resources in k8s-demo namespace...${NC}"
kubectl delete namespace k8s-demo

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ All resources in k8s-demo namespace deleted${NC}"
else
    echo -e "${RED}Failed to delete namespace. Trying individual resources...${NC}"
    
    # Delete resources in reverse order of creation
    kubectl delete -f ~/k8s-master-app/k8s/monitoring/resourcequota.yaml || true
    kubectl delete -f ~/k8s-master-app/k8s/monitoring/hpa.yaml || true
    kubectl delete -f ~/k8s-master-app/k8s/networking/networkpolicy.yaml || true
    kubectl delete -f ~/k8s-master-app/k8s/networking/ingress.yaml || true
    kubectl delete -f ~/k8s-master-app/k8s/networking/service.yaml || true
    kubectl delete -f ~/k8s-master-app/k8s/base/deployment.yaml || true
    kubectl delete -f ~/k8s-master-app/k8s/config/secret.yaml || true
    kubectl delete -f ~/k8s-master-app/k8s/config/configmap.yaml || true
    kubectl delete -f ~/k8s-master-app/k8s/volumes/volumes.yaml || true
    kubectl delete -f ~/k8s-master-app/k8s/base/namespace.yaml || true
    
    echo -e "${YELLOW}Individual resource deletion complete${NC}"
fi

# Step 3: Delete Persistent Volumes (these might exist outside the namespace)
echo -e "${CYAN}Deleting Persistent Volumes...${NC}"
kubectl delete pv k8s-data-pv k8s-config-pv k8s-logs-pv || true
echo -e "${GREEN}✓ Persistent Volumes deleted${NC}"

# Step 4: Stop any minikube mount processes
echo -e "${CYAN}Stopping any minikube mount processes...${NC}"
pkill -f "minikube mount" || true
echo -e "${GREEN}✓ Mount processes stopped${NC}"

# Step 5: Optional - clean up Docker images
echo -e "${CYAN}Cleaning up Docker images in Minikube...${NC}"
eval $(minikube docker-env)
docker rmi k8s-master-app:latest || true
echo -e "${GREEN}✓ Docker images cleaned up${NC}"

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}CLEANUP COMPLETE!${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "${YELLOW}You can restart the application by running ./scripts/deploy.sh${NC}"
EOL

# Create script for running load tests to demonstrate auto-scaling
cat > ${PROJECT_DIR}/scripts/load-test.sh << 'EOL'
#!/bin/bash
# Load test script for Kubernetes Zero to Hero application
# This script generates traffic to trigger the HorizontalPodAutoscaler

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}             KUBERNETES ZERO TO HERO - LOAD TEST                      ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# Check if the application is running
echo -e "${CYAN}Checking if the application is running...${NC}"
kubectl -n k8s-demo get deployment k8s-master-app &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}Application is not running. Please deploy it first.${NC}"
    exit 1
fi

# Get current pod count
CURRENT_PODS=$(kubectl -n k8s-demo get pods -l app=k8s-master | grep Running | wc -l)
echo -e "${GREEN}Current pod count: $CURRENT_PODS${NC}"

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo -e "${RED}curl is not installed. Please install it and try again.${NC}"
    exit 1
fi

# Get the application URL
MINIKUBE_IP=$(minikube ip)
APP_URL="http://$MINIKUBE_IP:30080"
echo -e "${CYAN}Application URL: $APP_URL${NC}"

# Function to run a single load test iteration
run_test_iteration() {
    local duration=$1
    local rate=$2
    
    echo -e "${YELLOW}Starting load test: $rate requests per second for $duration seconds${NC}"
    
    # Calculate total requests
    local total_requests=$((duration * rate))
    
    # Start time
    local start_time=$(date +%s)
    
    # Run curl in a loop
    for ((i=1; i<=total_requests; i++)); do
        curl -s "$APP_URL/api/metrics" > /dev/null &
        
        # Control the request rate by sleeping between requests
        if (( i % rate == 0 )); then
            sleep 1
        fi
    done
    
    # Wait for all curl processes to finish
    wait
    
    # End time
    local end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    
    echo -e "${GREEN}Test iteration complete: $total_requests requests in $elapsed seconds${NC}"
}

# Main load test function with progressive increase in load
run_load_test() {
    echo -e "${CYAN}Starting progressive load test...${NC}"
    echo -e "${CYAN}This will increase load over time to trigger autoscaling${NC}"
    
    # Check pod count before test
    echo -e "${YELLOW}Pod count before test:${NC}"
    kubectl -n k8s-demo get pods -l app=k8s-master
    
    # First iteration: Light load
    echo -e "${BLUE}--- Light Load Phase ---${NC}"
    run_test_iteration 30 5
    
    # Check pod count after light load
    echo -e "${YELLOW}Pod count after light load:${NC}"
    kubectl -n k8s-demo get pods -l app=k8s-master
    
    # Second iteration: Medium load
    echo -e "${BLUE}--- Medium Load Phase ---${NC}"
    run_test_iteration 30 15
    
    # Check pod count after medium load
    echo -e "${YELLOW}Pod count after medium load:${NC}"
    kubectl -n k8s-demo get pods -l app=k8s-master
    
    # Third iteration: Heavy load
    echo -e "${BLUE}--- Heavy Load Phase ---${NC}"
    run_test_iteration 30 30
    
    # Check pod count after heavy load
    echo -e "${YELLOW}Pod count after heavy load:${NC}"
    kubectl -n k8s-demo get pods -l app=k8s-master
    
    # Wait for HPA to stabilize
    echo -e "${CYAN}Waiting for HPA to stabilize...${NC}"
    sleep 30
    
    # Final pod count
    echo -e "${YELLOW}Final pod count:${NC}"
    kubectl -n k8s-demo get pods -l app=k8s-master
    
    # Show HPA status
    echo -e "${YELLOW}HPA status:${NC}"
    kubectl -n k8s-demo get hpa k8s-master-hpa
}

# Run the load test
run_load_test

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}LOAD TEST COMPLETE!${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "${YELLOW}The HPA may take a few minutes to scale down pods after the test.${NC}"
echo -e "${YELLOW}Monitor with: kubectl -n k8s-demo get hpa k8s-master-hpa -w${NC}"
EOL

# Make all scripts executable
chmod +x ${PROJECT_DIR}/scripts/deploy.sh
chmod +x ${PROJECT_DIR}/scripts/cleanup.sh
chmod +x ${PROJECT_DIR}/scripts/load-test.sh

echo -e "${GREEN}✓ Deployment scripts created${NC}"

# ===== STEP 6: CREATE README AND DOCUMENTATION =====
echo -e "${MAGENTA}[STEP 6] CREATING DOCUMENTATION${NC}"
echo -e "${CYAN}Creating README and documentation files...${NC}"

# Create a comprehensive README with explanations
cat > ${PROJECT_DIR}/README.md << 'EOL'
# Kubernetes Zero to Hero Application

This project demonstrates a complete Kubernetes application from zero to hero. It showcases various Kubernetes concepts including:

- Volume mounting from host to pods
- ConfigMaps and Secrets for configuration
- Multiple networking access methods (NodePort, Ingress)
- Health checks and probes
- Auto-scaling with HorizontalPodAutoscaler
- Resource management
- Network policies
- And much more!

## Prerequisites

- Minikube
- kubectl
- Docker
- WSL2 (if using Windows)

## Project Structure

```
k8s-master-app/
├── app/                   # Application code
│   ├── app.py             # Flask application
│   ├── Dockerfile         # Container definition
│   └── requirements.txt   # Python dependencies
├── k8s/                   # Kubernetes manifests
│   ├── base/              # Core resources
│   │   ├── deployment.yaml
│   │   └── namespace.yaml
│   ├── config/            # Configuration resources
│   │   ├── configmap.yaml
│   │   └── secret.yaml
│   ├── monitoring/        # Monitoring resources
│   │   ├── hpa.yaml
│   │   └── resourcequota.yaml
│   ├── networking/        # Networking resources
│   │   ├── ingress.yaml
│   │   ├── networkpolicy.yaml
│   │   └── service.yaml
│   └── volumes/           # Storage resources
│       └── volumes.yaml
└── scripts/               # Helper scripts
    ├── cleanup.sh         # Clean up all resources
    ├── deploy.sh          # Deploy the application
    └── load-test.sh       # Run load tests to demonstrate auto-scaling
```

## Quick Start

1. Ensure Prerequisites are installed
2. Run the deployment script:

```bash
cd ~/k8s-master-app
./scripts/deploy.sh
```

3. Access the application via one of these methods:
   - Port Forwarding: http://localhost:8080
   - NodePort: http://<minikube-ip>:30080
   - Ingress: http://k8s-master.local (requires hosts file entry)

## Key Concepts Demonstrated

### 1. Pods and Containers

Pods are the smallest deployable units in Kubernetes. In this project, each pod contains:
- Our Flask application container
- Shared storage volumes
- Resource limits and requests

### 2. Volume Mounting

This project mounts three volumes from the host:
- `/mnt/c/kubernetes/data` -> `/data` in the container
- `/mnt/c/kubernetes/config` -> `/config` in the container
- `/mnt/c/kubernetes/logs` -> `/logs` in the container

This demonstrates how to persist data and share files between the host and containers.

### 3. ConfigMaps and Secrets

ConfigMaps store non-sensitive configuration settings:
- Application name, version, environment
- Path configurations
- Feature flags

Secrets store sensitive data:
- API keys
- Database passwords
- Session keys

### 4. Networking and Exposure

The application is exposed through multiple methods:
- Service (NodePort): For direct access via Node IP and port
- Ingress: For host-based routing
- Port Forwarding: For easy local development access

### 5. Health Checks and Probes

The application implements three types of probes:
- Liveness: Determines if the container should be restarted
- Readiness: Determines if the container can receive traffic
- Startup: Gives the container time to initialize

### 6. Auto-scaling

HorizontalPodAutoscaler automatically adjusts the number of pods based on:
- CPU utilization
- Memory utilization

The load-test script demonstrates this feature by generating traffic.

### 7. Resource Management

The application defines:
- Resource requests: Minimum resources required
- Resource limits: Maximum resources allowed
- ResourceQuota: Namespace-level resource constraints

### 8. Network Policies

NetworkPolicy defines how pods communicate with each other:
- Who can send traffic to our application
- Where our application can send traffic

## Exploring the Demo

The application has several features to demonstrate Kubernetes concepts:
- View mounted files from host volumes
- Create new files in the data volume
- View pod information and resource usage
- Access API endpoints
- View environment variables from ConfigMaps and Secrets

## Cleaning Up

To remove all resources created by this demo:

```bash
./scripts/cleanup.sh
```

## Learn More

Each file in this project contains detailed comments explaining:
- What the resource is
- Why we're using it
- How it fits into the overall architecture
- Real-world analogies to help understand concepts

Explore the files to learn more about each Kubernetes concept!
EOL

# Create a Kubernetes Concepts cheat sheet
cat > ${PROJECT_DIR}/k8s-concepts.md << 'EOL'
# Kubernetes Concepts Cheat Sheet

## Core Components

### Control Plane Components

| Component | Role | Analogy |
|-----------|------|---------|
| **API Server** | Front-end to the control plane | Restaurant receptionist taking all customer requests |
| **etcd** | Key-value store for cluster data | Restaurant's reservation book and records |
| **Scheduler** | Assigns pods to nodes | Restaurant host assigning customers to tables |
| **Controller Manager** | Runs controller processes | Restaurant manager ensuring everything runs smoothly |

### Node Components

| Component | Role | Analogy |
|-----------|------|---------|
| **kubelet** | Ensures containers are running | Waiter making sure each table has what it needs |
| **kube-proxy** | Maintains network rules | Traffic director ensuring food gets to right tables |
| **Container Runtime** | Runs containers | The kitchen that prepares the food |

## Resource Types

### Workload Resources

| Resource | Purpose | Analogy |
|----------|---------|---------|
| **Pod** | Smallest deployable unit | A single chef in the kitchen |
| **Deployment** | Manages pod replicas | Restaurant manager ensuring enough chefs |
| **StatefulSet** | For stateful applications | Specialized kitchen stations that can't be interchanged |
| **DaemonSet** | Runs a pod on every node | Maintenance staff - one per location |
| **Job/CronJob** | Run-to-completion tasks | Special event catering or scheduled cleaning |

### Service Resources

| Resource | Purpose | Analogy |
|----------|---------|---------|
| **Service** | Stable endpoint for pods | Restaurant phone number to reach available staff |
| **Ingress** | HTTP(S) routing rules | Maitre d' directing customers to their tables |
| **NetworkPolicy** | Pod network access control | Security guards controlling who enters/exits |

### Config and Storage Resources

| Resource | Purpose | Analogy |
|----------|---------|---------|
| **ConfigMap** | Non-sensitive configuration | Recipe books for the chefs |
| **Secret** | Sensitive configuration | Secret recipe vault |
| **PersistentVolume** | Storage resource | Restaurant's food storage facility |
| **PersistentVolumeClaim** | Storage request | Chef's request for ingredients from storage |

### Metadata Resources

| Resource | Purpose | Analogy |
|----------|---------|---------|
| **Namespace** | Virtual cluster | Different departments in a company |
| **ResourceQuota** | Resource usage limits | Department budget limits |
| **LimitRange** | Default resource constraints | Standard expense limits per employee |

## Key Concepts

### Labels and Selectors

- **Labels**: Key-value pairs attached to resources
- **Selectors**: Filter resources based on labels
- **Analogy**: Tags on restaurant items (vegan, gluten-free) and customers selecting based on those tags

### Annotations

- Non-identifying metadata for resources
- Not used for selection by Kubernetes
- **Analogy**: Notes added to a recipe that don't change how it's prepared

### Probes

- **Liveness Probe**: Determines if a container is running properly
- **Readiness Probe**: Determines if a container can receive traffic
- **Startup Probe**: Determines if a container has started successfully
- **Analogy**: Health inspectors checking if restaurant stations are operational

### Resources and Scaling

- **Requests**: Minimum resources needed
- **Limits**: Maximum resources allowed
- **HorizontalPodAutoscaler**: Auto-scale based on metrics
- **VerticalPodAutoscaler**: Auto-adjust resource requests
- **Analogy**: Staffing levels based on restaurant busyness

## Common kubectl Commands

```bash
# Get resources
kubectl get pods                  # List all pods in current namespace
kubectl get all -n <namespace>    # List all resources in namespace
kubectl get pods -o wide          # List pods with more details

# Describe resources (detailed info)
kubectl describe pod <pod-name>   # Show detailed pod information

# Logs
kubectl logs <pod-name>           # Show pod logs
kubectl logs -f <pod-name>        # Stream pod logs

# Exec (run commands in pod)
kubectl exec -it <pod-name> -- /bin/bash  # Open shell in pod

# Apply/Delete resources
kubectl apply -f file.yaml        # Create/update resources from file
kubectl delete -f file.yaml       # Delete resources from file

# Port forwarding
kubectl port-forward svc/<service> 8080:80  # Forward local 8080 to service 80

# Context and namespace
kubectl config use-context <context>  # Switch to different cluster
kubectl config set-context --current --namespace=<namespace>  # Set default namespace
```
EOL

echo -e "${GREEN}✓ Documentation created${NC}"

# ===== FINAL STEP: MAKE SCRIPTS EXECUTABLE AND PRINT COMPLETION MESSAGE =====
chmod +x ${PROJECT_DIR}/scripts/deploy.sh
chmod +x ${PROJECT_DIR}/scripts/cleanup.sh
chmod +x ${PROJECT_DIR}/scripts/load-test.sh

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}KUBERNETES ZERO TO HERO PROJECT CREATED SUCCESSFULLY!${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo ""
echo -e "${YELLOW}Project directory:${NC} ${PROJECT_DIR}"
echo ""
echo -e "${CYAN}To deploy the application, run:${NC}"
echo -e "cd ${PROJECT_DIR}"
echo -e "./scripts/deploy.sh"
echo ""
echo -e "${CYAN}To clean up after you're done, run:${NC}"
echo -e "./scripts/cleanup.sh"
echo ""
echo -e "${CYAN}To run a load test for auto-scaling, run:${NC}"
echo -e "./scripts/load-test.sh"
echo ""
echo -e "${GREEN}This completes the Kubernetes Zero to Hero setup.${NC}"
echo -e "${GREEN}Explore the files to learn more about each Kubernetes concept!${NC}"
