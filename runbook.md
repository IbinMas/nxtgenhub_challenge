
# **Runbook: Managing and Maintaining the Web Server Solution**

This runbook provides instructions for administering and maintaining the "Hello, World!" web server deployed using Kubernetes and Helm. It includes scaling, logging, monitoring, and troubleshooting procedures.

---

## **1. Scaling**

### **Scaling Replicas**
To adjust the number of replicas of the web server, use the following command:

```bash
kubectl scale deployment webserver --replicas=<number-of-replicas>
```

For example, to scale the deployment to 3 replicas:

```bash
kubectl scale deployment webserver --replicas=3
```

### **Scaling via Helm Values**
Alternatively, update the `replicaCount` field in the `values.yaml` file of the Helm chart and apply the update:

```yaml
replicaCount: 3
```

Deploy the updated configuration:

```bash
helm upgrade webserver ./webserver-chart
```

---

## **2. Logging**

### **Viewing Logs**
To troubleshoot or monitor the web server, view the logs of the running pods:

```bash
kubectl logs <pod-name>
```

If multiple replicas are running, list all pods to identify the pod name:

```bash
kubectl get pods
```

View logs for a specific pod:

```bash
kubectl logs webserver-<pod-id>
```

### **Real-time Logs**
For streaming logs in real-time:

```bash
kubectl logs -f <pod-name>
```

---

## **3. Updating the Deployment**

### **Updating the Docker Image**
To deploy a new version of the web server, update the `image` field in the `values.yaml` file of the Helm chart:

```yaml
image:
  repository: your-docker-repo/hello-world-webserver
  tag: <new-version>
  pullPolicy: IfNotPresent
```

Apply the update with:

```bash
helm upgrade webserver ./webserver-chart
```

---

## **4. Monitoring**

### **Prometheus Metrics**
(Optional) If Prometheus is installed, it can monitor the web server and other cluster components. Verify Prometheus is scraping metrics by checking the **Targets** page.

To port-forward Prometheus for local access:

```bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n kube-system
```

Open Prometheus at:

```plaintext
http://localhost:9090
```

---

## **5. Troubleshooting**

### **Common Issues**
#### **1. Ingress Misconfiguration**
Symptoms: Unable to access the web server through the ingress.

Steps to troubleshoot:
- Verify ingress resources:
  ```bash
  kubectl get ingress
  ```
- Check ingress logs (if applicable):
  ```bash
  kubectl logs <ingress-pod-name>
  ```

Ensure the ingress hostname matches your DNS or LoadBalancer hostname.

#### **2. Image Pull Errors**
Symptoms: Pods fail to start due to `ImagePullBackOff`.

Steps to troubleshoot:
- Verify the image repository and tag in the `values.yaml` file.
- Check pod events for details:
  ```bash
  kubectl describe pod <pod-name>
  ```
- Ensure the image exists in the specified repository and that credentials (if required) are configured in Kubernetes.

#### **3. Resource Exhaustion**
Symptoms: Pods are evicted or fail due to insufficient resources.

Steps to troubleshoot:
- Check pod status:
  ```bash
  kubectl get pods
  ```
- View cluster resource usage:
  ```bash
  kubectl top nodes
  kubectl top pods
  ```
- Scale up the cluster or adjust resource requests/limits in the Helm chart:
  ```yaml
  resources:
    requests:
      memory: "64Mi"
      cpu: "250m"
    limits:
      memory: "128Mi"
      cpu: "500m"
  ```

#### **4. Helm Upgrade Issues**
Symptoms: Helm upgrade fails or doesn't apply changes.

Steps to troubleshoot:
- Check for syntax errors in the Helm chart or `values.yaml`.
- Use the `--debug` and `--dry-run` flags to simulate the deployment:
  ```bash
  helm upgrade webserver ./webserver-chart --dry-run --debug
  ```
- Roll back to the previous release if necessary:
  ```bash
  helm rollback webserver <revision-number>
  ```

---

## **6. Maintenance Best Practices**

### **Regular Tasks**
- Periodically check the status of all resources:
  ```bash
  kubectl get all -n <namespace>
  ```
- Monitor logs for anomalies.
- Test scaling and updates in a staging environment before applying to production.

### **Security Updates**
- Regularly update Docker images to the latest secure versions.
- Use `cert-manager` to automate HTTPS certificates for secure communication.

