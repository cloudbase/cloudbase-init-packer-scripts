packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.6"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "windows" {
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.insecure_skip_tls_verify
  username                 = var.username
  password                 = var.password
  node                     = var.node

  vm_name         = var.vm_template_name
  cores           = var.cores
  memory          = var.memory
  os              = local.os_map[var.unattended_os]["vm_os"]
  bios            = local.os_map[var.unattended_os]["vm_bios"]
  scsi_controller = "virtio-scsi-pci"
  boot            = "order=virtio0;ide2"
  qemu_agent      = true

  disks {
    disk_size    = var.os_disk_size
    storage_pool = var.storage_pool
    type         = "virtio"
  }

  efi_config {
    efi_storage_pool  = var.storage_pool
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  iso_file     = var.iso_file
  unmount_iso  = true
  boot_wait    = var.boot_wait
  boot_command = local.os_map[var.unattended_os]["efi_shell_command"]

  additional_iso_files {
    device           = "sata0"
    iso_storage_pool = var.unattended_iso_storage_pool
    unmount          = true
    cd_files = [
      "unattended/${var.unattended_os}/autounattend.xml",
      "../../scripts/install-openssh-server.ps1",
      "../../scripts/install-virtio-guest-tools.ps1"
    ]
  }

  additional_iso_files {
    device   = "sata1"
    iso_file = var.virtio_win_iso_file
    unmount  = true
  }

  network_adapters {
    bridge = var.network_bridge
    model  = "virtio"
  }

  communicator = "ssh"

  ssh_username = local.admin_user
  ssh_password = local.admin_password
  ssh_timeout  = "1h"
}

build {
  sources = [
    "source.proxmox-iso.windows"
  ]

  provisioner "file" {
    source      = "../../PSModules/CloudbaseInitSetup"
    destination = "\"C:\\Program Files\\WindowsPowerShell\\Modules\\CloudbaseInitSetup\""
  }

  provisioner "powershell" {
    elevated_user     = local.admin_user
    elevated_password = local.admin_password
    inline = [
      "$ErrorActionPreference = 'Stop'",
      "Import-Module CloudbaseInitSetup",

      "Get-WindowsBuildInfo",
      "Install-CloudbaseInit",
    ]
  }

  provisioner "file" {
    source      = "conf/"
    destination = "\"C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\conf\""
  }

  provisioner "powershell" {
    elevated_user     = local.admin_user
    elevated_password = local.admin_password
    inline = [
      "$ErrorActionPreference = 'Stop'",
      "Import-Module CloudbaseInitSetup",

      "Invoke-CloudbaseInitSetupComplete",
      "Invoke-Sysprep",
    ]
  }
}
