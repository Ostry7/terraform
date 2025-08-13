# Azure Terraform Lab – Windows VM Deployment

## 📌 Task Description
Create a **Windows Virtual Machine** in Azure using the following specifications:

- **VNet Name:** XXX-App-VNET (replace `XXX` with your initials)  
- **Subnets:** `dev_subnet` and `tst_subnet`  
- **VM Name:** XXX-app01vm  
- **Size:** `Standard_B2s`  
- **Operating System:** Windows Server 2022  
- Take a screenshot showing **all created resources** in Azure Portal.  
- **Important:** Destroy all created resources afterward to save costs.  

---

## 📂 Project Structure
```
.
├── main.tf         # Main infrastructure definition
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
   - Navigate to your resource group  
   - Confirm that **VNet, Subnets, NICs, and VM** have been created  

---

## 🧹 Destroy Resources (to save costs)
Once your screenshot is taken, remove all resources:  
```bash
terraform destroy
```

---
