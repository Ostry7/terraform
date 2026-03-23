# Azure Terraform Lab – Windows VM Deployment with Variables & Data Disks

## 📌 Task Description
This lab extends the **Windows VM deployment** in Azure.  
The goal is to **parameterize the configuration with variables**, **deploy multiple VMs**, and **attach managed data disks**.  

### Requirements:
- Deploy **multiple Windows VMs** using `count`  
- Replace all hardcoded values with **variables**  
- Provide a **list of used variables**  
- Create **Managed Disks with `for_each`**:
  - **Name:** taken from variable  
  - **Location & Resource Group:** taken from data source  
  - **Storage Account Type:** configurable via variable  
  - **Create Option:** configurable via variable  
  - **Disk Size:** configurable via variable  
- Attach created **Managed Disks** to Virtual Machines  

---

## 📂 Project Structure
```
.
├── main.tf         # Virtual Machine definition (count, OS disk, variables)
├── network.tf      # VNet, Subnets, NICs, Managed Disks, Disk Attachments
├── provider.tf     # Terraform provider configuration
├── data.tf         # Resource group data source
├── variables.tf    # Input variables (VM size, image, OS disk, user config, subnets, managed disks)
├── locals.tf       # Local values (naming convention)
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
   - Confirm that the **VNet, Subnets, NICs, VMs, OS Disks, and Data Disks** have been created and attached  

---

## 🧹 Destroy Resources (to save costs)
After completing the task and verifying deployment:  
```bash
terraform destroy
```

---
