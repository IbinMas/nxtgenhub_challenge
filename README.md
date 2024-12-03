# Hello, World! Web Server Deployment

This repository contains a Kubernetes-based deployment for a simple "Hello, World!" web server using Helm, Traefik as the ingress controller, and a LoadBalancer service.

## Features
- Kubernetes deployment with Helm.
- Configurable ingress routing via Traefik.
- Easily scalable and maintainable.

## Deployment Instructions
1. Set up a Kubernetes cluster (e.g., Minikube, Kind).
```bash
minikube docker-env
```
creating a local network tunnel: this will populate EXTERNAL-IP field for the LoadBalancer service (e.g., traefik)  with an IP address
```bash
minikube tunnel
```
Create a Kubernetes secret for image pull credentials:
```bash
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=<your-username> \
  --docker-password=<your-password> \
  --docker-email=<your-email>
```
Steps to Use the Chart:
```bash
helm package webserver-chart

```
3. Deploy the Helm chart:
```bash
   helm repo add traefik https://helm.traefik.io/traefik
   helm install traefik traefik/traefik --set service.type=LoadBalancer
   helm install hello-world-webserver ./webserver-chart
```
