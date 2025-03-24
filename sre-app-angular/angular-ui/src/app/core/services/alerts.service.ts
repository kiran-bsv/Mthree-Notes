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
        next: (alerts) => this.alertsSubject.next(alerts ?? []),
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
