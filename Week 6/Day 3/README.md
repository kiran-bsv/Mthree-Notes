# **Grafana , Prometheus & Loki**  

## **1. Starting Minikube and Accessing Grafana**  

Before using Grafana in a Kubernetes environment, ensure that Minikube is running:  

```bash
minikube start
```

Verify that the Grafana pod is running in the `monitoring` namespace:  

```bash
kubectl get pods -n monitoring
```

If the Grafana pod is running, use port forwarding to access it locally:  

```bash
kubectl port-forward svc/grafana -n monitoring 3000:80
```

Now, open Grafana in a web browser using:  

```
http://localhost:3000
```

## **2. Exporting a Dashboard from Grafana**  

Exporting a dashboard allows you to save and share its configuration as a JSON file.  

### **Steps to Export a Dashboard:**  

1. Open the dashboard in Grafana.  
2. Click on the **Share** icon (top-right corner).  
3. Navigate to the **Export** tab.  
4. Click **Save JSON** to download the dashboard configuration as a JSON file.  

The exported JSON file can be shared or imported into another Grafana instance.  

## **3. Importing a Dashboard into Grafana**  

You can import an existing dashboard from a JSON file to recreate its visualization.  

### **Steps to Import a Dashboard:**  

1. Open Grafana and go to the **Dashboards** section.  
2. Click **+** and select **Import Dashboard**.  
3. Paste the JSON code or upload the JSON file.  
4. Click **Load** and then **Create** to finalize the import.  

Your dashboard will now be available for use. If required, update the **UID** to avoid conflicts.  

## **4. Locating Dashboards Inside the Grafana Pod**  

Grafana stores dashboards inside the pod in Kubernetes. You can access them by following these steps:  

### **Find the Running Grafana Pod Name:**  

```bash
kubectl get pod -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath="{.items[0].metadata.name}"
```

### **Access the Grafana Pod Shell:**  

```bash
kubectl exec -it <grafana-pod-name> -n monitoring -- /bin/sh
```

### **Find Dashboard JSON Files:**  

```bash
find /var/lib/grafana -name "*.json"
```

This command lists all stored dashboards in the pod.  

## **5. Copying Dashboards from Grafana Pod to Local Machine**  

To extract dashboards from the Grafana pod, use `kubectl cp`:  

```bash
kubectl cp monitoring/<grafana-pod-name>:/var/lib/grafana/dashboards/default/dashboard.json ./dashboard.json
```

This will save the dashboard JSON file to your local machine.  

## **6. Verifying Imported Dashboards**  

After importing a dashboard:  

- Check if all panels are correctly displayed.  
- Ensure that data sources are correctly linked.  
- Verify that all queries and alerts function as expected.  
- Modify missing panel configurations if necessary.  

---

# **Prometheus and Loki Queries in Grafana**  

Grafana supports **Prometheus** for metrics and **Loki** for logs.  

## **7. Prometheus Overview**  

- **Purpose**: Time-series database for monitoring and alerting.  
- **Data Collection**: Scrapes metrics from applications.  
- **Storage**: Stores time-series data in its TSDB (Time Series Database).  
- **Query Language**: Uses **PromQL** for querying.  
- **Best For**: Application performance monitoring (CPU, memory, request counts, etc.).  

### **Basic PromQL Queries**  

1. **CPU Usage (%):**  

   ```promql
   100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
   ```

2. **Memory Utilization (%):**  

   ```promql
   (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100
   ```

3. **HTTP Requests per Second:**  

   ```promql
   rate(http_requests_total[5m])
   ```

4. **Request Latency (99th Percentile):**  

   ```promql
   histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
   ```

---

## **8. Loki Overview**  

- **Purpose**: Log aggregation system designed for Grafana.  
- **Data Collection**: Captures logs from applications without indexing log content (only labels).  
- **Query Language**: Uses **LogQL** for filtering and analyzing logs.  
- **Best For**: Troubleshooting and correlating logs with Prometheus metrics.  

### **Basic LogQL Queries**  

1. **Find All Logs for an Application:**  

   ```logql
   {app="nginx"}
   ```

2. **Filter Logs Containing "ERROR":**  

   ```logql
   {app="nginx"} |= "ERROR"
   ```

3. **Count Errors by Service:**  

   ```logql
   sum by(service) (count_over_time({app="nginx"} |= "ERROR" [5m]))
   ```

4. **Extract and Count Status Codes from Logs:**  

   ```logql
   {app="nginx"} | pattern <_> - - <_> "<_> <_> <_>" <status> <_> | count_over_time([5m]) by (status)
   ```

---

# **9. Using Prometheus in Grafana**  

### **Step 1: Add Prometheus as a Data Source**  

1. Navigate to **Configuration > Data Sources**.  
2. Click **Add data source**.  
3. Select **Prometheus**.  
4. Enter the Prometheus server URL (e.g., `http://localhost:9090`).  
5. Click **Save & Test**.  

### **Step 2: Create a Dashboard with Prometheus Data**  

1. Click **+ Create > Dashboard**.  
2. Click **Add new panel**.  
3. Select **Prometheus** as the data source.  
4. Write a PromQL query (e.g., `rate(http_requests_total[5m])`).  
5. Click **Apply** to add it to the dashboard.  

---

# **10. Using Loki in Grafana**  

### **Step 1: Add Loki as a Data Source**  

1. Navigate to **Configuration > Data Sources**.  
2. Click **Add data source**.  
3. Select **Loki**.  
4. Enter the Loki server URL (e.g., `http://localhost:3100`).  
5. Click **Save & Test**.  

### **Step 2: Create a Logs Panel in Grafana**  

1. Create a new panel in the dashboard.  
2. Select **Loki** as the data source.  
3. Enter a LogQL query (e.g., `{app="nginx"} |= "ERROR"`).  
4. Click **Apply** to display logs.  

---

## **11. Best Practices for Grafana Dashboards**  

### **For Prometheus Queries:**  

- Use `rate()` for counters to get an accurate per-second rate.  
- Use `sum()` and `avg()` to aggregate data meaningfully.  
- Group data using `by()` to analyze trends across dimensions.  
- Optimize dashboard performance by limiting query range and resolution.  

### **For Loki Queries:**  

- Always filter using labels (`{app="myapp"}`) to avoid scanning all logs.  
- Use `|=` for searching within logs efficiently.  
- Parse logs with `json` or `pattern` to extract structured data.  
- Reduce data volume with `count_over_time()` when analyzing log frequency.  

---

## **Conclusion**  

Grafana, when integrated with Prometheus and Loki, provides a powerful monitoring and logging solution. By using PromQL and LogQL effectively, you can build insightful dashboards to monitor system performance, detect anomalies, and debug application issues efficiently.