# 🚀 MLOps System Design and Hands-on Experience

<div align="center">

![MLOps Banner](https://img.shields.io/badge/MLOps-Production%20Ready-blue?style=for-the-badge)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

</div>

---

## 📋 Overview

This repository is a **one-stop MLOps solution** for building, deploying, and managing machine learning models in production using industry-standard tools such as **Kubernetes, MLflow, Airflow, Terraform, Docker, FastAPI, and KServe**.

---

## 📂 Project Structure

```plaintext
.
├── .github/
│   └── workflows/
│       └── mlops-pipeline.yml        # CI/CD workflow
├── docker/
│   ├── Dockerfile.train              # Image for model training
│   └── Dockerfile.api                # Image for model serving
├── k8s/
│   ├── airflow-values.yaml           # Helm values for Airflow
│   ├── mlflow-values.yaml            # Helm values for MLflow
│   ├── ingress.yaml                  # Ingress routing
├── kserve/
│   └── deploy.yaml                   # KServe model serving deployment
├── terraform/
│   ├── eks.tf
│   ├── vpc.tf
│   └── rds.tf
├── training/
│   ├── train.py
│   └── log_to_mlflow.py
├── serving/
│   └── app/
│       ├── main.py
│       └── model_loader.py
├── Makefile                          # Reproducible automation
└── run.sh                            # Bootstrap script
└── README.md                         # You're here!
```

---

## 🎯 Goals

<div align="left">

* ✅ **Full MLOps pipeline**: train, track, deploy, monitor
* ✅ **Reproducible infrastructure** (IaC with Terraform + EKS)
* ✅ **CI/CD** with GitHub Actions
* ✅ **Scalable model serving** with KServe and FastAPI
* ✅ **Experiment tracking** with MLflow
* ✅ **Workflow orchestration** using Airflow
* ✅ **Ingress, secrets, and production security practices**

</div>

---

## 🛠️ Tools and Tech Stack

<table>
<thead>
<tr>
<th>Layer</th>
<th>Tool</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>Infrastructure</strong></td>
<td>AWS, Terraform, EKS, RDS</td>
</tr>
<tr>
<td><strong>Orchestration</strong></td>
<td>Apache Airflow</td>
</tr>
<tr>
<td><strong>Experiment Tracking</strong></td>
<td>MLflow</td>
</tr>
<tr>
<td><strong>CI/CD</strong></td>
<td>GitHub Actions</td>
</tr>
<tr>
<td><strong>Serving</strong></td>
<td>KServe, FastAPI</td>
</tr>
<tr>
<td><strong>Containerization</strong></td>
<td>Docker</td>
</tr>
<tr>
<td><strong>Monitoring</strong></td>
<td>CloudWatch (future: Prometheus + Grafana)</td>
</tr>
<tr>
<td><strong>Security & Auth</strong></td>
<td>AWS Secrets Manager, Ingress + TLS</td>
</tr>
</tbody>
</table>

---

## ⚡ Quick Start

### 1️⃣ Setup Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

**This provisions:**
- EKS cluster
- VPC and subnets
- RDS PostgreSQL for MLflow and Airflow metadata

---

### 2️⃣ Build and Push Docker Images

```bash
# Train image
docker build -t mlops-train -f docker/Dockerfile.train .

# API image
docker build -t mlops-api -f docker/Dockerfile.api .
```

Push to your container registry (e.g., ECR or Docker Hub).

---

### 3️⃣ Deploy to Kubernetes

```bash
kubectl apply -f k8s/mlflow-deployment.yaml
kubectl apply -f k8s/ingress.yaml
```

**Helm-based Airflow deployment:**

```bash
helm repo add apache-airflow https://airflow.apache.org
helm install airflow apache-airflow/airflow -f k8s/airflow-values.yaml
```

---

### 4️⃣ Train and Log Model

```bash
python training/train.py
python training/log_to_mlflow.py
```

---

### 5️⃣ Serve Model

```bash
kubectl apply -f kserve/deploy.yaml
```

**Or use FastAPI server locally:**

```bash
uvicorn serving.app.main:app --host 0.0.0.0 --port 8000
```

---

### 6️⃣ Trigger CI/CD

CI/CD is triggered on pushes to `main` via `.github/workflows/mlops-pipeline.yml`.

---

## 🔧 Makefile Commands

```bash
make build-api         # Build API Docker image
make train             # Run training locally
make deploy-k8s        # Apply all Kubernetes manifests
```

---

## 📝 TODO and Improvements

<div align="left">

- [ ] Add Prometheus + Grafana for monitoring
- [ ] Add unit and integration tests
- [ ] Add S3 as MLflow artifact store
- [ ] Implement canary/blue-green deployments with KServe
- [ ] Add custom DAGs for retraining in Airflow
- [ ] Add cost allocation insights via CloudWatch

</div>

---

## 🤝 Contributing

1. **Fork the repo**
2. **Create your branch**: `git checkout -b feature/xyz`
3. **Commit changes**: `git commit -am 'Add new feature'`
4. **Push and raise PR**

---

## 📬 Contact

<div align="center">

Made with ❤️ by [**Pannagendra KL**](https://github.com/Pannagendra)

</div>

---

## 📄 License

This project is licensed under the **MIT License**.

---

<div align="center">

### Built with ❤️ for the MLOps community

⭐ **Star this repo if it helped you build better MLOps systems!** ⭐

</div>
