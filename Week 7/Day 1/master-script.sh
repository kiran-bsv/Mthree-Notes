#!/bin/bash

set -e

echo "========== SRE Application Setup Master Script =========="
echo "This script will set up the complete SRE environment with WSL, Minikube, Prometheus, Grafana, Flask API, and Angular UI"

# Create directories for the project
PROJECT_ROOT="/home/kiran/Desktop/Mthree-Notes/sre-app-angular"
# cc="/home/kiran/Desktop/Mthree-Notes/sre-app-angular"
FILES_SRC_DIR="/home/kiran/Desktop/Mthree-Notes/Week 7/Day 1"
FILES_DES_DIR="/home/kiran/Desktop/Mthree-Notes/sre-app-angular"
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
# cat > wsl-setup/setup-wsl-minikube.sh << 'EOF'
# # Script content goes here - copy from WSL and Minikube Setup Script artifact
# EOF
# chmod +x wsl-setup/setup-wsl-minikube.sh

# echo "Creating Prometheus setup script..."
# cat > prometheus/setup-prometheus.sh << 'EOF'
# # Script content goes here - copy from Prometheus Setup Script artifact
# EOF
# chmod +x prometheus/setup-prometheus.sh

# echo "Creating Grafana setup script..."
# cat > grafana/setup-grafana.sh << 'EOF'
# # Script content goes here - copy from Grafana Setup Script artifact
# EOF
# chmod +x grafana/setup-grafana.sh

echo "Creating Flask API files..."
# touch ${FILES_DES_DIR}/flask-api/app.py
# cp ${FILES_SRC_DIR}/flask-api.py ${FILES_DES_DIR}/flask-api
# mv ${FILES_DES_DIR}/flask-api/flask-api.py ${FILES_DES_DIR}/flask-api/app.py
cat > flask-api/app.py << 'EOF'
# # Script content goes here - copy from Flask API Backend Application artifact
import os
import time
import logging
from flask import Flask, jsonify, request
from flask_cors import CORS
from prometheus_client import Counter, Histogram, generate_latest, REGISTRY, CONTENT_TYPE_LATEST

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Define Prometheus metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total number of requests by endpoint and method', 
                      ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'Request latency in seconds',
                         ['method', 'endpoint'])

# Sample data
system_metrics = {
    'cpu_usage': 30.5,
    'memory_usage': 45.2,
    'disk_usage': 60.8,
    'network_io': {
        'sent_bytes': 1024000,
        'received_bytes': 2048000
    }
}

alerts = [
    {'id': 1, 'severity': 'critical', 'message': 'High CPU usage detected', 'timestamp': '2025-03-20T10:30:00Z'},
    {'id': 2, 'severity': 'warning', 'message': 'Memory usage above threshold', 'timestamp': '2025-03-20T11:45:00Z'},
    {'id': 3, 'severity': 'info', 'message': 'System update available', 'timestamp': '2025-03-20T09:15:00Z'}
]

# Middleware to record metrics
@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    request_latency = time.time() - request.start_time
    REQUEST_LATENCY.labels(request.method, request.path).observe(request_latency)
    REQUEST_COUNT.labels(request.method, request.path, response.status_code).inc()
    return response

@app.route('/metrics')
def metrics():
    return generate_latest(REGISTRY), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/api/health')
def health_check():
    logger.info('Health check endpoint accessed')
    return jsonify({'status': 'healthy', 'version': '1.0.0'})

@app.route('/api/metrics')
def get_metrics():
    logger.info('Metrics endpoint accessed')
    return jsonify(system_metrics)

@app.route('/api/alerts')
def get_alerts():
    logger.info('Alerts endpoint accessed')
    severity = request.args.get('severity')
    
    if severity:
        filtered_alerts = [alert for alert in alerts if alert['severity'] == severity]
        return jsonify(filtered_alerts)
    
    return jsonify(alerts)

@app.route('/api/config')
def get_config():
    logger.info('Config endpoint accessed')
    config = {
        'app_name': 'SRE Demo API',
        'environment': os.environ.get('ENVIRONMENT', 'development'),
        'log_level': os.environ.get('LOG_LEVEL', 'INFO'),
        'metrics_enabled': True,
        'version': '1.0.0'
    }
    return jsonify(config)

