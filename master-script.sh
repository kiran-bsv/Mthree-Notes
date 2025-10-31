#!/bin/bash

set -e

echo "========== SRE Application Setup Master Script =========="
echo "This script will set up the complete SRE environment with WSL, Minikube, Prometheus, Grafana, Flask API, and Angular UI"

# Create directories for the project
PROJECT_ROOT="$HOME/sre-app"
mkdir -p "$PROJECT_ROOT"
cd "$PROJECT_ROOT"

# Create directories for different components
mkdir -p wsl-setup
mkdir -p k8s
mkdir -p flask-api
mkdir -p angular-ui
mkdir -p prometheus
mkdir -p grafana

echo "Creating WSL and Minikube setup script..."
cat > wsl-setup/setup-wsl-minikube.sh << 'EOF'
# Script content goes here - copy from WSL and Minikube Setup Script artifact
EOF
chmod +x wsl-setup/setup-wsl-minikube.sh

echo "Creating Prometheus setup script..."
cat > prometheus/setup-prometheus.sh << 'EOF'
# Script content goes here - copy from Prometheus Setup Script artifact
EOF
chmod +x prometheus/setup-prometheus.sh

echo "Creating Grafana setup script..."
cat > grafana/setup-grafana.sh << 'EOF'
# Script content goes here - copy from Grafana Setup Script artifact
EOF
chmod +x grafana/setup-grafana.sh

echo "Creating Flask API files..."
cat > flask-api/app.py << 'EOF'
# Script content goes here - copy from Flask API Backend Application artifact
EOF

cat > flask-api/requirements.txt << 'EOF'
flask==2.3.2
flask-cors==4.0.0
prometheus-client==0.17.1
gunicorn==21.2.0
EOF

cat > flask-api/Dockerfile << 'EOF'
# Dockerfile content - copy from Flask API Dockerfile artifact
EOF

echo "Creating Flask API Kubernetes configuration..."
mkdir -p k8s/flask-api
cat > k8s/flask-api/deployment.yaml << 'EOF'
# Kubernetes deployment content - copy from Flask API Dockerfile artifact
EOF

echo "Creating Angular files..."
mkdir -p angular-ui/src/app
mkdir -p angular-ui/src/environments
mkdir -p angular-ui/src/app/core/models
mkdir -p angular-ui/src/app/core/services
mkdir -p angular-ui/src/app/shared/components/metric-card
mkdir -p angular-ui/src/app/shared/components/alert-list
mkdir -p angular-ui/src/app/features/dashboard

# Create Angular files (this will be simplified since we'll create only the essential structure)
cat > angular-ui/package.json << 'EOF'
{
  "name": "sre-dashboard",
  "version": "0.0.0",
  "scripts": {
    "ng": "ng",
    "start": "ng serve",
    "build": "ng build",
    "watch": "ng build --watch --configuration development",
    "test": "ng test"
  },
  "private": true,
  "dependencies": {
    "@angular/animations": "^17.0.0",
    "@angular/common": "^17.0.0",
    "@angular/compiler": "^17.0.0",
    "@angular/core": "^17.0.0",
    "@angular/forms": "^17.0.0",
    "@angular/platform-browser": "^17.0.0",
    "@angular/platform-browser-dynamic": "^17.0.0",
    "@angular/router": "^17.0.0",
    "rxjs": "~7.8.0",
    "tslib": "^2.3.0",
    "zone.js": "~0.14.2"
  },
  "devDependencies": {
    "@angular-devkit/build-angular": "^17.0.0",
    "@angular/cli": "^17.0.0",
    "@angular/compiler-cli": "^17.0.0",
    "@types/jasmine": "~5.1.0",
    "jasmine-core": "~5.1.0",
    "karma": "~6.4.0",
    "karma-chrome-launcher": "~3.2.0",
    "karma-coverage": "~2.2.0",
    "karma-jasmine": "~5.1.0",
    "karma-jasmine-html-reporter": "~2.1.0",
    "typescript": "~5.2.2"
  }
}
EOF

