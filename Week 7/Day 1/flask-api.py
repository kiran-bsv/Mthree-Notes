import os
import time
import logging
from flask import Flask, jsonify, request
from flask_cors import CORS
from prometheus_client import Counter, Histogram, generate_latest, REGISTRY, CONTENT_TYPE_LATEST

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Define Prometheus metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total number of requests by endpoint and method', 
                      ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'Request latency in seconds',
                         ['method', 'endpoint'])

# Sample data
system_metrics = {
    'cpu_usage': 30.5,
    'memory_usage': 45.2,
    'disk_usage': 60.8,
    'network_io': {
        'sent_bytes': 1024000,
        'received_bytes': 2048000
    }
}

alerts = [
    {'id': 1, 'severity': 'critical', 'message': 'High CPU usage detected', 'timestamp': '2025-03-20T10:30:00Z'},
    {'id': 2, 'severity': 'warning', 'message': 'Memory usage above threshold', 'timestamp': '2025-03-20T11:45:00Z'},
    {'id': 3, 'severity': 'info', 'message': 'System update available', 'timestamp': '2025-03-20T09:15:00Z'}
]

# Middleware to record metrics
@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    request_latency = time.time() - request.start_time
    REQUEST_LATENCY.labels(request.method, request.path).observe(request_latency)
    REQUEST_COUNT.labels(request.method, request.path, response.status_code).inc()
    return response

@app.route('/metrics')
def metrics():
    return generate_latest(REGISTRY), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/api/health')
def health_check():
    logger.info('Health check endpoint accessed')
    return jsonify({'status': 'healthy', 'version': '1.0.0'})

@app.route('/api/metrics')
def get_metrics():
    logger.info('Metrics endpoint accessed')
    return jsonify(system_metrics)

@app.route('/api/alerts')
def get_alerts():
    logger.info('Alerts endpoint accessed')
    severity = request.args.get('severity')
    
    if severity:
        filtered_alerts = [alert for alert in alerts if alert['severity'] == severity]
        return jsonify(filtered_alerts)
    
    return jsonify(alerts)

@app.route('/api/config')
def get_config():
    logger.info('Config endpoint accessed')
    config = {
        'app_name': 'SRE Demo API',
        'environment': os.environ.get('ENVIRONMENT', 'development'),
        'log_level': os.environ.get('LOG_LEVEL', 'INFO'),
        'metrics_enabled': True,
        'version': '1.0.0'
    }
    return jsonify(config)

@app.route('/api/simulate/cpu')
def simulate_cpu_load():
    """Endpoint to simulate CPU load for testing"""
    logger.info('CPU load simulation started')
    duration = int(request.args.get('duration', 5))
    
    # Simple CPU-bound task
    start_time = time.time()
    while time.time() - start_time < duration:
        _ = [i**2 for i in range(10000)]
    
    return jsonify({'status': 'success', 'message': f'CPU load simulated for {duration} seconds'})

@app.route('/api/simulate/memory')
def simulate_memory_load():
    """Endpoint to simulate memory load for testing"""
    logger.info('Memory load simulation started')
    size_mb = int(request.args.get('size_mb', 10))
    duration = int(request.args.get('duration', 5))
    
    # Allocate memory
    data = bytearray(size_mb * 1024 * 1024)
    
    # Hold for duration
    time.sleep(duration)
    
    # Memory is automatically freed when function returns
    return jsonify({'status': 'success', 'message': f'Memory load simulated: {size_mb}MB for {duration} seconds'})

@app.route('/api/simulate/error')
def simulate_error():
    """Endpoint to simulate an error for testing alerts"""
    error_type = request.args.get('type', 'server')
    logger.error(f'Error simulation triggered: {error_type}')
    
    if error_type == 'client':
        return jsonify({'error': 'Bad Request Simulation'}), 400
    else:
        return jsonify({'error': 'Internal Server Error Simulation'}), 500

if __name__ == '__main__':
    # Get port from environment or default to 5000
    port = int(os.environ.get('PORT', 5000))
    
    # Debug mode should be disabled in production
    debug_mode = os.environ.get('ENVIRONMENT', 'development') == 'development'
    
    logger.info(f'Starting Flask API on port {port}')
    app.run(host='0.0.0.0', port=port, debug=debug_mode)
