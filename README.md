
# Hello, World! Web Server Deployment

This repository contains a Kubernetes-based deployment for a simple "Hello, World!" web server using Helm. The solution includes Traefik as the ingress controller, a LoadBalancer service for external access, Cert-Manager for TLS, and Prometheus for monitoring and alerting.

## Features
- **Kubernetes Deployment**: Managed using Helm charts for easy configuration and maintainability.
- **Ingress Controller**: Traefik configured as a LoadBalancer with TLS enabled using Cert-Manager and Let's Encrypt.
- **Scalability**: Easily scale replicas via `kubectl` or Helm values.
- **Monitoring**: Prometheus and Alertmanager for metrics and alerting.
- **Security**: TLS certificates managed automatically using Cert-Manager and Let's Encrypt.

---

## Deployment Instructions

### Minikube Setup

1. **Start Minikube:**
   ```bash
   minikube start
   ```

2. **Enable Minikube Tunnel:**
   ```bash
   minikube tunnel
   ```
   This creates a local network tunnel and populates the EXTERNAL-IP field for the LoadBalancer service (e.g., Traefik).

3. **Create a Docker Registry Secret:**
   ```bash
   kubectl create secret docker-registry regcred \
     --docker-server=https://index.docker.io/v1/ \
     --docker-username=<your-username> \
     --docker-password=<your-password> \
     --docker-email=<your-email>
   ```

4. **Deploy the Helm Chart:**
   - Package and deploy:
     ```bash
     helm package ./hello-world-webserver-chart
     helm install hello-world-webserver ./hello-world-webserver-chart
     ```
   - Install Traefik as the ingress controller:
     ```bash
     helm repo add traefik https://helm.traefik.io/traefik
     helm repo update
     helm install traefik traefik/traefik --set service.type=LoadBalancer
     ```

---

### EKS Setup

1. **Provision a Kubernetes Cluster on EKS:**
   - Follow the instructions in the Terraform `README.md` file to set up your EKS cluster.

2. **Configure `kubectl` to Connect to EKS:**
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name hello-world-webserver-eks-cluster
   kubectl get nodes
   ```

3. **Build and Push the Docker Image:**
   ```bash
   docker build -t <your-dockerhub-username>/hello-world-webserver:1.0 .
   docker push <your-dockerhub-username>/hello-world-webserver:1.0
   ```

4. **Deploy Prometheus:**
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
   ```
   Access Prometheus locally:
   ```bash
   kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090
   ```

5. **Install Cert-Manager for TLS:**
   ```bash
   helm repo add jetstack https://charts.jetstack.io
   helm repo update
   helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
   ```
   Verify Cert-Manager:
   ```bash
   kubectl get pods -n cert-manager
   ```

6. **Deploy the Web Server Helm Chart:**
   - Update Helm dependencies and install the chart:
     ```bash
     helm dependency update ./hello-world-webserver-chart
     helm install hello-world-webserver ./hello-world-webserver-chart
     ```
   - Verify the deployment:
     ```bash
     kubectl get all
     kubectl get ingress
     ```

---

## Monitoring and Alerting

1. **Enable Alerting in Prometheus:**
   - Edit `values.yaml` for the Prometheus Helm chart to configure basic alerts.
   - Deploy Alertmanager and configure routes for alerts.

2. **Visualize Metrics:**
   - Access Prometheus and monitor key metrics (e.g., request latencies, error rates, and resource usage).

---

## Security Enhancements

- **TLS with Cert-Manager**: TLS certificates are managed by Cert-Manager, leveraging Let's Encrypt.
- **Pod Security**: Add PodSecurityPolicies or PodSecurityStandards for stricter access control.

---

## Scalability

- Scale the web server using `kubectl` or Helm:
  ```bash
  kubectl scale deployment hello-world-webserver --replicas=3
  ```

---

## Additional Enhancements

- **CI/CD Pipelines**: Integrate with GitHub Actions or Jenkins for automated deployments.
- **Advanced Monitoring**: Add Grafana dashboards for better visualization of Prometheus metrics.
- **Autoscaling**: Configure Horizontal Pod Autoscalers for dynamic scaling based on CPU/memory usage.
- **Logging**: Integrate with logging solutions like EFK (Elasticsearch, Fluentd, Kibana) or Loki.
- Implement advanced security features such as network policies and RBAC hardening.

---