@app.route('/api/simulate/cpu')
def simulate_cpu_load():
    """Endpoint to simulate CPU load for testing"""
    logger.info('CPU load simulation started')
    duration = int(request.args.get('duration', 5))
    
    # Simple CPU-bound task
    start_time = time.time()
    while time.time() - start_time < duration:
        _ = [i**2 for i in range(10000)]
    
    return jsonify({'status': 'success', 'message': f'CPU load simulated for {duration} seconds'})

@app.route('/api/simulate/memory')
def simulate_memory_load():
    """Endpoint to simulate memory load for testing"""
    logger.info('Memory load simulation started')
    size_mb = int(request.args.get('size_mb', 10))
    duration = int(request.args.get('duration', 5))
    
    # Allocate memory
    data = bytearray(size_mb * 1024 * 1024)
    
    # Hold for duration
    time.sleep(duration)
    
    # Memory is automatically freed when function returns
    return jsonify({'status': 'success', 'message': f'Memory load simulated: {size_mb}MB for {duration} seconds'})

@app.route('/api/simulate/error')
def simulate_error():
    """Endpoint to simulate an error for testing alerts"""
    error_type = request.args.get('type', 'server')
    logger.error(f'Error simulation triggered: {error_type}')
    
    if error_type == 'client':
        return jsonify({'error': 'Bad Request Simulation'}), 400
    else:
        return jsonify({'error': 'Internal Server Error Simulation'}), 500

if __name__ == '__main__':
    # Get port from environment or default to 5000
    port = int(os.environ.get('PORT', 5000))
    
    # Debug mode should be disabled in production
    debug_mode = os.environ.get('ENVIRONMENT', 'development') == 'development'
    
    logger.info(f'Starting Flask API on port {port}')
    app.run(host='0.0.0.0', port=port, debug=debug_mode)

EOF

cd ${FILES_DES_DIR}

cat > flask-api/requirements.txt << 'EOF'
flask==2.3.2
flask-cors==4.0.0
prometheus-client==0.17.1
gunicorn==21.2.0
EOF

cat > flask-api/Dockerfile << 'EOF'
# Dockerfile content - copy from Flask API Dockerfile artifact\
# Dockerfile for Flask API
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
EOF
# cp ${FILES_SRC_DIR}/flask-dockerfile.txt ${FILES_DES_DIR}/flask-api/Dockerfile

echo "Creating Flask API Kubernetes configuration..."
mkdir -p k8s/flask-api
cat > k8s/flask-api/deployment.yaml << 'EOF'
# Kubernetes deployment content - copy from Flask API Dockerfile artifact

# Kubernetes deployment file
# contents below should be saved as flask-api-deployment.yaml
# ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-api
  namespace: sre-monitoring
  labels:
    app: flask-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-api
  template:
    metadata:
      labels:
        app: flask-api
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "5000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: flask-api
        image: flask-api:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 5000
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: LOG_LEVEL
          value: "INFO"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
        readinessProbe:
          httpGet:
            path: /api/health
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /api/health
            port: 5000
          initialDelaySeconds: 15
          periodSeconds: 20
---
apiVersion: v1
kind: Service
metadata:
  name: flask-api-service
  namespace: sre-monitoring
spec:
  selector:
    app: flask-api
  ports:
  - port: 5000
    targetPort: 5000
  type: ClusterIP
---
EOF

echo "Creating Angular files..."
mkdir -p angular-ui/src/app
mkdir -p angular-ui/src/environments
mkdir -p angular-ui/src/app/core/models
mkdir -p angular-ui/src/app/core/services
mkdir -p angular-ui/src/app/shared/components/metric-card
mkdir -p angular-ui/src/app/shared/components/alert-list
mkdir -p angular-ui/src/app/features/dashboard

cat > angular-ui/src/app/core/models/metric.model.ts << 'EOF'
export interface Metric {
  value: number;
  timestamp: string;
  name: string;
  unit: string;
}

