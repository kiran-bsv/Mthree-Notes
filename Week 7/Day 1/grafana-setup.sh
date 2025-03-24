#!/bin/bash

set -e

echo "========== Grafana Setup Script =========="
echo "This script will install and configure Grafana in Minikube"

# Check if minikube is running
if ! minikube status &> /dev/null; then
  echo "Minikube is not running. Please start minikube first."
  exit 1
fi

# Create directory for Grafana configuration
mkdir -p grafana-config
NAMESPACE="sre-monitoring"

# Create Kubernetes manifests directory if not exists
mkdir -p k8s-manifests

# Create Grafana Deployment
cat > k8s-manifests/grafana-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: ${NAMESPACE}
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:9.5.2
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: GF_SECURITY_ADMIN_USER
          value: admin
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: admin
        - name: GF_USERS_ALLOW_SIGN_UP
          value: "false"
        - name: GF_INSTALL_PLUGINS
          value: "grafana-piechart-panel"
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-datasources
          mountPath: /etc/grafana/provisioning/datasources
        - name: grafana-dashboards-provider
          mountPath: /etc/grafana/provisioning/dashboards
        - name: grafana-dashboards
          mountPath: /var/lib/grafana/dashboards
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 200m
            memory: 512Mi
      volumes:
      - name: grafana-storage
        emptyDir: {}
      - name: grafana-datasources
        configMap:
          name: grafana-datasources
      - name: grafana-dashboards-provider
        configMap:
          name: grafana-dashboards-provider
      - name: grafana-dashboards
        configMap:
          name: grafana-dashboards
EOF

# Create Grafana Service
cat > k8s-manifests/grafana-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: ${NAMESPACE}
  labels:
    app: grafana
spec:
  ports:
  - port: 3000
    targetPort: 3000
    name: http
  selector:
    app: grafana
  type: ClusterIP
EOF

# Create Grafana datasources ConfigMap
mkdir -p grafana-config/datasources
cat > grafana-config/datasources/prometheus.yaml << EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
EOF

cat > k8s-manifests/grafana-datasources-configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: ${NAMESPACE}
data:
  prometheus.yaml: |
$(sed 's/^/    /' grafana-config/datasources/prometheus.yaml)
EOF

# Create Grafana dashboards provider ConfigMap
mkdir -p grafana-config/dashboards
cat > grafana-config/dashboards/provider.yaml << EOF
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 30
    options:
      path: /var/lib/grafana/dashboards
EOF

cat > k8s-manifests/grafana-dashboards-provider-configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboards-provider
  namespace: ${NAMESPACE}
data:
  provider.yaml: |
$(sed 's/^/    /' grafana-config/dashboards/provider.yaml)
EOF

# Create a basic dashboard with metrics
cat > grafana-config/dashboards/kubernetes-overview.json << EOF
{
  "annotations": {
    "list": []
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "panels": [
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "hiddenSeries": false,
      "id": 1,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.4.0",
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "sum(rate(container_cpu_usage_seconds_total{pod=~\"flask-api-.*|angular-ui-.*\"}[5m])) by (pod)",
          "interval": "",
          "legendFormat": "{{pod}}",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "CPU Usage by Pod",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "hiddenSeries": false,
      "id": 2,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.4.0",
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "sum(container_memory_working_set_bytes{pod=~\"flask-api-.*|angular-ui-.*\"}) by (pod)",
          "interval": "",
          "legendFormat": "{{pod}}",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Memory Usage by Pod",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "bytes",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 8
      },
      "hiddenSeries": false,
      "id": 3,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.4.0",
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "rate(http_requests_total{handler=\"/api\"}[5m])",
          "interval": "",
          "legendFormat": "{{handler}}",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "API Request Rate",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "short",
          "label": "Requests/s",
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 8
      },
      "hiddenSeries": false,
      "id": 4,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.4.0",
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "rate(http_request_duration_seconds_sum{handler=\"/api\"}[5m]) / rate(http_request_duration_seconds_count{handler=\"/api\"}[5m])",
          "interval": "",
          "legendFormat": "{{handler}}",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "API Response Time",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "s",
          "label": "Response Time",
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    }
  ],
  "refresh": "10s",
  "schemaVersion": 27,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "SRE Application Dashboard",
  "uid": "sre-k8s-dashboard",
  "version": 1
}
EOF

cat > k8s-manifests/grafana-dashboards-configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboards
  namespace: ${NAMESPACE}
data:
  kubernetes-overview.json: |
$(sed 's/^/    /' grafana-config/dashboards/kubernetes-overview.json)
EOF

# Apply Kubernetes manifests
echo "Applying Grafana Kubernetes manifests..."
kubectl apply -f k8s-manifests/grafana-datasources-configmap.yaml
kubectl apply -f k8s-manifests/grafana-dashboards-provider-configmap.yaml
kubectl apply -f k8s-manifests/grafana-dashboards-configmap.yaml
kubectl apply -f k8s-manifests/grafana-deployment.yaml
kubectl apply -f k8s-manifests/grafana-service.yaml

# Wait for Grafana deployment to be ready
echo "Waiting for Grafana deployment to be ready..."
kubectl -n ${NAMESPACE} rollout status deployment/grafana

# Port-forward for local access (will run in background)
echo "Setting up port forwarding for Grafana..."
nohup kubectl -n ${NAMESPACE} port-forward svc/grafana 3000:3000 > /dev/null 2>&1 &
GRAFANA_PORT_FORWARD_PID=$!

echo "==========================================="
echo "Grafana has been successfully deployed!"
echo "Access Grafana UI at: http://localhost:3000"
echo "Default login credentials: admin/admin"
echo "==========================================="
echo ""
echo "Grafana Instructions:"
echo "1. After logging in with the default credentials (admin/admin), you'll be prompted to change the password."
echo "2. The Prometheus data source is already configured."
echo "3. A basic SRE dashboard has been pre-configured with key metrics."
echo "4. To create additional dashboards:"
echo "   - Click on '+ Create' in the left sidebar menu"
echo "   - Select 'Dashboard' to create a new dashboard"
echo "   - Click 'Add new panel' to add monitoring metrics"
echo "   - In the query panel, you can use PromQL to query metrics from Prometheus"
echo "5. For monitoring Angular and Flask applications:"
echo "   - Use metrics like 'http_requests_total' for request counts"
echo "   - 'http_request_duration_seconds' for response times"
echo "   - 'container_memory_usage_bytes' and 'container_cpu_usage_seconds_total' for resource usage"
echo "6. To set up alerts:"
echo "   - Go to Alerting in the left sidebar"
echo "   - Click 'Create Alert Rule' to set up new alerts"
echo "   - Configure alerts for response time thresholds, error rates, or resource usage"
echo ""
echo "Note: Port forwarding is running in the background with PID: ${GRAFANA_PORT_FORWARD_PID}"
echo "To stop port forwarding: kill ${GRAFANA_PORT_FORWARD_PID}"
