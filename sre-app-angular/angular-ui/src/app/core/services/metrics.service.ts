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