export interface SystemMetrics {
  cpu_usage: number;
  memory_usage: number;
  disk_usage: number;
  network_io: {
    sent_bytes: number;
    received_bytes: number;
  };
}

EOF

cat > angular-ui/src/app/core/models/alert.model.ts << 'EOF'

export interface Alert {
  id: number;
  severity: 'critical' | 'warning' | 'info';
  message: string;
  timestamp: string;
  acknowledged?: boolean;
}
EOF

cat > angular-ui/src/app/core/services/api.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { SystemMetrics } from '../models/metric.model';
import { Alert } from '../models/alert.model';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  getHealth(): Observable<any> {
    return this.http.get(`${this.apiUrl}/health`);
  }

  getMetrics(): Observable<SystemMetrics> {
    return this.http.get<SystemMetrics>(`${this.apiUrl}/metrics`);
  }

  getAlerts(severity?: string): Observable<Alert[]> {
    let url = `${this.apiUrl}/alerts`;
    if (severity) {
      url += `?severity=${severity}`;
    }
    return this.http.get<Alert[]>(url);
  }

  getConfig(): Observable<any> {
    return this.http.get(`${this.apiUrl}/config`);
  }

  simulateCpuLoad(duration: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/simulate/cpu?duration=${duration}`);
  }

  simulateMemoryLoad(sizeMb: number, duration: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/simulate/memory?size_mb=${sizeMb}&duration=${duration}`);
  }

  simulateError(type: 'client' | 'server'): Observable<any> {
    return this.http.get(`${this.apiUrl}/simulate/error?type=${type}`);
  }
}
EOF

cat > angular-ui/src/app/core/services/metrics.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { ApiService } from './api.service';
import { BehaviorSubject, Observable, interval } from 'rxjs';
import { switchMap, shareReplay } from 'rxjs/operators';
import { SystemMetrics } from '../models/metric.model';

@Injectable({
  providedIn: 'root'
})
export class MetricsService {
  private metricsSubject = new BehaviorSubject<SystemMetrics | null>(null);
  private refreshInterval = 10000; // 10 seconds
  
  metrics$ = this.metricsSubject.asObservable();
  
  constructor(private apiService: ApiService) {
    // Set up automatic polling for metrics
    this.setupMetricsPolling();
  }
  
  private setupMetricsPolling(): void {
    interval(this.refreshInterval)
      .pipe(
        switchMap(() => this.apiService.getMetrics())
      )
      .subscribe({
        next: (metrics) => this.metricsSubject.next(metrics),
        error: (error) => console.error('Error fetching metrics:', error)
      });
      
    // Initial fetch
    this.refreshMetrics();
  }
  
  refreshMetrics(): void {
    this.apiService.getMetrics().subscribe({
      next: (metrics) => this.metricsSubject.next(metrics),
      error: (error) => console.error('Error fetching metrics:', error)
    });
  }
  
  setRefreshInterval(intervalMs: number): void {
    this.refreshInterval = intervalMs;
    this.setupMetricsPolling();
  }
}
EOF

cat > angular-ui/src/app/core/services/alerts.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { ApiService } from './api.service';
import { BehaviorSubject, Observable, interval } from 'rxjs';
import { switchMap } from 'rxjs/operators';
import { Alert } from '../models/alert.model';

@Injectable({
  providedIn: 'root'
})
export class AlertsService {
  private alertsSubject = new BehaviorSubject<Alert[]>([]);
  private refreshInterval = 30000; // 30 seconds
  
  alerts$ = this.alertsSubject.asObservable();
  
  constructor(private apiService: ApiService) {
    // Set up automatic polling for alerts
    this.setupAlertsPolling();
  }
  
  private setupAlertsPolling(): void {
    interval(this.refreshInterval)
      .pipe(
        switchMap(() => this.apiService.getAlerts())
      )
      .subscribe({
        next: (alerts) => this.alertsSubject.next(alerts),
        error: (error) => console.error('Error fetching alerts:', error)
      });
      
    // Initial fetch
    this.refreshAlerts();
  }
  
