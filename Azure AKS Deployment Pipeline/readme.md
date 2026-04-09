### Main Project — DevOps Portfolio Lab (Completed)
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
- _Stage 3_ — CI/CD pipeline with GitHub Actions [completed]
- _Stage 4_ — Kubernetes manifests (Deployment, HPA) [completed]
- _Stage 5_ — Monitoring with Azure Monitor + Log Analytics [completed]

### Tip:

> Renew ACR password -> github secrets
> 
> ```yaml
> az acr credential renew --name acrapp01 --password-name password
> az acr credential show --name acrapp01 --query "passwords[0].value" --output tsv
> ```

## _Stage 1_

In this step using `terraform` we create a bunch of Azure resources like: *resource group, conteiner registry(ACR), kubernetes cluster(AKS), Azure Monitor components*.

## _Stage 2_

Having Azure environment ready we create some python app:

```python
from flask import Flask, jsonify
import random

app = Flask(__name__)

facts = [
    
    "Super fact #1",
    #"Kubernetes means 'helmsman' in Greek.",
    #"Docker was released in 2013.",
    #"Terraform is written in Go.",
    #"Azure has over 60 regions worldwide.",
    #"The first Linux kernel was released in 1991.",
]

@app.route("/")
def home():
    return jsonify({"status": "ok", "message": "DevOps Portfolio App"})

@app.route("/health")
def health():
    return jsonify({"status": "healthy"})

@app.route("/fact")
def fact():
    return jsonify({"fact": random.choice(facts)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```
With this code prepared we create simple `Dockerfile`:

```Dockerfile
# Base python image
FROM python:3.14.3

# Set working dir
WORKDIR /app

# Copy and install all dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy app code
COPY app.py .

# Expose 5000 port
EXPOSE 5000

# Run the app
CMD [ "python", "app.py" ]
```

Using our `ci_prepare_azure_env.yaml` pipeline we are building the docker image and push it to ACR:

```yaml
      - name: Log in to ACR
        run: az acr login --name acrapp01

      - name: Build and Push to ACR
        uses: docker/build-push-action@v6
        with:
          push: true
          tags: acrapp01.azurecr.io/devops-app:latest
          file: Azure AKS Deployment Pipeline/app/Dockerfile
          context: Azure AKS Deployment Pipeline/app/
```

### _Stage 3_

Whole `ci_prepare_azure_env.yaml` workflow:

![alt text](<Untitled Diagram.drawio.png>)

### _Stage 4_

Right now under the `/Kubernetes/` catalog we are creating `deployment` `service` and `horizontal-pod-autoscaller`.

### _Stage 5_

Having all Kubernetes components we are collecting logs and metrics from `AKS`.