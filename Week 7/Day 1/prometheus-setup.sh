#!/bin/bash

set -e

echo "========== Prometheus Setup Script =========="
echo "This script will install and configure Prometheus in Minikube"

# Check if minikube is running
if ! minikube status &> /dev/null; then
  echo "Minikube is not running. Please start minikube first."
  exit 1
fi

# Create directory for Prometheus configuration
mkdir -p prometheus-config

# Create prometheus.yml configuration file
cat > prometheus-config/prometheus.yml << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "kubernetes-apiservers"
    kubernetes_sd_configs:
      - role: endpoints
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      insecure_skip_verify: true
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https

  - job_name: "kubernetes-nodes"
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      insecure_skip_verify: true
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - target_label: __address__
        replacement: kubernetes.default.svc:443
      - source_labels: [__meta_kubernetes_node_name]
        regex: (.+)
        target_label: __metrics_path__
        replacement: /api/v1/nodes/$1/proxy/metrics

  - job_name: "kubernetes-pods"
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement:  "\$1:\$2"
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: kubernetes_pod_name

  - job_name: "flask-app"
    static_configs:
      - targets: ["flask-api-service:5000"]
EOF

# Create Kubernetes manifests directory
mkdir -p k8s-manifests
NAMESPACE="sre-monitoring"

# Create Prometheus ConfigMap
cat > k8s-manifests/prometheus-configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: ${NAMESPACE}
data:
  prometheus.yml: |
$(sed 's/^/    /' prometheus-config/prometheus.yml)
EOF

# Create Prometheus Deployment
cat > k8s-manifests/prometheus-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: ${NAMESPACE}
  labels:
    app: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:v2.42.0
        args:
          - "--config.file=/etc/prometheus/prometheus.yml"
          - "--storage.tsdb.path=/prometheus"
          - "--storage.tsdb.retention.time=15d"
          - "--web.enable-lifecycle"
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: prometheus-config
          mountPath: /etc/prometheus
        - name: prometheus-storage
          mountPath: /prometheus
        resources:
          requests:
            cpu: 200m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-config
      - name: prometheus-storage
        emptyDir: {}
EOF

# Create Prometheus Service
cat > k8s-manifests/prometheus-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: ${NAMESPACE}
  labels:
    app: prometheus
spec:
  ports:
  - port: 9090
    targetPort: 9090
    name: web
  selector:
    app: prometheus
  type: ClusterIP
EOF

# Apply Kubernetes manifests
echo "Applying Prometheus Kubernetes manifests..."
kubectl apply -f k8s-manifests/prometheus-configmap.yaml
kubectl apply -f k8s-manifests/prometheus-deployment.yaml
kubectl apply -f k8s-manifests/prometheus-service.yaml

# Wait for Prometheus deployment to be ready
echo "Waiting for Prometheus deployment to be ready..."
kubectl -n ${NAMESPACE} rollout status deployment/prometheus

# Port-forward for local access (will run in background)
echo "Setting up port forwarding for Prometheus..."
nohup kubectl -n ${NAMESPACE} port-forward svc/prometheus 9090:9090 > /dev/null 2>&1 &
PROM_PORT_FORWARD_PID=$!

echo "==========================================="
echo "Prometheus has been successfully deployed!"
echo "Access the Prometheus UI at: http://localhost:9090"
echo "==========================================="
echo "Note: Port forwarding is running in the background with PID: ${PROM_PORT_FORWARD_PID}"
echo "To stop port forwarding: kill ${PROM_PORT_FORWARD_PID}"
