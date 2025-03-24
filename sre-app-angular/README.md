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
   git clone https://github.com/yourusername/sre-app-angular.git
   cd sre-app-angular
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
