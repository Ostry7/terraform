# Azure Terraform Lab – Windows VM Deployment with Variables & Managed Disks - Attach managed disks

## 📌 Task Description
This lab extends the previous **Windows VM deployment** in Azure.  
The goal is to **Attach managed disks from previous lab**.  

### Requirements:
- Copy your **previous Windows VM project** and perform all modifications on the copy  
- Replace all hardcoded values with **variables**  
- Provide a **list of used variables**  
- Create **Managed Disks with `for_each`**:
  - **Name:** taken from variable  
  - **Location & Resource Group:** taken from data source  
  - **Storage Account Type:** `Standard_LRS` (locally redundant storage)  
  - **Create Option:** `Empty`  
  - **Disk Size:** taken from variable  
- No need to attach the disks to the VM  

---

## 📂 Project Structure
```
.
├── main.tf         # Virtual Machine definition
├── network.tf      # VNet, Subnets, NICs, Managed Disks
├── provider.tf     # Terraform provider configuration
├── data.tf         # Resource group data source
├── variables.tf    # Input variables
└── README.md       # Project documentation
```

---

## 🚀 Deployment Instructions
1. **Initialize Terraform**  
   ```bash
   terraform init
   ```

2. **Review the Plan**  
   ```bash
   terraform plan
   ```

3. **Apply the Configuration**  
   ```bash
   terraform apply
   ```

4. **Verify in Azure Portal**  
   - Go to the **Resource Group**  
   - Confirm that the **VNet, Subnets, NICs, VM, and Managed Disks** have been created  

---

## 🧹 Destroy Resources (to save costs)
After completing the task and taking a screenshot:  
```bash
terraform destroy
```

---