  refreshAlerts(severity?: string): void {
    this.apiService.getAlerts(severity).subscribe({
      next: (alerts) => this.alertsSubject.next(alerts),
      error: (error) => console.error('Error fetching alerts:', error)
    });
  }
  
  acknowledgeAlert(alertId: number): void {
    const currentAlerts = this.alertsSubject.getValue();
    const updatedAlerts = currentAlerts.map(alert => 
      alert.id === alertId ? { ...alert, acknowledged: true } : alert
    );
    this.alertsSubject.next(updatedAlerts);
    
    // In a real app, you would call an API endpoint to persist this change
    // this.apiService.acknowledgeAlert(alertId).subscribe();
  }
}
EOF

cat > angular-ui/src/app//shared/components/metric-card/metric-card.component.ts << 'EOF'
import { Component, Input, OnInit } from '@angular/core';

@Component({
  selector: 'app-metric-card',
  template: `
    <div class="metric-card" [ngClass]="getSeverityClass()">
      <div class="metric-header">
        <h3>{{ title }}</h3>
        <span class="metric-unit">{{ unit }}</span>
      </div>
      <div class="metric-value">{{ value | number:'1.1-2' }}</div>
      <div class="metric-footer">
        <span class="trend" *ngIf="trend">
          <i class="fa" [ngClass]="getTrendIconClass()"></i>
          {{ trendValue | number:'1.1-2' }}%
        </span>
      </div>
    </div>
  `,
  styles: [`
    .metric-card {
      padding: 16px;
      border-radius: 8px;
      background-color: #fff;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      margin-bottom: 16px;
    }
    .metric-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;
    }
    .metric-header h3 {
      margin: 0;
      font-size: 16px;
      font-weight: 500;
    }
    .metric-unit {
      font-size: 12px;
      color: #666;
    }
    .metric-value {
      font-size: 24px;
      font-weight: 600;
      margin-bottom: 8px;
    }
    .metric-footer {
      font-size: 12px;
    }
    .trend {
      display: flex;
      align-items: center;
    }
    .trend i {
      margin-right: 4px;
    }
    .severity-normal {
      border-left: 4px solid #4caf50;
    }
    .severity-warning {
      border-left: 4px solid #ff9800;
    }
    .severity-critical {
      border-left: 4px solid #f44336;
    }
  `]
})
export class MetricCardComponent implements OnInit {
  @Input() title: string = '';
  @Input() value: number = 0;
  @Input() unit: string = '';
  @Input() trend?: number;
  @Input() trendValue?: number;
  @Input() thresholdWarning: number = 70;
  @Input() thresholdCritical: number = 90;

  ngOnInit(): void {
  }

  getSeverityClass(): string {
    if (this.value >= this.thresholdCritical) {
      return 'severity-critical';
    } else if (this.value >= this.thresholdWarning) {
      return 'severity-warning';
    }
    return 'severity-normal';
  }

  getTrendIconClass(): string {
    if (!this.trend) return '';
    return this.trend > 0 ? 'fa-arrow-up' : 'fa-arrow-down';
  }
}
EOF

cat > angular-ui/src/app/shared/components/alert-list/alert-list.component.ts << 'EOF'
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { Alert } from '../../../core/models/alert.model';

