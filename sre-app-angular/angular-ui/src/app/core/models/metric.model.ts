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

