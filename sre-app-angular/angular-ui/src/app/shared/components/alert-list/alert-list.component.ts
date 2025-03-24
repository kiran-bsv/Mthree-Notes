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