@Component({
  selector: 'app-alert-list',
  template: `
    <div class="alert-list">
      <div *ngIf="alerts.length === 0" class="no-alerts">
        No alerts to display
      </div>
      <div *ngFor="let alert of alerts" class="alert-item" [ngClass]="'severity-' + alert.severity">
        <div class="alert-header">
          <span class="severity-badge">{{ alert.severity }}</span>
          <span class="alert-timestamp">{{ alert.timestamp | date:'short' }}</span>
        </div>
        <div class="alert-message">{{ alert.message }}</div>
        <div class="alert-actions">
          <button *ngIf="!alert.acknowledged" (click)="onAcknowledge(alert.id)">Acknowledge</button>
          <span *ngIf="alert.acknowledged" class="acknowledged-badge">Acknowledged</span>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .alert-list {
      margin-bottom: 16px;
    }
    .no-alerts {
      padding: 16px;
      text-align: center;
      color: #666;
    }
    .alert-item {
      padding: 12px;
      border-radius: 4px;
      margin-bottom: 8px;
      background-color: #fff;
      box-shadow: 0 1px 2px rgba(0,0,0,0.1);
    }
    .alert-header {
      display: flex;
      justify-content: space-between;
      margin-bottom: 8px;
    }
    .severity-badge {
      padding: 2px 6px;
      border-radius: 4px;
      font-size: 12px;
      text-transform: uppercase;
    }
    .alert-timestamp {
      font-size: 12px;
      color: #666;
    }
    .alert-message {
      margin-bottom: 8px;
    }
    .alert-actions {
      text-align: right;
    }
    .alert-actions button {
      padding: 4px 8px;
      border: none;
      background-color: #2196f3;
      color: white;
      border-radius: 4px;
      cursor: pointer;
    }
    .acknowledged-badge {
      font-size: 12px;
      color: #666;
      font-style: italic;
    }
    .severity-critical {
      border-left: 4px solid #f44336;
    }
    .severity-critical .severity-badge {
      background-color: #f44336;
      color: white;
    }
    .severity-warning {
      border-left: 4px solid #ff9800;
    }
    .severity-warning .severity-badge {
      background-color: #ff9800;
      color: white;
    }
    .severity-info {
      border-left: 4px solid #2196f3;
    }
    .severity-info .severity-badge {
      background-color: #2196f3;
      color: white;
    }
  `]
})
export class AlertListComponent {
  @Input() alerts: Alert[] = [];
  @Output() acknowledge = new EventEmitter<number>();

  onAcknowledge(alertId: number): void {
    this.acknowledge.emit(alertId);
  }
}
EOF

