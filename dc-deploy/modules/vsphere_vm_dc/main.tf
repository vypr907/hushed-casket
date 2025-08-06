terraform {
  required_version = ">= 1.3.0"
    required_providers {
        vsphere = {
        source  = "hashicorp/vsphere"
        version = ">= 2.8.1"
        }
    }
}
resource "vsphere_virtual_machine" "dc_vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore

  num_cpus = 2
  memory   = 4096
  guest_id = "windows2019srv_64Guest"


  network_interface {
    network_id   = data.vsphere_network.network
  }

  disk {
    label            = "disk0"
    size             = 60
    eagerly_scrub    = false
    thin_provisioned = true
  }

  cdrom {
    datastore_id = var.iso_path_is_datastore ? data.vsphere_datastore.datastore_id : null
    path         = var.iso_path 
    client_device = !var.iso_path_is_datastore
  }

  provisioner "remote-exec" {
    inline = [
      "Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools",
      "Install-ADDSForest -DomainName '${var.domain_name}' -InstallDns -Force -NoRebootOnCompletion",
      "Write-Output 'Domain Controller setup completed.'"
    ]
    connection {
      type        = "winrm"
      host        = self.default_ip_address
      user        = var.vm_admin_user
      password    = var.vm_admin_password
      timeout     = "10m"
      https       = true
      insecure    = true
    }
  }

wait_for_guest_net_timeout = 10
  wait_for_guest_ip_timeout   = 10

  lifecycle {
    ignore_changes = [
      network_interface,
      disk,
      cdrom,
    ]
  }

  depends_on = [
    data.vsphere_compute_cluster.cluster,
    data.vsphere_datastore.datastore,
    data.vsphere_network.network,
  ]
  
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}