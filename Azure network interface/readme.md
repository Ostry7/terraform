# Azure Terraform Lab – Managed Disk Creation

## 📌 Task Description
Create an **Azure Managed Disk** in the existing `RG-TerraformLab` resource group with the following specifications:

- **Name:** XXXX-managed-disk (replace `XXXX` with your initials)  
- **Location:** East US  
- **Resource Group:** RG-TerraformLab  
- **Storage Account Type:** Standard_LRS  
- **Create Option:** Empty  
- **Disk Size:** 1 GB  

📄 **Documentation:** [azurerm_managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk)

---

## 📂 Project Structure
```
.
├── main.tf         # Infrastructure definition (VNet, Subnet, NIC, VM, Managed Disk)
├── provider.tf     # Terraform provider configuration
├── data.tf         # Resource group data source
└── README.md       # Project documentation
```

---

## 🚀 Deployment Instructions

1. **Initialize Terraform**  
   ```bash
   terraform init
   ```

2. **Format Code**  
   ```bash
   terraform fmt
   ```

3. **Validate Configuration**  
   ```bash
   terraform validate
   ```

4. **Review the Plan**  
   ```bash
   terraform plan
   ```

5. **Apply Changes**  
   ```bash
   terraform apply
   ```

6. **Verify in Azure Portal**  
   - Go to the Azure Portal  
   - Navigate to `RG-TerraformLab`  
   - Confirm that **the managed disk** has been created with the correct parameters  

---

## 🧹 Destroy Resources (to save costs)
Once your screenshot is taken, remove all resources:  
```bash
terraform destroy
```

---
