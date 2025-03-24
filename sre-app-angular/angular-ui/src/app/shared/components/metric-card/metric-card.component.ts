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