cat > angular-ui/src/app/features/dashboard/dashboard.component.ts << 'EOF'
import { Component, OnInit } from '@angular/core';
import { MetricsService } from '../../core/services/metrics.service';
import { AlertsService } from '../../core/services/alerts.service';
import { ApiService } from '../../core/services/api.service';
import { SystemMetrics } from '../../core/models/metric.model';
import { Alert } from '../../core/models/alert.model';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Component({
  selector: 'app-dashboard',
  template: `
    <div class="dashboard-container">
      <header class="dashboard-header">
        <h1>SRE Dashboard</h1>
        <div class="actions">
          <button (click)="refreshMetrics()">Refresh Metrics</button>
          <button (click)="openSettings()">Settings</button>
        </div>
      </header>

      <div class="dashboard-content">
        <div class="metrics-section">
          <h2>System Metrics</h2>
          <div class="metrics-grid">
            <app-metric-card
              title="CPU Usage"
              [value]="(metrics$ | async)?.cpu_usage || 0"
              unit="%"
              [thresholdWarning]="70"
              [thresholdCritical]="90"
            ></app-metric-card>
            
            <app-metric-card
              title="Memory Usage"
              [value]="(metrics$ | async)?.memory_usage || 0"
              unit="%"
              [thresholdWarning]="80"
              [thresholdCritical]="95"
            ></app-metric-card>
            
            <app-metric-card
              title="Disk Usage"
              [value]="(metrics$ | async)?.disk_usage || 0"
              unit="%"
              [thresholdWarning]="75"
              [thresholdCritical]="90"
            ></app-metric-card>
            
            <app-metric-card
              title="Network Sent"
              [value]="((metrics$ | async)?.network_io?.sent_bytes || 0) / (1024 * 1024)"
              unit="MB"
            ></app-metric-card>
            
            <app-metric-card
              title="Network Received"
              [value]="((metrics$ | async)?.network_io?.received_bytes || 0) / (1024 * 1024)"
              unit="MB"
            ></app-metric-card>
          </div>
        </div>

        <div class="alerts-section">
          <h2>Recent Alerts</h2>
          <div class="alerts-filter">
            <button 
              [ngClass]="{'active': currentSeverityFilter === ''}"
              (click)="filterAlerts('')">All</button>
            <button 
              [ngClass]="{'active': currentSeverityFilter === 'critical'}"
              (click)="filterAlerts('critical')">Critical</button>
            <button 
              [ngClass]="{'active': currentSeverityFilter === 'warning'}"
              (click)="filterAlerts('warning')">Warning</button>
            <button 
              [ngClass]="{'active': currentSeverityFilter === 'info'}"
              (click)="filterAlerts('info')">Info</button>
          </div>
          <app-alert-list
            [alerts]="alerts$ | async ?? []"
            (acknowledge)="acknowledgeAlert($event)"
          ></app-alert-list>
        </div>

        <div class="simulation-section">
          <h2>Test Utilities</h2>
          <div class="simulation-grid">
            <div class="simulation-card">
              <h3>CPU Load Test</h3>
              <div class="form-group">
                <label for="cpu-duration">Duration (seconds):</label>
                <input id="cpu-duration" type="number" [(ngModel)]="cpuTestDuration" min="1" max="30">
              </div>
              <button [disabled]="isTestRunning" (click)="simulateCpuLoad()">Run Test</button>
            </div>
            
            <div class="simulation-card">
              <h3>Memory Load Test</h3>
              <div class="form-group">
                <label for="memory-size">Size (MB):</label>
                <input id="memory-size" type="number" [(ngModel)]="memoryTestSize" min="1" max="100">
              </div>
              <div class="form-group">
                <label for="memory-duration">Duration (seconds):</label>
                <input id="memory-duration" type="number" [(ngModel)]="memoryTestDuration" min="1" max="30">
              </div>
              <button [disabled]="isTestRunning" (click)="simulateMemoryLoad()">Run Test</button>
            </div>
            
            <div class="simulation-card">
              <h3>Error Simulation</h3>
              <div class="form-group">
                <label for="error-type">Error Type:</label>
                <select id="error-type" [(ngModel)]="errorType">
                  <option value="client">Client Error (400)</option>
                  <option value="server">Server Error (500)</option>
                </select>
              </div>
              <button [disabled]="isTestRunning" (click)="simulateError()">Simulate Error</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .dashboard-container {
      padding: 16px;
      max-width: 1200px;
      margin: 0 auto;
    }
    .dashboard-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 24px;
    }
    .dashboard-header h1 {
      margin: 0;
    }
    .actions button {
      margin-left: 8px;
      padding: 8px 16px;
      background-color: #2196f3;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .metrics-section, .alerts-section, .simulation-section {
      margin-bottom: 32px;
    }
    .metrics-section h2, .alerts-section h2, .simulation-section h2 {
      margin-top: 0;
      margin-bottom: 16px;
      font-size: 20px;
    }
    .metrics-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 16px;
    }
    .alerts-filter {
      margin-bottom: 16px;
    }
    .alerts-filter button {
      margin-right: 8px;
      padding: 4px 12px;
      background-color: #f0f0f0;
      border: 1px solid #ddd;
      border-radius: 4px;
      cursor: pointer;
    }
    .alerts-filter button.active {
      background-color: #2196f3;
      color: white;
      border-color: #2196f3;
    }
    .simulation-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 16px;
    }
    .simulation-card {
      padding: 16px;
      background-color: #f9f9f9;
      border-radius: 8px;
      border: 1px solid #eee;
    }
    .simulation-card h3 {
      margin-top: 0;
      margin-bottom: 16px;
      font-size: 16px;
    }
    .form-group {
      margin-bottom: 12px;
    }
    .form-group label {
      display: block;
      margin-bottom: 4px;
      font-size: 14px;
    }
    .form-group input, .form-group select {
      width: 100%;
      padding: 8px;
      border: 1px solid #ddd;
      border-radius: 4px;
    }
    .simulation-card button {
      width: 100%;
      padding: 8px 16px;
      background-color: #4caf50;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .simulation-card button:disabled {
      background-color: #ccc;
      cursor: not-allowed;
    }
  `]
})
export class DashboardComponent implements OnInit {
  metrics$: Observable<SystemMetrics | null>;
  alerts$: Observable<Alert[]>;
  
  currentSeverityFilter: string = '';
  isTestRunning: boolean = false;
  
