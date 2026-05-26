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

This pipeline creates whole environment based on `terraform/` directory. Worflow sequence:
- `terraform-lint` -> checks terraform syntax,
- `terraform init`, `terraform plan`, `terraform apply` -> creates all resources (as terraform is declarative instead of imperative it creates only missing resources),
- `install ArgoCD` -> using `kubectl` it installs ArgoCD,
- `kubectl  create namespace dev`, `kubectl create namespace prod` -> creating `dev` and `prod` namespaces in Kubernetes.
- deploy `argocd-app-dev.yaml` and `argocd-app-prod.yaml` application using `kubectl apply -f "GitOps-Based Kubernetes Platform on Azure/gitops/argocd-app-dev.yaml"`

Based on different Helm values files proper environment will use correct values i.e. for `dev`:
```yaml
[...] #argocd-app-dev.yaml
    helm:
      valueFiles:
        - environment/dev/values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
[...]
```
- bootstrap monitoring objects -> using already created Kubernetes manifests the pipeline will create monitoring staff (also with previously created Grafana dashboard)
```yaml
[...]
      - name: Install Prometheus
        run: |
          kubectl create namespace monitoring
          kubectl apply -f "GitOps-Based Kubernetes Platform on Azure/gitops/monitoring/Prometheus/"
  
      - name: Install Grafana
        run: |
          kubectl apply -f "GitOps-Based Kubernetes Platform on Azure/gitops/monitoring/Grafana/"
```
Working Grafana dashboard:
![alt text](image.png)


### TIPS:
If you're creating new environment after `terraform destroy` we need to refresh the kubeconfig:
```bash
az aks get-credentials \
--resource-group gitops_rg2345234 \
--name example-aks1_test234 \
--overwrite-existing
```

and
```bash
az aks update \
  --resource-group gitops_rg2345234 \
  --name example-aks1_test234 \
  --attach-acr gitopscontainerregistry7677
```

### Project2_ci_build:

This pipeline is building and pushing Docker image to ACR and updating image tag Helm values (based on env: `dev` and `prod`). Only `ArgoCD` is watching any changes on the repo and commiting the changes if needed.

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

If a change is applied to the `dev` environment, the `Project2_cd_prod_deploy.yaml` workflow is triggered. In GitHub, we have configured an environment (based on the main branch) where the pipeline pauses and waits for manual approval before proceeding with the production deployment. Once the change is approved, the image tag from the `dev` environment is also updated in the prod Helm values file. ArgoCD then detects the difference between the desired and actual state, updates the Kubernetes manifests with the new tag, and Kubernetes pulls the corresponding image.
![alt text](image-1.png)