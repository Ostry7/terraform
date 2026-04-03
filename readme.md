### Training Exercises (`_training/`)
A collection of hands-on exercises completed during a Terraform training course. 

### Repository Structure
```
├── _training/                      # Exercises completed during Terraform training
│   ├── Add parameter/              
│   ├── Azure managed disk/         
│   ├── Azure network interface/    
│   ├── Azure virtual machine Win/  
│   ├── Final/                      
│   ├── ForEachLoop/                
│   └── ForEachLoop2/               
│
├── README.md
│
└── Azure AKS Deployment Pipeline   #Main project -> full CI/CD, IaC
```

### Main Project — DevOps Portfolio Lab (In Progress)
A production-style project deploying a containerized application to Azure Kubernetes Service with full CI/CD, IaC, and monitoring.

*Planned Architecture*
```
GitHub Repository
        │
        ▼
GitHub Actions (CI/CD)
        │
        ├──► Azure Container Registry (ACR)
        │
        └──► AKS (Azure Kubernetes Service)
                    │
                    ├── Deployment + HPA
                    ├── Ingress (nginx)
                    └── Azure Monitor / Log Analytics
```

Roadmap

- _Stage 1_ — Infrastructure foundation with Terraform (Resource Group, ACR, AKS, VNet) [completed]
- _Stage 2_ — Application + Dockerfile + push to ACR [completed]
- _Stage 3_ — CI/CD pipeline with GitHub Actions
- _Stage 4_ — Kubernetes manifests (Deployment, HPA, Ingress, Secrets)
- _Stage 5_ — Monitoring with Azure Monitor + Log Analytics