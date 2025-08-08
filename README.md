# hushed-casket

## Terraform vSphere Domain Controller Deployment

<!-- trunk-ignore(git-diff-check/error) -->

This Terraform project deploys a Windows Server-based Domain Controller in a vSphere environment, supporting both ISO-based and network-based provisioning. It (will be) is fully automated and modularized.

### Prerequisites

- Terraform >= 1.3
- Python >= 3.13
- Access to a vSphere environment
- A bootable Windows Server ISO uploaded to a vSphere datastore
- PowerShell unattended install scripts and floppy image in place
- DNS properly configured for post-deploy resolution (optional but recommended)

### File Structure

```
dc-deploy/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── README.md
├── http/
│   ├── vmtools/
│   │   └── setup64.exe
│   └── windows-2022/
│       ├── autounattend.iso
│       └── autounattend.xml
├── modules/
│   ├── vsphere_vm/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── dns_check/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── scripts/ [...custom PowerShell for domain promotion]
└── build/ [...output logs or generated config]
```

### Usage
1. **Ensure prerequisites are installed**
2. **Clone the repo and cd into the root directory**
3. **Fill in your values in `terraform.tfvars`**
4. **Start an HTTP server. This is to allow the installation of VMware Tools (ensure you are in the http folder)**
```sh ps
python -m http.server 8000
```
May need to allow HTTP traffic on port 8000 for the VMware Tools server:
```sh ps
New-NetFirewallRule -Name "Allow HTTP 8000" -DisplayName "Allow HTTP 8000" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 8000
```
3. **Run Terraform commands**
```sh
terraform init
terraform validate
terraform apply -auto-approve
```

### Input Variables
See `variables.tf` for all supported inputs. Key ones include:
- `vsphere_user`, `vsphere_password`, `vsphere_server`
- `datacenter`, `datastore`, `cluster`, `network`
- `vm_name`, `iso_path`, `floppy_path`
- `vm_fqdn`, `vm_expected_ip`

### DNS Verification Module
This module performs an `nslookup` after provisioning to confirm the FQDN resolves to the expected IP.

### Notes
- ISO must be uploaded to the datastore.
- Floppy image should contain unattend scripts and domain join automation.
- Use the DNS module optionally for verification; it depends on a working DNS infrastructure.

---
