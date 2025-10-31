#!/bin/bash

# Exit on error
set -e

echo "========== SIMPLE KUBERNETES MONITORING SETUP =========="

# Reset Minikube if requested
read -p "Do you want to reset Minikube? (y/n): " reset_choice
if [[ "$reset_choice" == "y" ]]; then
  echo "Stopping and deleting Minikube..."
  minikube stop || true
  minikube delete || true
  
  echo "Starting fresh Minikube cluster..."
  minikube start --driver=docker --cpus=2 --memory=3072
else
  echo "Using existing Minikube cluster..."
fi

# Verify Minikube
echo "Checking Minikube status..."
minikube status
kubectl get nodes

# Create a sample app
echo "Creating a sample application with logging..."
kubectl create namespace sample-app 2>/dev/null || true

# Create a simple app that generates logs
cat <<EOF > sample-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-logger
  namespace: sample-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample-logger
  template:
    metadata:
      labels:
        app: sample-logger
    spec:
      containers:
      - name: logger
        image: busybox
        command: ["/bin/sh", "-c"]
        args:
        - >
          while true; do
            echo "[INFO] Log entry at \$(date)";
            sleep 3;
            echo "[DEBUG] Processing data...";
            sleep 2;
            if [ \$((RANDOM % 10)) -eq 0 ]; then
              echo "[ERROR] Sample error occurred!";
            fi;
            sleep 1;
          done
        resources:
          requests:
            memory: "32Mi"
            cpu: "50m"
          limits:
            memory: "64Mi"
            cpu: "100m"
EOF

kubectl apply -f sample-app.yaml

# Install Prometheus
echo "Installing Prometheus..."

# Clean up monitoring namespace if it exists
kubectl delete namespace monitoring 2>/dev/null || true
kubectl create namespace monitoring

# Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus with minimal settings
cat <<EOF > prometheus-values.yaml
alertmanager:
  enabled: false
pushgateway:
  enabled: false
server:
  persistentVolume:
    enabled: false
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 200m
      memory: 512Mi
EOF

helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --values prometheus-values.yaml

# Wait for the prometheus server pod to be running
echo "Waiting for Prometheus server pod to start..."
kubectl wait --for=condition=ready pod --selector="app.kubernetes.io/name=prometheus,app.kubernetes.io/component=server" -n monitoring --timeout=120s

# Install Loki + Promtail
echo "Installing Loki Stack..."
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set prometheus.enabled=false \
  --set loki.persistence.enabled=false

# Install Grafana with Prometheus and Loki datasources preconfigured
echo "Installing Grafana..."
cat <<EOF > grafana-values.yaml
persistence:
  enabled: false
adminPassword: admin
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.monitoring.svc.cluster.local
      access: proxy
      isDefault: true
    - name: Loki
      type: loki
      url: http://loki.monitoring.svc.cluster.local:3100
      access: proxy
dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: 'default'
      orgId: 1
      folder: ''
      type: file
      disableDeletion: false
      editable: true
      options:
        path: /var/lib/grafana/dashboards/default
dashboards:
  default:
    k8s-pod-logs:
      gnetId: 12019
      revision: 2
      datasource: Prometheus
    k8s-simple-dashboard:
      url: https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-global.json
EOF

# Install Grafana
helm install grafana grafana/grafana \
  --namespace monitoring \
  --values grafana-values.yaml

# Wait for Grafana to be ready
echo "Waiting for Grafana to be ready..."
kubectl wait --for=condition=ready pod --selector="app.kubernetes.io/name=grafana" -n monitoring --timeout=180s

# Create port-forward for Grafana
echo "Setting up port-forward for Grafana..."
kubectl port-forward svc/grafana -n monitoring 3000:80 &
PORT_FORWARD_PID=$!

# Create a simple custom dashboard
echo "Waiting 5 seconds for port-forward to stabilize..."
sleep 5

echo "Creating custom dashboard for our logs..."
cat <<EOF > dashboard.json
{
  "dashboard": {
    "title": "Application Logs",
    "uid": "app-logs",
    "panels": [
      {
        "id": 1,
        "title": "Sample App Logs",
        "type": "logs",
        "datasource": "Loki",
        "targets": [
          {
            "expr": "{namespace=\"sample-app\", app=\"sample-logger\"}"
          }
        ],
        "gridPos": {"h": 12, "w": 24, "x": 0, "y": 0},
        "options": {
          "showTime": true
        }
      },
      {
        "id": 2,
        "title": "Error Logs",
        "type": "logs",
        "datasource": "Loki",
        "targets": [
          {
            "expr": "{namespace=\"sample-app\"} |= \"ERROR\""
          }
        ],
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 12}
      }
    ],
    "refresh": "5s"
  },
  "folderUid": null,
  "overwrite": true
}
EOF

# Import dashboard
curl -s -X POST -H "Content-Type: application/json" -d @dashboard.json http://admin:admin@localhost:3000/api/dashboards/db

# Get access info
echo ""
echo "==========================================================="
echo "Setup complete! Access your monitoring dashboards:"
echo ""
echo "Grafana: http://localhost:3000"
echo "Username: admin"
echo "Password: admin"
echo ""
echo "Your dashboards should now be visible in Grafana"
echo ""
echo "To access Kubernetes Dashboard, run in a separate terminal:"
echo "minikube dashboard"
echo ""
echo "Press Ctrl+C when you're done to terminate port-forwarding"
echo "==========================================================="

# Keep script running to maintain port-forward
wait $PORT_FORWARD_PID
