# **SRE Monitoring**

## **Core Features**
- **Streamlined Minikube Deployment**: Automates Minikube setup, ensuring a fresh environment for local Kubernetes testing.
- **Scalable Flask API**: Designed with Prometheus instrumentation for detailed request tracking, latency analysis, and error logging.
- **Resource-Efficient Kubernetes Architecture**: Optimized to run effectively with minimal CPU and memory consumption.
- **Comprehensive Monitoring Stack**:
  - **Prometheus**: Collects time-series metrics from the application and infrastructure.
  - **Loki**: Handles structured log storage and retrieval.
  - **Grafana**: Provides interactive dashboards for real-time insights.
- **Stress Testing & Performance Validation**: Simulates high-traffic scenarios to assess system reliability.

---

## **Application Architecture & Endpoints**
### **Flask-Based API Overview**
The API is structured to include key observability-focused endpoints:

- **Retrieve User Data (`/api/users`)**
  - Emulates a database query with variable response times.
  - Sample response:
    ```json
    [
      {"id": 101, "name": "John Doe", "email": "john@example.com"},
      {"id": 102, "name": "Jane Smith", "email": "jane@example.com"}
    ]
    ```
- **Echo Service (`/api/echo`)**
  - Accepts JSON payloads and returns the same data.
  - Example:
    ```json
    {"status": "success", "data": {"message": "Hello World"}}
    ```
- **Simulated Error Responses (`/api/error`)**
  - Generates errors for testing alerting mechanisms:
    - `?type=client` → Returns `400 Bad Request`.
    - Default behavior → Returns `500 Internal Server Error`.
- **Health & Readiness Probes**
  - **Liveness (`/health/liveness`)**: Ensures the app is running and responsive.
  - **Readiness (`/health/readiness`)**: Confirms dependencies are functional before accepting traffic.

---

## **Prometheus Metrics & Instrumentation**
The Flask app integrates with Prometheus to provide essential metrics:

- **Traffic & Request Monitoring**
  - `REQUEST_COUNT`: Total requests categorized by endpoint, method, and status code.
  - `REQUEST_LATENCY`: Response time distribution tracking.
- **Error Detection & Logging**
  - `ERROR_COUNTER`: Logs application errors by type and endpoint.
- **Resource Utilization**
  - `ACTIVE_REQUESTS`: Tracks ongoing request counts to prevent saturation.

#### **Middleware Hooks for Observability**
- **Request Start Hook**:
  ```python
  @app.before_request
  def start_request():
      request.start_time = time.time()
      ACTIVE_REQUESTS.inc()
  ```
- **Response Processing Hook**:
  ```python
  @app.after_request
  def process_response(response):
      request_duration = time.time() - request.start_time
      REQUEST_LATENCY.labels(endpoint=request.path, method=request.method).observe(request_duration)
      REQUEST_COUNT.labels(endpoint=request.path, method=request.method, http_status=response.status_code).inc()
      ACTIVE_REQUESTS.dec()
      return response
  ```

#### **Prometheus Metrics Endpoint (`/metrics`)**
```python
from prometheus_client import make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {'/metrics': make_wsgi_app()})
```

---

## **Log Aggregation with Loki & Promtail**
Loki collects structured logs, making debugging and tracing more efficient.

- **Standardized Logging Format**:
  ```python
  import logging
  logging.basicConfig(
      level=logging.INFO,
      format='%(asctime)s [%(levelname)s] %(message)s',
      datefmt='%Y-%m-%d %H:%M:%S'
  )
  ```
- **Automatic Error Logging Example**:
  ```python
  if random.random() < 0.05:  # Simulated 5% error rate
      ERROR_COUNTER.labels(error_type="db_failure", endpoint="/api/users").inc()
      logging.error("Database connection timeout occurred")
  ```
- **Promtail Configuration for Loki Integration**
  - Ensures logs from all Kubernetes pods are efficiently aggregated for analysis.

---

## **Lightweight Kubernetes Monitoring Stack**
### **Prometheus Configuration (`prometheus-values.yaml`)**
```yaml
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
      cpu: 250m
      memory: 512Mi
```

### **Loki Configuration (`loki-values.yaml`)**
```yaml
loki:
  persistence:
    enabled: false
  resources:
    requests:
      cpu: 50m
      memory: 128Mi
    limits:
      cpu: 150m
      memory: 256Mi
promtail:
  config:
    snippets:
      pipelineStages:
        - docker: {}
```

---

## **Key Observability Metrics in Prometheus**
- **Response Latency** (`app_request_latency_seconds`): Measures processing time.
- **Request Volume** (`app_request_count`): Tracks API traffic trends.
- **Error Rate** (`app_error_count`): Identifies failure patterns.
- **Active Requests** (`app_active_requests`): Monitors system load.

---

## **Building a Resilient Monitoring Strategy**
### **Core Observability Components**
- **Metrics**: Collect key performance indicators using Prometheus.
- **Logs**: Capture structured application events via Loki.
- **Dashboards**: Visualize trends and anomalies with Grafana.
- **Alerting**: Define thresholds for key metrics to trigger alerts.

### **Health & Performance Monitoring**
- **Kubernetes Probes**
  - **Liveness Probe**: Detects unresponsive applications (`/health/liveness`).
  - **Readiness Probe**: Ensures application dependencies are operational (`/health/readiness`).
- **Dependency Validation**: Monitors essential service availability before accepting traffic.

### **Defining Service Level Objectives (SLOs)**
To maintain reliability, define and monitor SLOs such as:
- **Error Budget**: Maintain an acceptable error rate threshold.
- **Response Time Targets**: Ensure 99% of requests complete within 300ms.
- **Availability SLAs**: Monitor uptime and request success rates.

---

This enhanced monitoring stack provides robust observability while keeping resource consumption minimal.

