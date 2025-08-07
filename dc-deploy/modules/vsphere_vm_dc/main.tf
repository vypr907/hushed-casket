terraform {
  required_version = ">= 1.3.0"
    required_providers {
        vsphere = {
        source  = "vmware/vsphere"
        version = ">= 2.8.1"
        }
    }
}
resource "vsphere_virtual_machine" "dc_vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = var.datastore
  host_system_id   = data.vsphere_host.host.id

  num_cpus = 2
  memory   = 4096
  guest_id = "windows2019srv_64Guest"


  network_interface {
    network_id   = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = 60
    eagerly_scrub    = false
    thin_provisioned = true
  }

  # ISO for Windows Server 2022 installation
  # If iso_path_is_datastore is true, the ISO is expected to be in the datastore
  # If false, it will be mounted from the local machine
  cdrom {
    datastore_id = var.iso_path_is_datastore ? data.vsphere_datastore.datastore.id : null
    path         = var.iso_path 
    client_device = !var.iso_path_is_datastore
  }

  # ISO for VMware Tools installation
  # This assumes the ISO is in the datastore
  cdrom {
    client_device = false
    datastore_id = data.vsphere_datastore.datastore.id
    path = "[datastore1] ISO_OVA/VMware-tools-windows-12.5.0-24276846.iso"
  }
  
  cdrom {
    client_device = false
    datastore_id  = var.datastore
    path          = vsphere_file.autounattend_floppy.destination_file
  }

  extra_config = {
    "bios.bootOrder" = "cdrom,network,hd"
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
    data.vsphere_host.host,
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

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "template_file" "autounattend" {
    template = file("${path.module}/scripts/autounattend_template.xml")
    vars = {
      vm_name            = var.vm_name
      domain_name        = var.domain_name
      vm_admin_user      = var.vm_admin_user
      vm_admin_password  = var.vm_admin_password
    }
  }

  resource "local_file" "autounattend_xml" {
    content  = data.template_file.autounattend.rendered
    filename = "${path.module}/scripts/autounattend.xml"
  }

  resource "null_resource" "create_floppy" {
    provisioner "local-exec" {
      command = <<EOT
      mkdosfs -C ${path.module}/autounattend.flp 1440
      mcopy -i ${path.module}/autounattend.flp ${path.module}/autounattend.xml ::
      EOT
    }
    depends_on = [local_file.autounattend_xml]
  }

  resource "vsphere_file" "autounattend_floppy" {
    datacenter = var.datacenter
    datastore  = var.datastore
    source_file     = "${path.module}/autounattend.flp"
    destination_file = "autounattend.flp"
    depends_on = [null_resource.create_floppy]
  }