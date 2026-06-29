## Project — GitOps-Based Kubernetes Platform on Azure

Production-style multi-region disaster recovery platform — containerized application deployed on AKS via GitOps, with failover, WAL-based PostgreSQL replication, and full observability.

Architecture
```
GitHub Repository
        │
        ├──► GitHub Actions (CI — build & push image to ACR)
        │
        ▼
Argo CD (GitOps (ArgoCD) — watches repo, syncs cluster state)
        │
        ▼
AKS Primary (West Europe)                    AKS DR (Poland Central)
        │                                            │
        ├── Helm (dev / prod namespaces)             ├── CNPG DR Cluster (replica)
        ├── CNPG Primary Cluster                     └── WAL recovery from Azure Blob
        ├── WAL archive → Azure Blob (GRS)
        ├── Internal LoadBalancer (5432)
        ├── Prometheus
        └── Grafana
```

### Tech Stack:

|       Layer       |                          Tools                         |
|:-----------------:|:------------------------------------------------------:|
| Infrastructure    | Terraform, Azure (AKS, ACR, VNet, Storage Account GRS) |
| Container runtime |            Docker, Azure Container Registry            |
| Orchestration     |                 Kubernetes (AKS), Helm                 |
| GitOps            |                         Argo CD                        |
| Database          |            CloudNativePG (CNPG), PostgreSQL            |
| CI/CD             |                     GitHub Actions                     |
| Observability     |                   Prometheus, Grafana                  |
| Application       |                     Python / Flask                     |


VNet Peering connects both clusters — the DR replica streams WAL from the primary over a private internal IP.

### Prerequisites:

First things first we need to generate the `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_CREDENTIALS` secrets and put it into Github Secrets and variables.

```
az ad sp create-for-rbac \
  --name "github-actions-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/TWOJ_SUBSCRIPTION_ID" \
  --sdk-auth
```

## Pipelines

### `Project2_ci_infrastructure` Bootstrap the infrastructure:

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


### `Project2_ci_build` Build & Deploy

Triggered on every push. Builds the Docker image, pushes to ACR, and updates the Helm values image tag for dev. Argo CD detects the diff and syncs the cluster.

```
build image → push to ACR → update dev image tag → commit
                                    │
                             ArgoCD detects diff
                                    │
                             sync dev namespace
                                    │
                    trigger Project2_cd_prod_deploy
                                    │
                          manual approval gate
                                    │
                          update prod image tag
                                    │
                             ArgoCD syncs prod
```
Prod deploy requires manual approval — configured as a GitHub Environment protection rule on the main branch.
![alt text](image-2.png)

### `Project2_DR_failover` - Perform Failover

Triggered manually via `workflow_dispatch`. Requires typing `FAILOVER` in the confirmation input — guards against accidental execution.

```
[manual trigger: "FAILOVER"]
        │
        ▼
promote cnpg-cluster-dr → replica.enabled: false
        │
        ▼
wait: cluster phase = "Cluster in healthy state"
        │
        ▼
verify: pg_is_in_recovery() = false   ← DR is now writable primary
        │
        ▼
patch db-config ConfigMap (prod + dev)
  db_mode: "PRIMARY" → "DR"
        │
        ▼
rollout restart devops-app (prod + dev)
  ← pods pick up new DB_MODE, UI header shows "DR"
```

Failover operates only on the DR cluster — the primary AKS is intentionally left untouched (assumed unavailable or degraded).

### `Project2_DR_failback` Failback to primary

Triggered manually via `workflow_dispatch`. Requires typing `FAILBACK`. Full restoration sequence — brings the primary back and resets the DR cluster to replica mode.

```
[manual trigger: "FAILBACK"]
        │
        ▼
on-demand backup of cnpg-cluster-dr (DR → Azure Blob)
  wait: backup phase = completed
        │
        ▼
delete cnpg-cluster-primary + PVC (prod namespace, primary AKS)
        │
        ▼
clean WAL archive: delete blobs matching cnpg-cluster-primary/*
  (prevents timeline conflict on restore)
        │
        ▼
apply cnpg-failback.yaml (recovery from DR backup)
  WAL_PATH injected via sed from terraform output
        │
        ▼
patch cnpg-cluster-primary: remove /spec/replica
  → promote to standalone primary
  wait: cluster phase = "Cluster in healthy state"
        │
        ▼
patch cnpg-cluster-dr: replica.enabled: true
  → DR goes back to streaming replica mode
        │
        ▼
patch db-config ConfigMap (prod + dev)
  db_mode: "DR" → "PRIMARY"
        │
        ▼
rollout restart devops-app (prod + dev)
        │
        ▼
verify: pg_is_in_recovery() = false on primary
```

The failback manifest (`database/prod/failback/cnpg-failback.yaml`) lives outside the standard ArgoCD sync path — it's applied directly by the pipeline to avoid Argo CD reconciling it away mid-restore.


## Database - PostgreSQL with CloudNativePG (CNPG)

### Primary:

- Single-instance CNPG cluster: `cnpg-cluster-primary`
- `WAL` archiving to Azure Blob Storage with gzip complression
- Exposed internally via `cnpg-primary-internal-lb` (Service: `LoadBalancer` port `5432`)
- Schema bootstrapped via `postInitApplicationSQL`:
  - users table,
  - products table.

### DR Replica:

- `cnpg-cluster-dr` bootstrapped from `recovery` source pointing at primary
- streaming replication over VNet peering 
- `WAL` recovery from the same Azure Blob container as primary
- on demand backup manifest available under `database/dr/ondemand-backups/`

### CloudNativePG and WAL - How it works?

