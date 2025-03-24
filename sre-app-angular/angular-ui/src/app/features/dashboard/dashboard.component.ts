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
            [alerts]="alerts$ | async "
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
  // alerts$: Observable<Alert[]> = this.alertsService.getAlerts().pipe(
  //   map(alerts => alerts ?? []) // Converts `null` to an empty array
  // );
  
  
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
