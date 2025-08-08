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
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id

  num_cpus = 2
  memory   = 4096
  guest_id = "windows9Server64Guest"


  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
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
    datastore_id  = var.iso_path_is_datastore ? data.vsphere_datastore.datastore.id : null
    path          = var.iso_path
    client_device = !var.iso_path_is_datastore
  }

  # ISO for autounattend.xml
  cdrom {
    client_device = false
    datastore_id  = data.vsphere_datastore.datastore.id
    path          = "[${var.datastore}] ISO_OVA/autounattend.iso"
  }

  # Set boot order to CDROM, then Disk
  extra_config = {
    "bios.bootOrder" = "cdrom, disk"
  }

  provisioner "remote-exec" {
    inline = [
      # Download VMware Tools installer
      "$url = 'http://${var.local_host}:8000/vmtools/setup64.exe'",
      "$dest = 'C:\\Windows\\Temp\\vmtools_setup64.exe'",
      "Invoke-WebRequest -Uri $url -OutFile $dest",
      # Install VMware Tools silently
      "Start-Process -FilePath $dest -ArgumentList '/S /v\"/qn REBOOT=R\"' -Wait",
      # Remove the installer after installation
      "Remove-Item $dest",
      # Install Active Directory Domain Services
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