`WAL` stands for `Write` `Ahead` `Log`. It's core PostgreSQL durability mechanism: before any change reaches the data files, it is first written to the log. If the database crashes mid-operation, PostgreSQL replays the `WAL` on restart - committed transactions are never lost. `WAL` is a physical stream of changes. Every `INSERT`, `UPDATE`, `DELETE` produces `WAL` records. 

### Streaming Replication (Continous replication)

The DR replica connects to primary and says: "give me WAL from position X". Primary responds with a continuous stream of changes — this is streaming replication.

```
Primary PostgreSQL
        │
        │  WAL stream (TCP port 5432, TLS)
        ▼
DR Replica PostgreSQL
  (applies WAL records continuously, stays in recovery mode)
```

The replica is always in `pg_is_in_recovery() = true` — it's read-only and continuously applying changes from primary. This is how replication lag stays in the milliseconds range under normal conditions.

In this project, the stream travels over VNet Peering between West Europe and Poland Central. The primary is exposed via an internal Azure Load Balancer (`cnpg-primary-internal-lb`) on port `5432` with a static private IP — the DR cluster references that IP directly in externalClusters.

### WAL Archiving to Azure Blob

Streaming replication alone has a problem: if the primary dies before the replica received the latest WAL segments, those changes are gone. WAL archiving solves this.

```
Primary PostgreSQL
        │
        │  completed WAL segment (every 16MB or on timeout)
        ▼
Azure Blob Storage (wal-archive container, GRS)
        │
        │  WAL restore / catch-up
        ▼
DR Replica PostgreSQL
```

CNPG uses `Barman (Backup and Recovery Manager)` under the hood to handle this. `Barman` is a open-source tool to manage backups and WAL archiving for PostgreSQL. In `CNPG` context `Barman` isn't a separate process. `CNPG` includes a built-in `barman-cloud` library, which is a set of CLI tools from the Barman ecosystem adapted for cloud storage: 

```
barman-cloud-wal-archive   # sends a WAL segment to S3/Azure Blob/GCS
barman-cloud-wal-restore   # retrieves the WAL segment from storage
barman-cloud-backup        # performs a base backup
barman-cloud-restore       # restores the backup
```

CNPG invokes these commands inside the PostgreSQL container as hooks—for example, after each WAL segment is closed, PostgreSQL triggers `archive_command`, and CNPG replaces that command with `barman-cloud-wal-archive`, passing the appropriate parameters to Azure Blob.


Every completed WAL segment gets shipped to Azure Blob with gzip compression. The DR cluster can recover from Blob even if it was offline for a period and missed streaming WAL — it fetches the archived segments and replays them to catch up.

GRS (Geo-Redundant Storage) means Azure replicates the archive to a paired region automatically, so the archive itself survives a regional outage.

In the CNPG manifest this looks like:

```yaml
backup:
  barmanObjectStore:
    destinationPath: "https://<storage_account>.blob.core.windows.net/wal-archive"
    azureCredentials:
      inheritFromAzureAD: true   # uses AKS workload identity, no secrets
    wal:
      compression: gzip
```

### Why WAL Archive must be cleared before failback?

PostgreSQL uses timelines to track the history of a cluster. When a standby is promoted to primary, it starts a new timeline (e.g. timeline 2). All WAL it generates goes into the archive under timeline 2.

If you then try to restore the original primary from the archive without clearing it first, PostgreSQL sees WAL from both timeline 1 (old primary) and timeline 2 (DR after promotion) in the same directory. It gets confused about which history to follow and refuses to start, or worse — silently applies wrong data.

The failback pipeline solves this by deleting all blobs matching cnpg-cluster-primary/* before writing the new restore manifest:

```bash
az storage blob delete-batch \
  --account-name $STORAGE_ACCOUNT \
  --source wal-archive \
  --pattern "cnpg-cluster-primary/*" \
  --account-key $STORAGE_KEY
```
After the cleanup the restored primary starts fresh on timeline 3 (or whatever is next), with no ambiguity.

### Failover vs Failback - state changes:

|                |          Primary cluster          |            DR cluster            | db_mode ConfigMap |
|:--------------:|:---------------------------------:|:--------------------------------:|:-----------------:|
| Normal         |  replica.enabled absent, writable | replica.enabled: true, read-only |      PRIMARY      |
| After failover |      untouched (assumed down)     | replica.enabled: false, writable |         DR        |
| After failback | restored from DR backup, writable | replica.enabled: true, read-only |      PRIMARY      |

The `db_mode` ConfigMap value is surfaced in the Flask app UI header (PRIMARY DB / DR) so the current active site is always visible at a glance.


## Operations:

### 1. Refresh kubeconfig after `terraform destroy`
```bash
# Primary (prod)
az aks get-credentials \
  --resource-group gitops_rg2345234 \
  --name example-aks1_test234 \
  --overwrite-existing

# Attach ACR
az aks update \
  --resource-group gitops_rg2345234 \
  --name example-aks1_test234 \
  --attach-acr gitopscontainerregistry7677

# DR site
az aks get-credentials \
  --resource-group gitops_rg2345234_dr \
  --name aks-dr-234623465 \
  --context aks-dr \
  --overwrite-existing
```
### 2. Switch between contexts

```bash
kubectl config get-contexts
kubectl config use-context example-aks1_test234   # primary
kubectl config use-context aks-dr                  # DR
```

### 3. Expose ArgoCD UI:

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### 4. Check active image per namespace:

```bash
echo "DEV:" && kubectl describe pod -n dev | grep "Image:"
echo "PROD:" && kubectl describe pod -n prod | grep "Image:"
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