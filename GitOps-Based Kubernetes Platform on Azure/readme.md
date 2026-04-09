### Project — GitOps-Based Kubernetes Platform on Azure

A production-style platform that deploys and manages containerized applications on Azure Kubernetes Service using GitOps, with full CI, multi-environment setup, and observability.

Architecture
```
GitHub Repository
        │
        ├──► GitHub Actions (CI - build & push image)
        │
        ▼
Argo CD (GitOps)
        │
        ▼
AKS (Azure Kubernetes Service)
        │
        ├── Helm (application deployment)
        ├── Namespaces (dev / stage / prod)
        ├── PostgreSQL
        ├── Prometheus
        └── Grafana
```
Key Features:

- GitOps-based deployment using Argo CD
- Multi-environment setup (dev, stage, prod) with isolated configurations
- CI pipeline with GitHub Actions for building and pushing Docker images
- Infrastructure provisioned with Terraform
- Application deployment managed via Helm charts
- Observability stack with Prometheus and Grafana
- Stateful component using PostgreSQL

Scope:

- Separation of CI (build) and CD (GitOps-driven deployment)
- Automated synchronization between Git repository and Kubernetes cluster
- Self-healing mechanism ensuring cluster state consistency
- Environment-specific configuration and scaling strategy

Tech Stack
Azure, Kubernetes (AKS), Docker, Terraform, Helm, Git, GitHub Actions, Argo CD, Prometheus, Grafana, PostgreSQL