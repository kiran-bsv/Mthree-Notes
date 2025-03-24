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
