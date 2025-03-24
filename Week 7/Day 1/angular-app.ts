// File structure overview:
// - src/app/core/models/ - Interface definitions
// - src/app/core/services/ - Services for API communication
// - src/app/shared/ - Shared components
// - src/app/features/ - Feature modules
// - src/app/features/dashboard/ - Main dashboard
// - src/app/features/metrics/ - Detailed metrics
// - src/app/features/alerts/ - Alerts management

// First, let's create our core models

// src/app/core/models/metric.model.ts
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

// src/app/core/models/alert.model.ts
export interface Alert {
  id: number;
  severity: 'critical' | 'warning' | 'info';
  message: string;
  timestamp: string;
  acknowledged?: boolean;
}

// src/app/core/services/api.service.ts
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

// src/app/core/services/metrics.service.ts
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

// src/app/core/services/alerts.service.ts
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

// Now let's create the shared components

// src/app/shared/components/metric-card/metric-card.component.ts
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

// src/app/shared/components/alert-list/alert-list.component.ts
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

// Next, let's create the dashboard component

// src/app/features/dashboard/dashboard.component.ts
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

// app.module.ts
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

// app.component.ts
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

// environments/environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:5000/api'
};

// environments/environment.prod.ts
export const environment = {
  production: true,
  apiUrl: '/api'
};
