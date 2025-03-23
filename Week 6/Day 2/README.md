# Accessing Grafana

### 1. Starting Minikube and Accessing Grafana  
First, ensure Minikube is running by executing:  
```bash
minikube start
```  
Next, verify that the Grafana pod is up and running within the `monitoring` namespace:  
```bash
kubectl get pods -n monitoring
```  
If Grafana is running, you can access it locally by setting up port forwarding:  
```bash
kubectl port-forward svc/grafana -n monitoring 3000:80
```  
Now, open a browser and go to:  
[http://localhost:3000](http://localhost:3000)  

---

### 2. Exporting Dashboards  
To export a Grafana dashboard:  
1. Open Grafana and navigate to the dashboard you want to export.  
2. Click on the **Dashboard settings** (gear icon).  
3. Select **JSON Model** and click **Download JSON** to export it.  
4. The dashboard JSON file will be saved to your local machine.  

---

### 3. Importing Dashboards Back into Grafana  
To restore a previously exported dashboard:  
1. Open Grafana and go to the **Dashboards** section.  
2. Click **Import** and upload the saved JSON file.  
3. If needed, modify the **UID** to avoid conflicts.  
4. Click **Create**, and the dashboard will be available for use.  

---

### 4. Locating Dashboards Inside the Grafana Pod  
Grafana stores dashboards inside the pod, and you can locate them as follows:  
1. Get the name of the running Grafana pod:  
   ```bash
   kubectl get pod -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath="{.items[0].metadata.name}"
   ```  
2. Access the Grafana pod’s shell:  
   ```bash
   kubectl exec -it <grafana-pod-name> -n monitoring -- /bin/sh
   ```  
3. Find dashboard JSON files inside the pod:  
   ```bash
   find /var/lib/grafana -name "*.json"
   ```  

---

### 5. Copying Dashboards from Grafana Pod to Local Machine  
To transfer a dashboard JSON file from the Grafana pod to your local system, use:  
```bash
kubectl cp monitoring/<grafana-pod-name>:/var/lib/grafana/dashboards/default/dashboard.json ./dashboard.json
```  

---

### 6. Verifying Import & Access  
Once the dashboard is imported:  
- Check that it appears correctly in Grafana.  
- Ensure all panels are visible and data sources are correctly configured.  
- Update any missing configurations if necessary.  

This process ensures smooth dashboard management in Grafana within a Minikube environment. 