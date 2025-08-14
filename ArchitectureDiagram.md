# 🚀 Production-Grade MLOps Pipeline on AWS EKS

<div align="center">

![MLOps Architecture](https://img.shields.io/badge/Architecture-Production%20Ready-success?style=for-the-badge)
![AWS](https://img.shields.io/badge/AWS-Cloud%20Native-orange?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Container%20Orchestration-blue?style=for-the-badge&logo=kubernetes&logoColor=white)

</div>

---

## 🏗️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                           AWS Cloud                             │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    EKS Cluster                          │    │
│  │                                                         │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │    │
│  │  │   Airflow   │  │   MLflow    │  │  Prometheus │      │    │
│  │  │ Scheduler   │  │   Server    │  │  & Grafana  │      │    │
│  │  │ & Workers   │  │             │  │             │      │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘      │    │
│  │                                                         │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │    │
│  │  │   FastAPI   │  │   KServe    │  │   Ingress   │      │    │
│  │  │ Model API   │  │   Serving   │  │ Controller  │      │    │
│  │  │             │  │             │  │             │      │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘      │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │     S3      │  │     RDS     │  │     ECR     │              │
│  │  (Data &    │  │(PostgreSQL) │  │ (Container  │              │
│  │ Artifacts)  │  │             │  │  Registry)  │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ CloudWatch  │  │     VPC     │  │     IAM     │              │
│  │  (Logging)  │  │ (Networking)│  │   (Auth)    │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      External Systems                           │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   GitHub    │  │   DVC       │  │   CI/CD     │              │
│  │  (Code)     │  │(Data Ver.)  │  │ (Actions)   │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 MLOps Platform Architecture Overview

This architecture provides a comprehensive MLOps platform utilizing AWS cloud services and Kubernetes orchestration for scalable, production-ready machine learning operations.

### 🎯 **Core Components**

**Infrastructure Layer:**
- GitHub/GitLab → CI/CD (GitHub Actions or Jenkins)
- DVC ↔ S3
- MLflow Tracking → RDS (PostgreSQL) + S3
- Training Jobs on EKS (Dockerized)
- Airflow DAGs (running on EKS)
- MLflow Registry
- FastAPI/KServe (EKS)
- Prometheus + Grafana (EKS)
- Logs → AWS CloudWatch
- Ingress via NGINX/ALB + TLS + DNS (e.g., mlflow.myorg.com)

---

## ⚙️ Kubernetes Configurations

### 🔧 **MLflow Deployment**

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mlflow
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mlflow
  template:
    metadata:
      labels:
        app: mlflow
    spec:
      containers:
        - name: mlflow
          image: mlflow/mlflow:latest
          args: ["mlflow", "server", "--backend-store-uri", "postgresql://<rds-uri>", "--default-artifact-root", "s3://mlflow-artifacts"]
          env:
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: aws-creds
                  key: access_key
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: aws-creds
                  key: secret_key
          ports:
            - containerPort: 5000
```

### 🌬️ **Airflow Helm Values** (via Astronomer Chart)

```yaml
webserver:
  service:
    type: ClusterIP
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      - airflow.myorg.com
    tls:
      - secretName: airflow-tls
        hosts:
          - airflow.myorg.com

dags:
  persistence:
    enabled: true
    existingClaim: airflow-dags-pvc

executor: KubernetesExecutor
logs:
  persistence:
    enabled: false
```

### 📊 **Prometheus and Grafana Configuration**

```bash
# helm install prometheus prometheus-community/kube-prometheus-stack
```

```yaml
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false

grafana:
  adminPassword: "<secure-password>"
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      - grafana.myorg.com
    tls:
      - secretName: grafana-tls
        hosts:
          - grafana.myorg.com
```

---

## 🐳 Docker Configuration

### **Training Dockerfile**

```dockerfile
FROM python:3.10
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "train.py"]
```

### **FastAPI Serving Dockerfile**

```dockerfile
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.10
COPY ./app /app
```

---

## 🔄 CI/CD Pipelines (GitHub Actions)

### **MLOps Pipeline Configuration**

```yaml
name: MLOps Pipeline
on:
  push:
    branches:
      - main
jobs:
  build-and-train:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.10'

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Train model
        run: python train.py

      - name: Log to MLflow
        run: python log_to_mlflow.py

      - name: Build & Push Docker Image
        run: |
          docker build -t <ECR_URI>:latest .
          aws ecr get-login-password | docker login --username AWS --password-stdin <ECR_URI>
          docker push <ECR_URI>:latest

      - name: Deploy to Kubernetes
        run: kubectl apply -f k8s/deployment.yaml
```

---

## 📈 Monitoring Configuration

### **Prometheus Scrape Configuration**

```yaml
scrape_configs:
  - job_name: 'airflow'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: airflow
```

### **Grafana Dashboard**
- Use Airflow, MLflow, KServe exporters
- Dashboard panels: pipeline duration, success rate, training time, drift alerts

---

## 🔐 Security & Access Management

### **Security Features:**
- **IRSA**: IAM Role for Service Account for MLflow, Airflow to access S3, RDS
- **TLS**: Cert-Manager for automatic HTTPS certificates
- **RBAC**: RoleBindings for Airflow and MLflow UIs

---

## 🏛️ Infrastructure as Code (Terraform)

### **EKS & VPC Configuration**
- `terraform-aws-eks` module
- `terraform-aws-vpc` module

### **Sample Terraform Block**

```hcl
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "mlops-cluster"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  node_groups = {
    general = {
      desired_capacity = 2
      instance_types   = ["t3.medium"]
    }
    spot = {
      desired_capacity = 3
      instance_types   = ["t3.medium", "t3.large"]
      spot             = true
    }
  }
}
```

---

## 🌐 External Access URLs

<div align="center">

| Service | URL | Description |
|---------|-----|-------------|
| **MLflow** | `https://mlflow.myorg.com` | MLflow UI & Tracking |
| **Airflow** | `https://airflow.myorg.com` | Workflow Management |
| **Grafana** | `https://grafana.myorg.com` | Monitoring Dashboards |

</div>

---

## ⚡ Optimization Recommendations

<div align="left">

- **EKS Configuration**: Use EKS Managed Node Groups with mixed On-Demand and Spot instances
- **Auto Scaling**: Enable Cluster Autoscaler for dynamic resource management
- **Resource Management**: Configure proper Resource Requests/Limits
- **Storage Optimization**: Use S3 Lifecycle Rules for artifacts management
- **GPU Support**: Use NVIDIA GPU node group with tolerations for model training
- **Cost Optimization**: Implement cost allocation insights via CloudWatch

</div>

---

<div align="center">

### 🎯 **Production-Ready MLOps at Scale**

*Built for reliability, scalability, and operational excellence*

</div>