  // Simulation controls
  cpuTestDuration: number = 5;
  memoryTestSize: number = 10;
  memoryTestDuration: number = 5;
  errorType: 'client' | 'server' = 'client';
  
  constructor(
    private metricsService: MetricsService,
    private alertsService: AlertsService,
    private apiService: ApiService
  ) {
    this.metrics$ = this.metricsService.metrics$;
    this.alerts$ = this.alertsService.alerts$;
  }
  
  ngOnInit(): void {
    // Initial data fetch
    this.refreshMetrics();
    this.alertsService.refreshAlerts();
  }
  
  refreshMetrics(): void {
    this.metricsService.refreshMetrics();
  }
  
  filterAlerts(severity: string): void {
    this.currentSeverityFilter = severity;
    this.alertsService.refreshAlerts(severity);
  }
  
  acknowledgeAlert(alertId: number): void {
    this.alertsService.acknowledgeAlert(alertId);
  }
  
  openSettings(): void {
    // In a real app, this would open a settings dialog
    alert('Settings functionality would go here');
  }
  
  simulateCpuLoad(): void {
    this.isTestRunning = true;
    this.apiService.simulateCpuLoad(this.cpuTestDuration).subscribe({
      next: (response) => {
        console.log('CPU test response:', response);
        this.isTestRunning = false;
        // Refresh metrics after test
        setTimeout(() => this.refreshMetrics(), 1000);
      },
      error: (error) => {
        console.error('CPU test error:', error);
        this.isTestRunning = false;
      }
    });
  }
  
  simulateMemoryLoad(): void {
    this.isTestRunning = true;
    this.apiService.simulateMemoryLoad(this.memoryTestSize, this.memoryTestDuration).subscribe({
      next: (response) => {
        console.log('Memory test response:', response);
        this.isTestRunning = false;
        // Refresh metrics after test
        setTimeout(() => this.refreshMetrics(), 1000);
      },
      error: (error) => {
        console.error('Memory test error:', error);
        this.isTestRunning = false;
      }
    });
  }
  
  simulateError(): void {
    this.isTestRunning = true;
    this.apiService.simulateError(this.errorType).subscribe({
      next: (response) => {
        // This shouldn't happen
        console.log('Error simulation response:', response);
        this.isTestRunning = false;
      },
      error: (error) => {
        console.log('Error simulated successfully:', error);
        this.isTestRunning = false;
        // Refresh alerts after error
        setTimeout(() => this.alertsService.refreshAlerts(), 1000);
      }
    });
  }
}
EOF

cat > angular-ui/src/app/app.module.ts << 'EOF'
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { RouterModule, Routes } from '@angular/router';

import { AppComponent } from './app.component';
import { MetricCardComponent } from './shared/components/metric-card/metric-card.component';
import { AlertListComponent } from './shared/components/alert-list/alert-list.component';
import { DashboardComponent } from './features/dashboard/dashboard.component';

const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
];

