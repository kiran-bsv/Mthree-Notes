# **Table of Contents**  

1️⃣ **[Introduction](#introduction)**  
   - Overview of Kubernetes Configuration  
   - Components Covered  

2️⃣ **[Namespace: Organizing the Application](#namespace-organizing-the-application)**  
   - Definition & Purpose  
   - Namespace YAML Configuration  

3️⃣ **[ConfigMap: Storing Configuration](#configmap-storing-configuration)**  
   - Definition & Purpose  
   - ConfigMap YAML Configuration  

4️⃣ **[Deployment: Managing Pods](#deployment-managing-pods)**  
   - Definition & Purpose  
   - [Deployment YAML Breakdown](#deployment-yaml-breakdown)  
     - [Pod Template](#pod-template)  
     - [Container Configuration](#container-configuration)  
     - [Port & Environment Variables](#port-environment-variables)  
     - [Resource Allocation](#resource-allocation)  
     - [Health Checks (Liveness & Readiness Probes)](#health-checks-liveness-readiness-probes)  

5️⃣ **[Service: Exposing the Application](#service-exposing-the-application)**  
   - Definition & Purpose  
   - [Service Types (ClusterIP, NodePort, LoadBalancer)](#service-types-clusterip-nodeport-loadbalancer)  
   - [Port Mapping & YAML Configuration](#port-mapping-yaml-configuration)  

6️⃣ **[Summary of Components](#summary-of-components)**  
   - Table Comparing Different Components  

7️⃣ **[How to Deploy the Application](#how-to-deploy-the-application)**  
   - Applying Kubernetes Configuration  
   - Checking Deployed Resources  
   - Viewing Pod Logs  
   - Accessing the Flask Application  

8️⃣ **[Conclusion](#conclusion)**  
   - Scalability & Fault Tolerance in Kubernetes  
   - Key Takeaways  

9️⃣ **[Difference Between Namespace, Name, and Labels](#difference-between-namespace-name-and-labels)**  
   - Namespace: Logical Resource Grouping  
   - Name: Unique Identifier for Resources  
   - Labels: Tagging & Filtering Resources  

🔟 **[Comparison Table: Namespace vs. Name vs. Labels](#comparison-table-namespace-vs-name-vs-labels)**  

---

The Kubernetes configuration defines a **namespace, ConfigMap, Deployment, and Service** for deploying a Flask-based application inside a Kubernetes cluster. Let's break it down step by step.

---

## 1️⃣ **Namespace: Organizing the Application**  
A **namespace** is like a separate workspace in Kubernetes, allowing multiple projects to run without interfering with each other.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mini-demo
  labels:
    name: mini-demo
```
- **apiVersion**: `v1` (Namespace is a core Kubernetes object).
- **kind**: `Namespace` (Defines a new namespace).
- **metadata**: Specifies the name (`mini-demo`) and labels.
- **Purpose**: Groups all application resources under `mini-demo` to keep them isolated from other deployments.

---

## 2️⃣ **ConfigMap: Storing Configuration**  
A **ConfigMap** stores environment variables, configurations, or settings separately from the application code.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: mini-demo
data:
  APP_NAME: "Kubernetes Mini Demo"
  APP_VERSION: "1.0.0"
```
- **kind**: `ConfigMap` (Stores configuration data).
- **namespace**: `mini-demo` (Ensures it's only accessible within this namespace).
- **data**: Key-value pairs (these become environment variables in the pods).
- **Purpose**: Instead of hardcoding values in the application, they are injected dynamically.

---

## 3️⃣ **Deployment: Managing Pods**  
A **Deployment** ensures the desired number of replicas (pods) of a containerized application are running.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
  namespace: mini-demo
  labels:
    app: flask-app
spec:
  replicas: 2
```
- **apiVersion**: `apps/v1` (Deployment is a higher-level API object).
- **kind**: `Deployment` (Manages pod replicas and updates).
- **metadata**: 
  - `name: flask-app` (Deployment name).
  - `namespace: mini-demo` (Belongs to the `mini-demo` namespace).
  - `labels: app: flask-app` (Used for identification).

### **Pod Template (Inside Deployment)**
The `template` section defines how each pod should be created:

```yaml
  selector:
    matchLabels:
      app: flask-app
```
- **selector**: Matches pods with label `app: flask-app`.

```yaml
  template:
    metadata:
      labels:
        app: flask-app
```
- **metadata**: Assigns the `flask-app` label to pods.

```yaml
    spec:
      containers:
      - name: flask-app
        image: mini-k8s-demo:latest
        imagePullPolicy: Never  # Use local image (for Minikube)
```
- **Containers**:
  - `name`: `flask-app` (Container name inside the pod).
  - `image`: `mini-k8s-demo:latest` (Docker image used for the application).
  - `imagePullPolicy: Never` (Does not fetch from a remote registry, useful in Minikube).

### **Port and Environment Configuration**
```yaml
        ports:
        - containerPort: 5000
          name: http
```
- **Exposes port 5000** inside the container (Flask default).

```yaml
        envFrom:
        - configMapRef:
            name: app-config
```
- **Loads environment variables** from `ConfigMap` (`app-config`).

### **Resource Allocation**
```yaml
        resources:
          requests:
            cpu: "100m"     # Requests 0.1 CPU
            memory: "64Mi"  # Requests 64MB RAM
          limits:
            cpu: "200m"     # Maximum 0.2 CPU
            memory: "128Mi" # Maximum 128MB RAM
```
- **Requests**: Minimum resources the container needs.
- **Limits**: Maximum resources it can consume.

### **Health Checks (Liveness & Readiness Probes)**
```yaml
        livenessProbe:
          httpGet:
            path: /api/health
            port: http
          initialDelaySeconds: 10
          periodSeconds: 30
```
- **Liveness Probe**:
  - Checks `/api/health` endpoint.
  - Starts **after 10 seconds**.
  - Runs **every 30 seconds**.
  - If it fails, Kubernetes restarts the container.

```yaml
        readinessProbe:
          httpGet:
            path: /api/health
            port: http
          initialDelaySeconds: 5
          periodSeconds: 10
```
- **Readiness Probe**:
  - Determines when the pod is ready to serve traffic.
  - Starts **after 5 seconds**.
  - Runs **every 10 seconds**.
  - If it fails, the pod is **removed from the load balancer**.

---

## 4️⃣ **Service: Exposing the Application**
A **Service** routes network traffic to pods.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-app
  namespace: mini-demo
  labels:
    app: flask-app
```
- **kind**: `Service` (Manages network traffic).
- **namespace**: `mini-demo` (Ensures isolation).
- **selector**: Routes traffic to pods with `app: flask-app`.

### **Service Types**
```yaml
spec:
  type: NodePort
```
- **`ClusterIP` (default)**: Only accessible inside the cluster.
- **`NodePort`**: Exposes it on a static port across all nodes.
- **`LoadBalancer`**: Uses a cloud provider’s external load balancer.

### **Port Configuration**
```yaml
  ports:
  - port: 80           # Exposed service port
    targetPort: 5000   # Container's Flask app port
    nodePort: 30080    # Node port (between 30000-32767)
    protocol: TCP
```
- **Port Mapping**:
  - **`port: 80`** → The Service exposes this port.
  - **`targetPort: 5000`** → The Flask app listens on port 5000.
  - **`nodePort: 30080`** → Accessible on the Kubernetes node IP.

---

## **Summary**
| Component        | Purpose |
|-----------------|---------|
| **Namespace (`mini-demo`)** | Isolates resources in Kubernetes. |
| **ConfigMap (`app-config`)** | Stores environment variables (e.g., app name & version). |
| **Deployment (`flask-app`)** | Ensures 2 running replicas of the Flask app. |
| **Pod (`flask-app`)** | Runs the Flask app inside a container. |
| **Service (`flask-app`)** | Routes external traffic to the Flask application. |

## **How to Deploy**
### 1️⃣ **Apply all configurations**
```bash
kubectl apply -f deployment.yaml
```

### 2️⃣ **Check created resources**
```bash
kubectl get namespaces
kubectl get pods -n mini-demo
kubectl get svc -n mini-demo
```

### 3️⃣ **Check pod logs**
```bash
kubectl logs -n mini-demo <pod-name>
```

### 4️⃣ **Access the Flask app**
Find the **Minikube IP**:
```bash
minikube ip
```
Access the application:
```
http://<minikube-ip>:30080/
```

---
## **Conclusion**
This setup provides a **scalable, fault-tolerant** Flask application in Kubernetes.  
- The **Deployment** ensures the application runs with redundancy.  
- The **ConfigMap** externalizes configuration.  
- The **Service** allows external access via **NodePort**.  

---

### **Difference Between Namespace, Name, and Labels in Kubernetes**

1. **Namespace**  
   - A Kubernetes **Namespace** is a way to logically divide cluster resources among multiple users or applications.  
   - It helps in organizing and managing resources in a large Kubernetes cluster.  
   - Each resource inside a namespace must have a **unique name**, but different namespaces can have resources with the same name.  
   - Example:
     ```yaml
     apiVersion: v1
     kind: Namespace
     metadata:
       name: mini-demo
     ```
   - Here, `mini-demo` is the **namespace**, meaning all the resources (Pods, Deployments, Services, etc.) defined within it are logically grouped under this namespace.

---

2. **Name**  
   - The **name** field is a unique identifier for a specific Kubernetes resource within a **namespace**.  
   - It allows users to reference a specific resource when running `kubectl` commands.  
   - Example:
     ```yaml
     apiVersion: v1
     kind: ConfigMap
     metadata:
       name: app-config
       namespace: mini-demo
     ```
   - Here, `app-config` is the **name** of the ConfigMap inside the `mini-demo` namespace.

---

3. **Labels**  
   - **Labels** are key-value pairs assigned to Kubernetes resources for identification, grouping, and selection.  
   - Labels do **not** have to be unique and can be used to **group and filter** resources.  
   - Example:
     ```yaml
     metadata:
       labels:
         app: flask-app
     ```
   - Here, the label `app: flask-app` is applied to a resource, making it easier to select this resource using label selectors.  
   - Labels are primarily used for:
     - **Selectors in Deployments, Services, etc.** to manage related resources.
     - **Grouping resources** logically.

---

| Feature    | Purpose |
|------------|---------|
| **Namespace** | Logical separation of resources within a Kubernetes cluster. |
| **Name** | Unique identifier for a resource within a namespace. |
| **Labels** | Key-value metadata for grouping, selecting, and managing resources. |

---

### **What is `app:` in `labels`?**  

In Kubernetes, the `app:` label is a **key-value pair** used to **identify and group** resources. It is a **custom label key** that helps categorize resources logically.

#### **Breaking it Down:**
```yaml
metadata:
  labels:
    app: flask-app
```
- **`app`** → This is the **key** (a custom-defined label).
- **`flask-app`** → This is the **value** (indicating that this resource belongs to the `flask-app` application).

---

### **Why Use the `app:` Label?**
1. **Grouping Related Resources**  
   - If multiple resources (Pods, Services, Deployments) belong to the same application, they can share the same `app:` label.
   - Example: All resources related to `flask-app` can be labeled as `app: flask-app`.

2. **Selectors in Kubernetes Resources**  
   - Kubernetes uses **selectors** to manage and associate resources based on labels.
   - Example: A **Deployment** selects Pods using this label:
     ```yaml
     selector:
       matchLabels:
         app: flask-app
     ```
   - This ensures the Deployment manages only the Pods labeled `app: flask-app`.

3. **Service Discovery & Networking**  
   - A **Service** routes traffic to Pods based on the `app:` label:
     ```yaml
     selector:
       app: flask-app
     ```
   - This means only Pods with `app: flask-app` receive traffic from the Service.

---

### **Example of Using `app:` Label Across Multiple Resources**
#### **Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
  labels:
    app: flask-app
spec:
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
```

#### **Service**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-service
spec:
  selector:
    app: flask-app
  ports:
    - port: 80
      targetPort: 5000
```
- The **Service** will route traffic only to Pods with `app: flask-app`.

---

### **Key Takeaways**
| Concept | Purpose |
|---------|---------|
| `app:` Label | A key-value pair to **group resources** under the same application. |
| Used in **selectors** | Deployments, Services, and other controllers use it to **select resources**. |
| Helps with **networking** | Services use it to **route traffic** to the correct Pods. |

**Conclusion:** The `app:` label is **not built-in** but is a **convention** commonly used to group related Kubernetes resources. 🚀

---

### **Understanding the Role of Kubernetes Files in the Master-Worker Node Architecture**  

## **🚀 Master and Worker Node Architecture Overview**
A Kubernetes cluster consists of:  
- **Master Node (Control Plane)**: Responsible for managing and scheduling workloads.  
  - 📌 **Key components**: API Server, Scheduler, Controller Manager, etcd.  
- **Worker Nodes**: Execute applications (Pods & Containers) and report back to the master.  
  - 📌 **Key components**: Kubelet, Kube Proxy, Container Runtime.

---

## **📄 Your Kubernetes Files and Their Role in the Cluster**

### 1️⃣ **Namespace (`Namespace` file)**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mini-demo
  labels:
    name: mini-demo
```
#### **Role in the Cluster:**
- A **Namespace** provides a logical separation of resources within the cluster.
- Master **API Server** handles requests for this namespace.
- All defined resources (ConfigMap, Deployment, Service) exist within `mini-demo`.

**📌 In the Architecture:**  
✅ **Master Node (API Server, etcd)**  
- The **API Server** stores the namespace in **etcd** (Kubernetes' database).  
- The **Controller Manager** ensures the namespace exists in the cluster.

---

### 2️⃣ **Configuration (`ConfigMap` file)**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: mini-demo
data:
  APP_NAME: "Kubernetes Mini Demo"
  APP_VERSION: "1.0.0"
```
#### **Role in the Cluster:**
- Stores **non-sensitive** configuration values for the application.
- Used by **Pods** running on Worker Nodes.
- **Kubelet** ensures Pods load environment variables from the ConfigMap.

**📌 In the Architecture:**  
✅ **Master Node (API Server, etcd)**  
- The API Server registers this ConfigMap in etcd.  
✅ **Worker Nodes (Kubelet, Pods, Containers)**  
- Kubelet ensures Pods retrieve config values from the API Server.

---

### 3️⃣ **Deployment (`Deployment` file)**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
  namespace: mini-demo
  labels:
    app: flask-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: mini-k8s-demo:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 5000
          name: http
```
#### **Role in the Cluster:**
- **Deployment** tells Kubernetes to run **2 Pods** of `flask-app`.
- The **Scheduler** assigns these Pods to Worker Nodes.
- **Kubelet** on each Worker Node ensures the Pods run correctly.

**📌 In the Architecture:**  
✅ **Master Node (API Server, Scheduler, Controller Manager)**  
- **API Server** receives the Deployment request.  
- **Scheduler** finds available Worker Nodes to place the Pods.  
- **Controller Manager** ensures the correct number of Pods run.  
✅ **Worker Nodes (Kubelet, Pods, Containers)**  
- **Kubelet** on each node pulls the container image and starts the Pod.

---

### 4️⃣ **Service (`Service` file)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-app
  namespace: mini-demo
  labels:
    app: flask-app
spec:
  type: NodePort
  selector:
    app: flask-app
  ports:
  - port: 80
    targetPort: 5000
    nodePort: 30080
```
#### **Role in the Cluster:**
- **Exposes Pods to external traffic**.
- **Kube Proxy** on Worker Nodes routes traffic from **NodePort (30080)** to the right Pods.

**📌 In the Architecture:**  
✅ **Master Node (API Server, etcd, Controller Manager)**  
- The **API Server** stores and manages the Service configuration.  
✅ **Worker Nodes (Kube Proxy, Pods, Containers)**  
- **Kube Proxy** forwards requests from port **30080** to the appropriate Pod running `flask-app`.

---

## **📝 Summary Table**
| **Kubernetes File**  | **Master Node (Control Plane) Role** | **Worker Node Role** |
|---------------------|---------------------------------|------------------|
| **Namespace**       | Stored in **etcd**, managed by **API Server** | N/A |
| **ConfigMap**       | Stored in **etcd**, accessed via API Server | **Kubelet** ensures Pods load the config |
| **Deployment**      | **Scheduler** assigns Pods to Nodes, **Controller Manager** maintains desired state | **Kubelet** ensures Pods are running |
| **Service**         | API Server manages the service definition | **Kube Proxy** routes traffic to correct Pods |

---

## **🔥 How the Master & Worker Nodes Work Together**
1. **You apply these YAML files using `kubectl apply -f`**
2. **API Server** receives the request and stores it in **etcd**.
3. **Scheduler** assigns Pods to **Worker Nodes**.
4. **Kubelet** on each Worker Node ensures the assigned Pods run.
5. **Kube Proxy** routes external traffic to the correct Pods.
6. **Controller Manager** ensures desired state (e.g., 2 replicas of the app).

---

### **What is the use of 3 ports here in kubernetes ?**

In Kubernetes, a `Service` (especially of type `NodePort`) uses **three different ports** to route traffic. This is different from Docker, where we typically use only **two ports** (host port and container port).  

### **Understanding the Three Ports**
```yaml
  ports:
  - port: 80           # (1) Service Port
    targetPort: 5000   # (2) Container Port
    nodePort: 30080    # (3) Node Port
```

1️⃣ **`port: 80` (Service Port)**  
   - This is the **port exposed by the Service** inside the Kubernetes cluster.  
   - Any **other pods within the same cluster** can access the service via `flask-app:80`.

2️⃣ **`targetPort: 5000` (Container Port)**  
   - This is the port where the application **inside the container** is listening (like `EXPOSE 5000` in Docker).  
   - Kubernetes forwards requests received at `port 80` to the application's container on port `5000`.

3️⃣ **`nodePort: 30080` (Node Port - Only for NodePort Service Type)**  
   - This is an **optional external port** that allows access **from outside the cluster**.  
   - Any node in the cluster will forward traffic from `http://<NodeIP>:30080` to the correct **Pod's Service Port (`80`)**.

---

### **How Requests Flow Through the Ports**
1️⃣ **External users** access the application using `http://<NodeIP>:30080`.  
2️⃣ The request **enters the Node** on port `30080` (NodePort).  
3️⃣ **Kube Proxy** forwards the request to the **Service on port `80`** (ClusterIP).  
4️⃣ The Service **routes traffic to a Pod** running the Flask app, **forwarding it to `5000`** (inside the container).  
5️⃣ The Flask app running inside the container **processes the request** and sends a response back.

---

### **Comparison with Docker (Why Only Two Ports in Docker?)**
In **Docker**, we typically use **only two ports**:
```sh
docker run -p 8080:5000 flask-app
```
- `8080` → Exposed **host** port.
- `5000` → **Container's** port.

Here, Docker directly maps `host:8080` to `container:5000`. But in Kubernetes, there is an **extra layer (Service)** to manage pod discovery, scaling, and internal routing.

---

### **When to Use These Ports**
| **Port** | **Use Case** | **Example in Kubernetes** |
|----------|-------------|--------------------------|
| `targetPort` | The port where the **containerized app** listens | Flask app runs on `5000` inside the Pod |
| `port` | The port exposed by the **Service** for internal cluster communication | Other Pods in the cluster call `flask-app:80` |
| `nodePort` | (Only for `NodePort` services) Exposes the service **externally** on each node | External access via `http://<NodeIP>:30080` |

---

## **Summary**
- **In Docker**, you expose only two ports: **host port → container port**.
- **In Kubernetes (`NodePort` Service)**, there are **three ports**:
  - `nodePort`: External access from outside the cluster.
  - `port`: Internal access within the cluster.
  - `targetPort`: Port inside the container where the app is running.

---

