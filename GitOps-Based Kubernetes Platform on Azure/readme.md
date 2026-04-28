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
        ├── Namespaces (dev / prod)
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

### Prerequisites:

First things first we need to generate the `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_CREDENTIALS` secrets and put it into Github Secrets and variables.

```
az ad sp create-for-rbac \
  --name "github-actions-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/TWOJ_SUBSCRIPTION_ID" \
  --sdk-auth
```

### Project2_ci_infrastructure:

This pipeline creates whole environment based on `/terraform/` directory. Worflow sequence:
- `terraform-lint` -> checks terraform syntax,
- `terraform init`, `terraform plan`, `terraform apply` -> creates all resources (as terraform is declarative instead of imperative it creates only missing resources),
- `install ArgoCD` -> using `kubectl` it installs ArgoCD,
- `kubectl  create namespace dev`, `kubectl create namespace prod` -> creating `dev` and `prod` namespaces in Kubernetes.

If you're creating new environment after `terraform destroy` we need to refresh the kubeconfig:
```yaml
az aks get-credentials \
--resource-group gitops_rg2345234 \
--name example-aks1_test234 \
--overwrite-existing
```

and
```yaml
az aks update \
  --resource-group gitops_rg2345234 \
  --name example-aks1_test234 \
  --attach-acr gitopscontainerregistry7677
```

### Project2_ci_build:

This pipeline is building and pushing Docker image to ACR and updating image tag (in `gitops/dev`). Only `ArgoCD` is watching any changes on the repo and commiting the changes if needed.

To enter the ArgoCD console we need to add LoadBalancer using:

```yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

#ArgoCD console admin password:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

To check what image is used for `dev` and `prod` deployments:

```bash
echo "DEV:"
kubectl describe pod -n dev | grep "Image:"
echo "PROD:"
kubectl describe pod -n prod | grep "Image:"
```