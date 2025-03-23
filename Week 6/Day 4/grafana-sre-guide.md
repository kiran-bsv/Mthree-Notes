# Complete Grafana SRE Dashboard Implementation Guide

This comprehensive guide provides step-by-step instructions for creating Grafana dashboards that visualize all essential Site Reliability Engineering (SRE) concepts. By following this guide, you'll build a complete monitoring solution covering the four golden signals (latency, traffic, errors, and saturation), SLOs, error budgets, and other critical SRE metrics.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Accessing Grafana](#accessing-grafana)
3. [Creating the Main SRE Overview Dashboard](#creating-the-main-sre-overview-dashboard)
4. [Implementing the Four Golden Signals Dashboard](#implementing-the-four-golden-signals-dashboard)
5. [Building an SLO and Error Budget Dashboard](#building-an-slo-and-error-budget-dashboard)
6. [Infrastructure Health Dashboard](#infrastructure-health-dashboard)
7. [User Experience Dashboard](#user-experience-dashboard)
8. [Setting Up Alerting Based on SRE Principles](#setting-up-alerting-based-on-sre-principles)
9. [Dashboard Organization and Best Practices](#dashboard-organization-and-best-practices)

## Prerequisites

Before starting, ensure you have:

- A running Grafana instance (version 8.x or newer recommended)
- Prometheus configured as a data source in Grafana
- Basic metrics being collected from your application (HTTP requests, errors, resource usage)
- Admin or editor access to Grafana to create dashboards
- For advanced dashboards: node_exporter for host metrics and application-specific exporters

## Accessing Grafana

1. Open your Grafana instance at `http://localhost:8080` (or your custom URL)
2. Log in with the admin credentials (default: username `admin`, password `admin`)
3. You should see the Grafana home dashboard
4. Verify Prometheus is configured as a data source:
   - Navigate to Configuration → Data Sources
   - Confirm Prometheus is listed and the status is "Working"

## Creating the Main SRE Overview Dashboard

### Step 1: Create a New Dashboard

1. Click on the "+" icon in the left sidebar
2. Select "Dashboard"
3. Click "Add new panel"

### Step 2: Configure Dashboard Settings

1. Click the gear icon in the upper right to access dashboard settings
2. Set the following values:
   - Name: "SRE Overview Dashboard"
   - Description: "Main dashboard for monitoring SRE metrics and SLOs"
   - Tags: "sre", "overview", "production"
3. Under Variables, add the following:
   - Name: "service"
   - Label: "Service"
   - Type: "Query"
   - Data source: "Prometheus"
   - Query: `label_values(up, service)`
   - Sort: "Alphabetical (asc)"
   - Include "All" option
4. Save the dashboard

### Step 3: Add Service Health Status Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Service Health Status"
3. Select visualization type: "Stat"
4. Data source: "Prometheus"
5. Query A: `up{service=~"$service"}`
6. In Field tab:
   - Standard options → Unit: "none"
   - Value mappings:
     - 1 → "Healthy" (color: green)
     - 0 → "Down" (color: red)
7. Under Threshold:
   - Set thresholds to: 0,1
   - Colors: red, green
8. Click "Apply" to save the panel

### Step 4: Add Availability SLO Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Service Availability (SLO: 99.9%)"
3. Select visualization type: "Gauge"
4. Data source: "Prometheus"
5. Query A: `sum(rate(http_requests_total{service=~"$service", status!~"5.."}[5m])) / sum(rate(http_requests_total{service=~"$service"}[5m])) * 100`
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
7. Under Threshold:
   - Set thresholds to: 99.5,99.9
   - Colors: red, yellow, green
8. Panel options → Description: "Current service availability percentage against SLO of 99.9%"
9. Click "Apply" to save the panel

### Step 5: Add Error Budget Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Error Budget Remaining"
3. Select visualization type: "Gauge"
4. Data source: "Prometheus"
5. Query A:
   ```
   100 - (
     (1 - (sum(rate(http_requests_total{service=~"$service", status!~"5.."}[30d])) / sum(rate(http_requests_total{service=~"$service"}[30d])))) 
     / (1 - 0.999) * 100
   )
   ```
   (This calculates error budget based on a 99.9% SLO)
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
7. Under Threshold:
   - Set thresholds to: 20,50
   - Colors: red, yellow, green
8. Panel options → Description: "Percentage of error budget remaining for the month"
9. Click "Apply" to save the panel

### Step 6: Add Alert Status Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Active Alerts"
3. Select visualization type: "Table"
4. Data source: "Prometheus"
5. Query A: `ALERTS{severity=~"warning|critical", alertstate="firing"}`
6. Under Transform:
   - Add a transformation of type "Organize fields"
   - Keep only: alertname, severity, instance, job, value
7. Panel options → Description: "Currently firing alerts"
8. Click "Apply" to save the panel

### Step 7: Save and Organize Dashboard

1. Click the "Save" icon in the top right
2. Add a meaningful description if prompted
3. Click "Save" to confirm
4. Arrange panels by dragging them to create a logical layout
5. Adjust panel sizes as needed
6. Save again after organizing

## Implementing the Four Golden Signals Dashboard

### Step 1: Create a New Dashboard for Golden Signals

1. Click on the "+" icon in the left sidebar
2. Select "Dashboard"
3. Follow Step 2 from the previous section to configure dashboard settings
   - Name: "Four Golden Signals Dashboard"
   - Add the same service variable

### Step 2: Create Latency Panel (Signal 1)

1. Click "Add panel" → "Add new panel"
2. Panel title: "Request Latency"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A: `histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket{service=~"$service"}[5m])) by (le))` (Label: p50)
6. Query B: `histogram_quantile(0.90, sum(rate(http_request_duration_seconds_bucket{service=~"$service"}[5m])) by (le))` (Label: p90)
7. Query C: `histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service=~"$service"}[5m])) by (le))` (Label: p99)
8. In Field tab:
   - Standard options → Unit: "seconds"
9. In Panel options:
   - Description: "Distribution of request latency (p50, p90, p99)"
   - Add threshold line for your SLO (e.g., 200ms for p95)
10. Click "Apply" to save the panel

### Step 3: Create Traffic Panel (Signal 2)

1. Click "Add panel" → "Add new panel"
2. Panel title: "Request Traffic"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A: `sum(rate(http_requests_total{service=~"$service"}[5m]))` (Label: Requests/sec)
6. In Field tab:
   - Standard options → Unit: "requests/sec"
7. In Panel options:
   - Description: "Total request rate per second"
8. Click "Apply" to save the panel

### Step 4: Create Error Rate Panel (Signal 3)

1. Click "Add panel" → "Add new panel"
2. Panel title: "Error Rate"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A: `sum(rate(http_requests_total{service=~"$service", status=~"5.."}[5m])) / sum(rate(http_requests_total{service=~"$service"}[5m])) * 100` (Label: Error Rate %)
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
7. In Panel options:
   - Description: "Percentage of requests resulting in 5xx errors"
   - Add threshold line for your error SLO (e.g., 0.1%)
8. Click "Apply" to save the panel

### Step 5: Create Saturation Panels (Signal 4)

#### CPU Saturation Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "CPU Utilization"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A: `avg(rate(process_cpu_seconds_total{service=~"$service"}[5m])) by (instance) * 100` (Label: CPU %)
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
7. In Panel options:
   - Description: "CPU utilization percentage"
   - Add threshold line at 80% to indicate potential saturation
8. Click "Apply" to save the panel

#### Memory Saturation Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Memory Utilization"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A: `sum(process_resident_memory_bytes{service=~"$service"}) by (instance) / 1024 / 1024 / 1024` (Label: Memory Used GB)
6. In Field tab:
   - Standard options → Unit: "gigabytes"
7. In Panel options:
   - Description: "Memory usage in GB"
8. Click "Apply" to save the panel

### Step 6: Create Connection Pool Saturation Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Connection Pool Utilization"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A: `sum(pool_connections_used{service=~"$service"}) by (pool_name) / sum(pool_connections_max{service=~"$service"}) by (pool_name) * 100` (Label: Utilization %)
   - Note: Adjust the metric names to match your actual connection pool metrics
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
7. In Panel options:
   - Description: "Connection pool utilization percentage"
   - Add threshold line at 80% to indicate potential saturation
8. Click "Apply" to save the panel

### Step 7: Save and Organize Dashboard

1. Save the dashboard
2. Arrange the panels logically:
   - Put Latency and Traffic in the top row
   - Put Error Rate and Saturation panels in the bottom rows
3. Adjust panel sizes for optimal viewing
4. Save again after organizing

## Building an SLO and Error Budget Dashboard

### Step 1: Create a New Dashboard for SLOs

1. Click on the "+" icon in the left sidebar
2. Select "Dashboard"
3. Follow Step 2 from the previous section to configure dashboard settings
   - Name: "SLO and Error Budget Dashboard"
   - Add the same service variable
   - Add additional variable:
     - Name: "slo_period"
     - Label: "SLO Period"
     - Type: "Custom"
     - Values: "1h,6h,1d,7d,30d"
     - Default: "30d"

### Step 2: Create SLO Overview Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "SLO Compliance Overview"
3. Select visualization type: "Gauge"
4. Data source: "Prometheus"
5. Create multiple queries for different SLOs:

   **Query A (Availability SLO):**
   ```
   sum(rate(http_requests_total{service=~"$service", status!~"5.."}[$slo_period])) / sum(rate(http_requests_total{service=~"$service"}[$slo_period])) * 100
   ```
   Label: "Availability SLO (99.9%)"

6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
7. Under Threshold:
   - Set thresholds to: 99.5,99.9
   - Colors: red, yellow, green
8. Panel options → Description: "Current service availability against SLO"
9. Click "Apply" to save the panel

### Step 3: Create Error Budget Burn Rate Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Error Budget Burn Rate"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A:
   ```
   (
     (1 - (sum(rate(http_requests_total{service=~"$service", status!~"5.."}[1h])) / sum(rate(http_requests_total{service=~"$service"}[1h]))))
     /
     (1 - 0.999)
   ) * 24 * 30
   ```
   Label: "Burn Rate (30-day equivalent)"
6. In Field tab:
   - Standard options → Unit: "none"
7. In Panel options:
   - Description: "Rate at which error budget is being consumed. Value of 1.0 means the budget will last exactly the SLO period. Higher values indicate faster consumption."
   - Add threshold lines at 1.0 and 2.0
8. Click "Apply" to save the panel

### Step 4: Create Error Budget Remaining Time Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Error Budget Remaining Days"
3. Select visualization type: "Stat"
4. Data source: "Prometheus"
5. Query A:
   ```
   (
     (1 - 0.999) - (1 - (sum(rate(http_requests_total{service=~"$service", status!~"5.."}[30d])) / sum(rate(http_requests_total{service=~"$service"}[30d]))))
   ) / (
     (1 - (sum(rate(http_requests_total{service=~"$service", status!~"5.."}[1d])) / sum(rate(http_requests_total{service=~"$service"}[1d]))))
     /
     30
   )
   ```
6. In Field tab:
   - Standard options → Unit: "days"
   - Min: 0
7. Panel options → Description: "Estimated days until error budget is exhausted based on current burn rate"
8. Click "Apply" to save the panel

### Step 5: Create SLO Compliance History Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "SLO Compliance History"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A:
   ```
   sum(rate(http_requests_total{service=~"$service", status!~"5.."}[1d])) / sum(rate(http_requests_total{service=~"$service"}[1d])) * 100
   ```
   Label: "Daily Availability"
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
   - Min: 99.5
   - Max: 100
7. In Panel options:
   - Description: "Daily SLO compliance history"
   - Add threshold line at 99.9% for the SLO
8. Click "Apply" to save the panel

### Step 6: Create Latency SLO Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Latency SLO Compliance"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A:
   ```
   sum(rate(http_request_duration_seconds_bucket{service=~"$service", le="0.3"}[$slo_period])) / sum(rate(http_request_duration_seconds_count{service=~"$service"}[$slo_period])) * 100
   ```
   Label: "% Requests < 300ms"
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
   - Min: 95
   - Max: 100
7. In Panel options:
   - Description: "Percentage of requests completing within latency SLO (target: 99%)"
   - Add threshold line at 99% for the SLO target
8. Click "Apply" to save the panel

### Step 7: Save and Organize Dashboard

1. Save the dashboard
2. Arrange the panels in a logical flow:
   - Top row: SLO Compliance Overview and Error Budget Remaining Days
   - Middle row: Error Budget Burn Rate
   - Bottom row: SLO Compliance History and Latency SLO Compliance
3. Adjust panel sizes for optimal viewing
4. Save again after organizing

## Infrastructure Health Dashboard

### Step 1: Create a New Dashboard for Infrastructure

1. Click on the "+" icon in the left sidebar
2. Select "Dashboard"
3. Configure dashboard settings:
   - Name: "Infrastructure Health Dashboard"
   - Add variables:
     - Name: "node"
     - Label: "Node"
     - Type: "Query"
     - Data source: "Prometheus"
     - Query: `label_values(node_uname_info, instance)`

### Step 2: Create Host CPU Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "CPU Usage"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A:
   ```
   100 - (avg by (instance) (rate(node_cpu_seconds_total{instance=~"$node", mode="idle"}[5m])) * 100)
   ```
   Label: "CPU Usage %"
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
7. Panel options → Description: "CPU usage percentage (higher is more utilized)"
8. Click "Apply" to save the panel

### Step 3: Create Host Memory Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Memory Usage"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A:
   ```
   (1 - (node_memory_MemAvailable_bytes{instance=~"$node"} / node_memory_MemTotal_bytes{instance=~"$node"})) * 100
   ```
   Label: "Memory Usage %"
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
7. Panel options → Description: "Memory usage percentage (higher is more utilized)"
8. Click "Apply" to save the panel

### Step 4: Create Disk Usage Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Disk Usage"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A:
   ```
   (1 - (node_filesystem_avail_bytes{instance=~"$node", mountpoint="/", fstype!="rootfs"} / node_filesystem_size_bytes{instance=~"$node", mountpoint="/", fstype!="rootfs"})) * 100
   ```
   Label: "Disk Usage %"
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
7. Panel options → Description: "Disk usage percentage (higher is more utilized)"
8. Click "Apply" to save the panel

### Step 5: Create Network Traffic Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Network Traffic"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A:
   ```
   rate(node_network_receive_bytes_total{instance=~"$node", device!~"lo"}[5m]) * 8 / 1024 / 1024
   ```
   Label: "Receive (Mbps)"
6. Query B:
   ```
   rate(node_network_transmit_bytes_total{instance=~"$node", device!~"lo"}[5m]) * 8 / 1024 / 1024
   ```
   Label: "Transmit (Mbps)"
7. In Field tab:
   - Standard options → Unit: "mbps"
8. Panel options → Description: "Network traffic in/out in Mbps"
9. Click "Apply" to save the panel

### Step 6: Create System Load Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "System Load Average"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A: `node_load1{instance=~"$node"}` (Label: "1m Load")
6. Query B: `node_load5{instance=~"$node"}` (Label: "5m Load")
7. Query C: `node_load15{instance=~"$node"}` (Label: "15m Load")
8. Query D: `count(node_cpu_seconds_total{instance=~"$node", mode="idle"})` (Label: "Cores")
9. In Field tab:
   - Standard options → Unit: "none"
10. Panel options → Description: "System load average (1m, 5m, 15m) and number of CPU cores"
11. Click "Apply" to save the panel

### Step 7: Create Kubernetes Resource Panels (if applicable)

1. Click "Add panel" → "Add new panel"
2. Panel title: "Kubernetes Pod Status"
3. Select visualization type: "Stat"
4. Data source: "Prometheus"
5. Query A: `sum(kube_pod_status_phase{phase="Running"})` (Label: "Running")
6. Query B: `sum(kube_pod_status_phase{phase="Pending"})` (Label: "Pending")
7. Query C: `sum(kube_pod_status_phase{phase="Failed"})` (Label: "Failed")
8. Panel options → Description: "Kubernetes pod status counts"
9. Click "Apply" to save the panel

### Step 8: Save and Organize Dashboard

1. Save the dashboard
2. Arrange the panels in a logical flow
3. Adjust panel sizes for optimal viewing
4. Save again after organizing

## User Experience Dashboard

### Step 1: Create a New Dashboard for User Experience

1. Click on the "+" icon in the left sidebar
2. Select "Dashboard"
3. Configure dashboard settings:
   - Name: "User Experience Dashboard"
   - Add service variable as in previous dashboards

### Step 2: Create Page Load Time Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Page Load Time"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A:
   ```
   histogram_quantile(0.50, sum(rate(page_load_time_seconds_bucket{service=~"$service"}[5m])) by (le))
   ```
   Label: "p50"
6. Query B:
   ```
   histogram_quantile(0.90, sum(rate(page_load_time_seconds_bucket{service=~"$service"}[5m])) by (le))
   ```
   Label: "p90"
7. Query C:
   ```
   histogram_quantile(0.99, sum(rate(page_load_time_seconds_bucket{service=~"$service"}[5m])) by (le))
   ```
   Label: "p99"
8. In Field tab:
   - Standard options → Unit: "seconds"
9. Panel options → Description: "Distribution of page load times (p50, p90, p99)"
10. Click "Apply" to save the panel

### Step 3: Create Time to First Byte Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Time to First Byte"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A:
   ```
   histogram_quantile(0.95, sum(rate(time_to_first_byte_seconds_bucket{service=~"$service"}[5m])) by (le))
   ```
   Label: "p95 TTFB"
6. In Field tab:
   - Standard options → Unit: "seconds"
7. Panel options → Description: "Time to first byte (95th percentile)"
8. Click "Apply" to save the panel

### Step 4: Create Error Rate by Endpoint Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Error Rate by Endpoint"
3. Select visualization type: "Bar Gauge" (horizontal)
4. Data source: "Prometheus"
5. Query A:
   ```
   sum(rate(http_requests_total{service=~"$service", status=~"5.."}[5m])) by (endpoint) / sum(rate(http_requests_total{service=~"$service"}[5m])) by (endpoint) * 100
   ```
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
   - Max: 5
7. Panel options → Description: "Error rate by endpoint"
8. Click "Apply" to save the panel

### Step 5: Create User-Reported Errors Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "Client-Side Errors"
3. Select visualization type: "Graph"
4. Data source: "Prometheus"
5. Query A:
   ```
   sum(rate(client_error_total{service=~"$service"}[5m])) by (error_type)
   ```
6. In Field tab:
   - Standard options → Unit: "short"
7. Panel options → Description: "Client-side errors reported from the application"
8. Click "Apply" to save the panel

### Step 6: Create User Journey Success Rate Panel

1. Click "Add panel" → "Add new panel"
2. Panel title: "User Journey Success Rate"
3. Select visualization type: "Gauge"
4. Data source: "Prometheus"
5. Query A:
   ```
   sum(rate(user_journey_success_total{service=~"$service", journey_name="checkout"}[5m])) / sum(rate(user_journey_total{service=~"$service", journey_name="checkout"}[5m])) * 100
   ```
   Label: "Checkout Success %"
6. In Field tab:
   - Standard options → Unit: "Percent (0-100)"
7. Panel options → Description: "Success rate of key user journeys"
8. Click "Apply" to save the panel

### Step 7: Save and Organize Dashboard

1. Save the dashboard
2. Arrange the panels in a logical flow
3. Adjust panel sizes for optimal viewing
4. Save again after organizing

## Setting Up Alerting Based on SRE Principles

### Step 1: Access Alerting Configuration

1. In the Grafana sidebar, click on "Alerting"
2. Click "New alert rule"

### Step 2: Create SLO Breach Alert

1. Set rule name to "SLO Breach Alert"
2. Under "Rule type" select "Grafana managed alert"
3. For data source, select "Prometheus"
4. Enter the query:
   ```
   sum(rate(http_requests_total{service="your-service", status!~"5.."}[1h])) / sum(rate(http_requests_total{service="your-service"}[1h])) < 0.999
   ```
5. Set evaluation interval to "1m"
6. Set "For" duration to "5m" (to avoid alerting on brief spikes)
7. Under "Conditions" set:
   - When: "C"
   - Is above: unchecked (looking for values below threshold)
   - Threshold: "true"
8. Under "Add labels" add:
   - severity: critical
   - slo_type: availability
9. Under "Annotations" add:
   - summary: "Availability SLO breach detected"
   - description: "Service availability has dropped below 99.9% over the last 5 minutes"
10. Click "Save" to create the alert

### Step 3: Create Error Budget Alert

1. Click "New alert rule"
2. Set rule name to "Error Budget 50% Consumed Alert"
3. Under "Rule type" select "Grafana managed alert"
4. For data source, select "Prometheus"
5. Enter the query:
   ```
   (
     (1 - (sum(rate(http_requests_total{service="your-service", status!~"5.."}[30d])) / sum(rate(http_requests_total{service="your-service"}[30d]))))
     /
     (1 - 0.999)
   ) > 0.5
   ```
6. Set evaluation interval to "1h"
7. Set "For" duration to "1h"
8. Under "Conditions" set:
   - When: "C"
   - Is above: checked
   - Threshold: "true"
9. Under "Add labels" add:
   - severity: warning
   - alert_type: error_budget
10. Under "Annotations" add:
   - summary: "Error budget 50% consumed"
   - description: "More than 50% of the monthly error budget has been consumed"
11. Click "Save" to create the alert

### Step 4: Create Latency SLO Alert

1. Click "New alert rule"
2. Set rule name to "Latency SLO Breach Alert"
3. Under "Rule type" select "Grafana managed alert"
4. For data source, select "Prometheus"
5. Enter the query:
   ```
   histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{service="your-service"}[5m])) by (le)) > 0.3
   ```
6. Set evaluation interval to "1m"
7. Set "For" duration to "5m"
8. Under "Conditions" set:
   - When: "C"
   - Is above: checked
   - Threshold: "true"
9. Under "Add labels" add:
   - severity: warning
   - slo_type: latency
10. Under "Annotations" add:
   - summary: "Latency SLO breach detected"
   - description: "95th percentile request latency has exceeded 300ms for 5 minutes"
11. Click "Save" to create the alert

### Step 5: Create Notification Channel

1. Go to Alerting → Notification channels
2. Click "New channel"
3. Set name to "SRE Team"
4. Select type (e.g., Slack, Email, PagerDuty)
5. Configure the details for your chosen channel type
6. Enable "Default" if you want all alerts to go to this channel
7. Click "Save" to create the notification channel

### Step 6: Create Alert Groups (optional)

1. Go to Alerting → Alert groups
2. Create groups based on severity or alert type
3. Configure routing to different notification channels based on alert properties

## Dashboard Organization and Best Practices

### Step 1: Create Dashboard Folders

1. Go to Dashboards → Manage
2. Click "New folder"
3. Create folders for different categories:
   - "SRE Dashboards"
   - "Infrastructure Dashboards"
   - "Application Dashboards"
   - "Business Dashboards"
4. Click "Create" for each folder

### Step 2: Organize Dashboards

1. Go to Dashboards → Manage
2. Select dashboards and use "Move" function to organize them into the appropriate folders

### Step 3: Set Up Dashboard Links

1. Open each dashboard
2. Go to Settings → Links
3. Add links to related dashboards for easy navigation
4. Save the dashboard

### Step 4: Documentation and Best Practices

1. Add descriptive text panels to each dashboard explaining its purpose and how to interpret the data
2. Use consistent naming conventions for dashboards, panels, and metrics
3. Use template variables to make dashboards reusable across services and environments
4. Set appropriate time ranges and refresh intervals for each dashboard
5. Use appropriate visualization types for different metrics:
   - Time series data: Graphs
   - Current status: Stat panels, Gauges
   - Comparative data: Bar charts, Tables
6. Add threshold lines to indicate SLO targets on relevant graphs
7. Use meaningful colors that consistently indicate status (e.g., green for good, yellow for warning, red for critical)

## Conclusion

Following this comprehensive guide, you've created a complete set of Grafana dashboards covering all essential SRE concepts:

1. **The Four Golden Signals**: Latency, Traffic, Errors, and Saturation
2. **SLO Management**: Clear visibility into SLO compliance and error budgets
3. **Infrastructure Health**: Comprehensive monitoring of your infrastructure
4. **User Experience**: Real-world performance from the user perspective
5. **Alerting**: Proactive notifications based on SRE principles

These dashboards will help you maintain reliable systems by providing visibility into all aspects of your service performance, enabling data-driven decisions, and supporting a culture of reliability and continuous improvement.

For advanced users, consider exploring additional features:
- Grafana Annotations to mark events like deployments
- Dashboard playlists for NOC displays
- Custom plugins for specialized visualizations
- Integration with additional data sources for broader context

Remember that effective SRE dashboards evolve over time as you learn more about your system and refine your SLIs and SLOs.
