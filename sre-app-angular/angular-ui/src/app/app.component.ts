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
