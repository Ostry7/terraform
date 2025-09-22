# Azure Terraform Lab – Multi Virtual Machine Deployment

## 📌 Task Description
Create **multiple Azure Virtual Machines** in the existing `RG-TerraformLab` resource group using a **Terraform module**. Each VM will have:

- **Dynamic naming:** `${appcode}-${environment}-01-vm`, `${appcode}-${environment}-02-vm`, etc.  
- **Location:** same as the resource group  
- **VM Size:** configurable via variable (`Standard_B2s` by default)  
- **OS Image:** configurable (Windows Server 2022 by default, can switch to Linux)  
- **OS Disk:** Managed disk with configurable type and size  
- **Network:** Each VM attached to its own NIC, connected to specified subnet  
- **Shared SSH Key / Windows password:** Used for authentication  



## 📂 Project Structure
```
.
├── main.tf                      # Root module: calls VM module
├── variables.tf                 # Root module variables
├── data.tf                       # Root module data sources
├── provider.tf                   # Azure provider configuration
├── virtual_machine_module/       # VM module
│   ├── main.tf                  # VM resource definition
│   ├── network.tf               # VNet, Subnet, NIC, Managed Disk
│   ├── variables.tf             # Module variables
│   └── outputs.tf               # Module outputs (if any)
└── README.md                     # Project documentation
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

3. **Apply Changes**  
   ```bash
   terraform apply
   ```

4. **Verify in Azure Portal**  
   - Go to the Azure Portal  
   - Navigate to `RG-TerraformLab`  
   - Confirm that **the virtual machines** and **managed disks** have been created with correct parameters  

---


## 🧹 Destroy Resources (to save costs)
Once testing is complete, remove all resources:  
```bash
terraform destroy
```

---

## ⚠️ Notes
- Ensure your **SSH key** exists before applying for Linux VMs:  
  ```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
  ```  
- For Windows VMs, make sure the password meets Azure complexity requirements.  
- Adjust `storage_image_reference` to switch between Linux and Windows images.  
- Module creates **all VMs with the same configuration** except for names and disks.