@NgModule({
  declarations: [
    AppComponent,
    MetricCardComponent,
    AlertListComponent,
    DashboardComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    FormsModule,
    RouterModule.forRoot(routes)
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
EOF

cat > angular-ui/src/app/app.component.ts << 'EOF'
import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <div class="app-container">
      <nav class="sidebar">
        <div class="sidebar-header">
          <h2>Team 4 - SRE Portal</h2>
        </div>
        <ul class="nav-links">
          <li><a routerLink="/dashboard" routerLinkActive="active">Dashboard</a></li>
          <li><a routerLink="/metrics" routerLinkActive="active">Metrics</a></li>
          <li><a routerLink="/alerts" routerLinkActive="active">Alerts</a></li>
          <li><a routerLink="/config" routerLinkActive="active">Configuration</a></li>
        </ul>
      </nav>
      <main class="main-content">
        <router-outlet></router-outlet>
      </main>
    </div>
  `,
  styles: [`
    .app-container {
      display: flex;
      height: 100vh;
    }
    .sidebar {
      width: 250px;
      background-color: #2c3e50;
      color: white;
    }
    .sidebar-header {
      padding: 16px;
      border-bottom: 1px solid #34495e;
    }
    .sidebar-header h2 {
      margin: 0;
      font-size: 20px;
    }
    .nav-links {
      list-style: none;
      padding: 0;
      margin: 0;
    }
    .nav-links li a {
      display: block;
      padding: 12px 16px;
      color: #ecf0f1;
      text-decoration: none;
      border-left: 4px solid transparent;
    }
    .nav-links li a:hover {
      background-color: #34495e;
    }
    .nav-links li a.active {
      background-color: #34495e;
      border-left: 4px solid #3498db;
    }
    .main-content {
      flex: 1;
      overflow-y: auto;
      background-color: #f5f5f5;
    }
  `]
})
export class AppComponent {
  title = 'sre-dashboard';
}
EOF

cat > angular-ui/src/environments/environment.ts << 'EOF'
export const environment = {
  production: false,
  apiUrl: 'http://localhost:5000/api'
};
EOF

cat > angular-ui/src/environments/environment.prod.ts << 'EOF'
export const environment = {
  production: true,
  apiUrl: '/api'
};
EOF

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

# Dockerfile for Angular App
FROM node:18 as build

WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Build the application
RUN npm run build --prod

# Production stage
FROM nginx:alpine

# Copy the build output to replace the default nginx contents
COPY --from=build /app/dist/sre-dashboard /usr/share/nginx/html

# Copy our custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

EOF
# cp ${FILES_SRC_DIR}/angular-dockerfile.txt ${FILES_DES_DIR}/angular-ui/Dockerfile 

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
# Kubernetes deployment file
# Save this as angular-ui-deployment.yaml
# ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: angular-ui
  namespace: sre-monitoring
  labels:
    app: angular-ui
spec:
  replicas: 1
  selector:
    matchLabels:
      app: angular-ui
  template:
    metadata:
      labels:
        app: angular-ui
    spec:
      containers:
      - name: angular-ui
        image: angular-ui:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: angular-ui-service
  namespace: sre-monitoring
spec:
  selector:
    app: angular-ui
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sre-app-ingress
  namespace: sre-monitoring
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
  - http:
      paths:
      - path: /(.*)
        pathType: Prefix
        backend:
          service:
            name: angular-ui-service
            port:
              number: 80
# ---
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
EOF

# Create the main setup script
cat > setup.sh << 'EOF'
#!/bin/bash

set -e

echo "========== SRE Application Setup Script =========="
echo "This script will set up the complete SRE environment"

# Check if running on Windows with WSL
# if [[ "$(uname -r)" != *Microsoft* ]] && [[ "$(uname -r)" != *microsoft* ]]; then
#   echo "This script is intended to be run on Windows with WSL."
#   echo "If you've already installed WSL, you can continue. Otherwise, please install WSL first."
#   read -p "Continue? (y/n) " -n 1 -r
#   echo
#   if [[ ! $REPLY =~ ^[Yy]$ ]]; then
#     exit 1
#   fi
# fi

# Step 1: Set up WSL and Minikube
echo "Step 1: Setting up WSL and Minikube..."
# ./wsl-setup/setup-wsl-minikube.sh

# Step 2: Build and deploy the Flask API
echo "Step 2: Building and deploying the Flask API..."
cd flask-api
docker build -t flask-api:latest .
cd ..

minikube image load flask-api:latest
kubectl apply -f k8s/flask-api/deployment.yaml

# Step 3: Build and deploy the Angular UI
echo "Step 3: Building and deploying the Angular UI..."
cd angular-ui
# In a real script, we would build the Angular app here
# For brevity, we'll just build the Docker image
docker build -t angular-ui:latest .
cd ..


minikube image load angular-ui:latest
kubectl apply -f k8s/angular-ui/deployment.yaml

# Step 4: Set up Prometheus
echo "Step 4: Setting up Prometheus..."
# ./prometheus/setup-prometheus.sh

# Step 5: Set up Grafana
echo "Step 5: Setting up Grafana..."
# ./grafana/setup-grafana.sh

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
echo "============================================="
