# Azure Terraform Lab – Managed Disk Creation

## 📌 Task Description
Deploy an **Azure Managed Disk** using Terraform in the existing resource group **RG-TerraformLab**.

### **Specifications**
- **Name:** `XXX-managed-disk` (replace `XXX` with your initials)  
- **Location:** `East US`  
- **Resource Group:** `RG-TerraformLab`  
- **Storage Account Type:** `Standard_LRS`  
- **Create Option:** `Empty`  
- **Size:** `1 GB`  

---

## 📂 Project Structure
```
.
├── main.tf         # Managed Disk resource definition
└── README.md       # Project documentation
```

---

## 🚀 Deployment Instructions
1. **Initialize Terraform**  
   ```bash
   terraform init
   ```

2. **Format Configuration Files**  
   ```bash
   terraform fmt
   ```

3. **Validate the Configuration**  
   ```bash
   terraform validate
   ```

4. **Preview the Plan**  
   ```bash
   terraform plan
   ```

5. **Apply the Configuration**  
   ```bash
   terraform apply
   ```

6. **Verify in Azure Portal**  
   - Navigate to the `RG-TerraformLab` resource group  
   - Check that the **Managed Disk** has been created  

---

## 🧹 Destroy Resources (to save costs)
```bash
terraform destroy
```

---
