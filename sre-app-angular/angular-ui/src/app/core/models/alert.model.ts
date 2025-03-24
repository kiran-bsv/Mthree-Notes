
export interface Alert {
  id: number;
  severity: 'critical' | 'warning' | 'info';
  message: string;
  timestamp: string;
  acknowledged?: boolean;
}
