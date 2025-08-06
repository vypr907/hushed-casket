terraform {
    required_providers {
      vsphere = {
        source  = "hashicorp/vsphere"
        version = ">= 2.8.1"
      }
    }
    required_version = ">= 1.3.0"
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

module "vsphere_vm_dc" {
  source = "./modules/vsphere_vm_dc"

  datacenter             = var.datacenter
  datastore              = var.datastore
  cluster                = var.cluster
  network                = var.network
  vm_name                = var.vm_name
  iso_path               = var.iso_path
  iso_path_is_datastore  = var.iso_path_is_datastore
  floppy_path            = var.floppy_path
  vm_fqdn                = var.vm_fqdn
  vm_expected_ip         = var.vm_expected_ip
}

module "dns_check" {
  source = "./modules/dns_check"

  vm_fqdn        = var.vm_fqdn
  vm_expected_ip = var.vm_expected_ip
  depends_on = [ module.vsphere_vm_dc ]
}

output "dc_vm_ip" {
  value = module.vsphere_vm_dc.vm_ip
}