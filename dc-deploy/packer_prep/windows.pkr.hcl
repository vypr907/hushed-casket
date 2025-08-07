packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vsphere = {
      version = ">= 1.4.2"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

variable "vcenter_server" {
  type        = string
  description = "vCenter server address"
}

variable "vcenter_username" {
  type        = string
  description = "vCenter username"
}

variable "vcenter_password" {
  type        = string
  sensitive   = true
  description = "vCenter password"
}

variable "datacenter" {
  type        = string
  description = "vSphere datacenter name"
}

variable "host" {
  type        = string
  description = "Target ESXi host"
}

variable "datastore" {
  type        = string
  description = "vSphere datastore name"
}

variable "network" {
  type        = string
  description = "vSphere network name"
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "iso_path" {
  type        = string
  description = "Path to Windows Server 2022 ISO in datastore"
}

variable "vmtools_iso_path" {
  type        = string
  description = "Path to VMware Tools ISO in datastore"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Administrator password"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the domain controller"
}


variable "original_iso_path" {
  type        = string
  description = "Local path to the original Windows Server 2022 ISO"
}

locals {
  modified_iso_path = "[${var.datastore}] ISO_OVA/windows_server_2022_modified.iso"
}

source "null" "generate_iso" {
  communicator = "none"
}

build {
  sources = ["source.null.generate_iso"]

  provisioner "shell-local" {
    inline = [
      "$ErrorActionPreference = 'Stop'",
      "$tempDir = 'C:/Users/vypr/HUSHED CASKET/hushed-casket/dc-deploy/packer_prep/iso_temp'",
      "$isoPath = 'C:/Users/vypr/HUSHED CASKET/hushed-casket/dc-deploy/packer_prep/windows_server_2022_modified.iso'",
      "Write-Host 'Creating temporary directory: $tempDir'",
      "New-Item -ItemType Directory -Path $tempDir -Force",
      "Write-Host 'Copying ISO contents from ${var.original_iso_path}'",
      "Copy-Item -Path '${var.original_iso_path}' -Destination '$tempDir/windows_server_2022.iso' -Force",
      "Write-Host 'Mounting ISO'",
      "$iso = Mount-DiskImage -ImagePath '$tempDir/windows_server_2022.iso' -PassThru",
      "$driveLetter = ($iso | Get-Volume).DriveLetter",
      "Write-Host 'Copying ISO contents to $tempDir/iso_content'",
      "New-Item -ItemType Directory -Path '$tempDir/iso_content' -Force",
      "Copy-Item -Path \"$driveLetter`:\\*\" -Destination '$tempDir/iso_content' -Recurse -Force",
      "Dismount-DiskImage -ImagePath '$tempDir/windows_server_2022.iso'",
      "Remove-Item -Path '$tempDir/windows_server_2022.iso'",
      "Write-Host 'Generating autounattend.xml'",
      "Set-Content -Path '$tempDir/iso_content/autounattend.xml' -Value '${templatefile("http/windows-2022/autounattend_template.xml", { admin_password = var.admin_password, domain_name = var.domain_name, product_key = var.product_key })}'",
      "Write-Host 'Creating modified ISO: $isoPath'",
      "& 'C:/Program Files (x86)/Windows Kits/10/Assessment and Deployment Kit/Deployment Tools/amd64/Oscdimg/oscdimg.exe' -m -u2 -b'C:/Program Files (x86)/Windows Kits/10/Assessment and Deployment Kit/Deployment Tools/amd64/Oscdimg/efisys_noprompt.bin' '$tempDir/iso_content' '$isoPath'",
      "Write-Host 'Cleaning up temporary directory'",
      "Remove-Item -Path '$tempDir' -Recurse -Force"
    ]
    inline_shebang = "powershell -Command"
  }


  provisioner "file" {
    source      = "C:/Users/vypr/HUSHED CASKET/hushed_casket/dc-deploy/packer_prep/windows_server_2022_modified.iso"
    destination = "${local.modified_iso_path}"
    direction   = "upload"
  }
}

source "vsphere-iso" "windows-2022" {
  vcenter_server      = var.vcenter_server
  username            = var.vcenter_username
  password            = var.vcenter_password
  datacenter          = var.datacenter
  host                = var.host
  datastore           = var.datastore
  insecure_connection = true

  vm_name             = var.vm_name
  guest_os_type       = "windowsServer2264Guest"
  CPUs                = 2
  RAM                 = 4096
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size         = 61440
    thin_provisioned  = true
  }
  network_adapters {
    network           = var.network
    network_card      = "vmxnet3"
  }

  iso_paths           = [local.modified_iso_path, var.vmtools_iso_path]
  boot_order          = "disk,cdrom"
  convert_to_template = true

  communicator        = "winrm"
  winrm_username      = "Administrator"
  winrm_password      = var.admin_password
}

build {
  sources = ["source.vsphere-iso.windows-2022"]

  provisioner "powershell" {
    inline = [
      "Write-Host 'Installing VMware Tools...'",
      "E:\\setup64.exe /S /v\"/qn REBOOT=R\"",
      "Write-Host 'VMware Tools installation complete.'"
    ]
  }

  provisioner "powershell" {
    script = "${path.root}/scripts/promote-dc.ps1"
    environment_vars = [
      "domain_name=${var.domain_name}",
      "admin_password=${var.admin_password}"
    ]
  }
}