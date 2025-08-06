terraform {
  required_version = ">= 1.3.0"
    required_providers {
        vsphere = {
        source  = "hashicorp/vsphere"
        version = ">= 2.2.0"
        }
    }
}
resource "vsphere_virtual_machine" "dc_vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore_id

  num_cpus = 2
  memory   = 4096
  guest_id = "windows2019srv_64Guest"


  network_interface {
    network_id   = data.vsphere_network.network_id
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

  floppy {
    datastore_id = data.vsphere_datastore.datastore_id
    path         = var.floppy_path
  }

  extra_config = {
    "floppy0.present" = "TRUE"
  }

wait_for_guest_net_timeout = 10
  wait_for_guest_ip_timeout   = 10

  lifecycle {
    ignore_changes = [
      network_interface,
      disk,
      cdrom,
      floppy,
    ]
  }

  depends_on = [
    data.vsphere_compute_cluster,
    data.vsphere_datastore,
    data.vsphere_network,
  ]
  
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}