cat > angular-ui/angular.json << 'EOF'
{
  "$schema": "./node_modules/@angular/cli/lib/config/schema.json",
  "version": 1,
  "newProjectRoot": "projects",
  "projects": {
    "sre-dashboard": {
      "projectType": "application",
      "schematics": {},
      "root": "",
      "sourceRoot": "src",
      "prefix": "app",
      "architect": {
        "build": {
          "builder": "@angular-devkit/build-angular:browser",
          "options": {
            "outputPath": "dist/sre-dashboard",
            "index": "src/index.html",
            "main": "src/main.ts",
            "polyfills": [
              "zone.js"
            ],
            "tsConfig": "tsconfig.app.json",
            "assets": [
              "src/favicon.ico",
              "src/assets"
            ],
            "styles": [
              "src/styles.css"
            ],
            "scripts": []
          },
          "configurations": {
            "production": {
              "budgets": [
                {
                  "type": "initial",
                  "maximumWarning": "500kb",
                  "maximumError": "1mb"
                },
                {
                  "type": "anyComponentStyle",
                  "maximumWarning": "2kb",
                  "maximumError": "4kb"
                }
              ],
              "outputHashing": "all"
            },
            "development": {
              "buildOptimizer": false,
              "optimization": false,
              "vendorChunk": true,
              "extractLicenses": false,
              "sourceMap": true,
              "namedChunks": true
            }
          },
          "defaultConfiguration": "production"
        },
        "serve": {
          "builder": "@angular-devkit/build-angular:dev-server",
          "configurations": {
            "production": {
              "browserTarget": "sre-dashboard:build:production"
            },
            "development": {
              "browserTarget": "sre-dashboard:build:development"
            }
          },
          "defaultConfiguration": "development"
        },
        "extract-i18n": {
          "builder": "@angular-devkit/build-angular:extract-i18n",
          "options": {
            "browserTarget": "sre-dashboard:build"
          }
        },
        "test": {
          "builder": "@angular-devkit/build-angular:karma",
          "options": {
            "polyfills": [
              "zone.js",
              "zone.js/testing"
            ],
            "tsConfig": "tsconfig.spec.json",
            "assets": [
              "src/favicon.ico",
              "src/assets"
            ],
            "styles": [
              "src/styles.css"
            ],
            "scripts": []
          }
        }
      }
    }
  }
}
EOF

cat > angular-ui/Dockerfile << 'EOF'
# Dockerfile content - copy from Angular Dockerfile artifact
EOF

cat > angular-ui/nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Forward API requests to the backend service
    location /api/ {
        proxy_pass http://flask-api-service:5000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

echo "Creating Angular Kubernetes configuration..."
mkdir -p k8s/angular-ui
cat > k8s/angular-ui/deployment.yaml << 'EOF'
# Kubernetes deployment content - copy from Angular Dockerfile artifact
EOF

# Create a README file
cat > README.md << 'EOF'
# SRE Application Setup

This repository contains all the necessary scripts and configurations to set up a complete SRE environment with:

- WSL (Windows Subsystem for Linux)
- Minikube
- Prometheus for monitoring
- Grafana for visualization
- Flask API backend
- Angular UI frontend

## Prerequisites

- Windows 10/11 with WSL capability
- Administrative privileges
- Internet connection

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/sre-app.git
   cd sre-app
   ```

2. Run the setup script:
   ```
   ./setup.sh
   ```

3. Follow the on-screen instructions.

## Accessing the Applications

After installation, you can access:

- Angular UI: http://localhost (via Minikube Ingress)
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (username: admin, password: admin)

## Features

- Complete SRE environment
- Metrics visualization
- CPU and memory usage monitoring
- Test utilities for simulating load
- Alert management

## Troubleshooting

If you encounter any issues, please check the logs:

```
kubectl logs -n sre-monitoring deployment/angular-ui
kubectl logs -n sre-monitoring deployment/flask-api
kubectl logs -n sre-monitoring deployment/prometheus
kubectl logs -n sre-monitoring deployment/grafana
```

## License

MIT
EOF

# Create the main setup script
cat > setup.sh << 'EOF'
#!/bin/bash

set -e

echo "========== SRE Application Setup Script =========="
echo "This script will set up the complete SRE environment"

# Check if running on Windows with WSL
if [[ "$(uname -r)" != *Microsoft* ]] && [[ "$(uname -r)" != *microsoft* ]]; then
  echo "This script is intended to be run on Windows with WSL."
  echo "If you've already installed WSL, you can continue. Otherwise, please install WSL first."
  read -p "Continue? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Step 1: Set up WSL and Minikube
echo "Step 1: Setting up WSL and Minikube..."
./wsl-setup/setup-wsl-minikube.sh

# Step 2: Build and deploy the Flask API
echo "Step 2: Building and deploying the Flask API..."
cd flask-api
docker build -t flask-api:latest .
cd ..

kubectl apply -f k8s/flask-api/deployment.yaml

# Step 3: Build and deploy the Angular UI
echo "Step 3: Building and deploying the Angular UI..."
cd angular-ui
# In a real script, we would build the Angular app here
# For brevity, we'll just build the Docker image
docker build -t angular-ui:latest .
cd ..

kubectl apply -f k8s/angular-ui/deployment.yaml

# Step 4: Set up Prometheus
echo "Step 4: Setting up Prometheus..."
./prometheus/setup-prometheus.sh

# Step 5: Set up Grafana
echo "Step 5: Setting up Grafana..."
./grafana/setup-grafana.sh

echo "==========================================="
echo "SRE Application setup completed successfully!"
echo "Access your applications at:"
echo "- Angular UI: http://$(minikube ip)"
echo "- Prometheus: http://localhost:9090 (port-forwarded)"
echo "- Grafana: http://localhost:3000 (port-forwarded)"
echo "  Username: admin"
echo "  Password: admin"
echo "==========================================="
EOF
chmod +x setup.sh

echo "==========================================="
echo "Project structure has been created at: $PROJECT_ROOT"
echo "To start the setup, run:"
echo "cd $PROJECT_ROOT"
echo "./setup.sh"
echo "==========================================="
echo "Note: The setup script expects you to edit the placeholder scripts"
echo "and replace them with the actual script content from the provided artifacts."
echo "=============================================
