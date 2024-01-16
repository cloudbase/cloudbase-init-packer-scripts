//
// Proxmox connection variables
//
variable "proxmox_url" {
  description = "Proxmox URL"
  type        = string
  default     = "https://proxmox.example.com:8006/api2/json"
}

variable "insecure_skip_tls_verify" {
  description = "Proxmox insecure skip tls verify"
  type        = bool
  default     = false
}

variable "username" {
  description = "Proxmox user name"
  type        = string
  default     = "root@pam"
}

variable "password" {
  description = "Proxmox user password"
  type        = string
}

//
// Packer builder VM variables
//
variable "node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

variable "vm_template_name" {
  description = "Proxmox VM template name"
  type        = string
  default     = "packer-windows-template"
}

variable "cores" {
  description = "Proxmox VM cores"
  type        = number
  default     = 4
}

variable "memory" {
  description = "Proxmox VM memory"
  type        = number
  default     = 8192
}

variable "network_bridge" {
  description = "Proxmox VM network bridge name"
  type        = string
  default     = "vmbr0"
}

variable "os_disk_size" {
  description = "Proxmox VM OS disk size"
  type        = string
  default     = "32G"
}

variable "storage_pool" {
  description = "Proxmox VM disks storage pool"
  type        = string
  default     = "local-lvm"
}

variable "iso_file" {
  description = "Proxmox VM ISO file"
  type        = string
  default     = "san-repo:iso/windows_server_2022_EVAL_x64.iso"
}

variable "virtio_win_iso_file" {
  description = "Proxmox VM virtio-win ISO file"
  type        = string
  default     = "san-repo:iso/virtio-win.iso"
}

variable "unattended_os" {
  description = "Unattended OS directory name (must be present in the unattended subdirectory) with the autounattend.xml file"
  type        = string
  default     = "ws2022"
}

variable "unattended_iso_storage_pool" {
  description = "Storage pool used by the unattended ISO generated by Packer"
  type        = string
  default     = "local"
}

variable "boot_wait" {
  description = "Proxmox VM boot wait time before executing the EFI shell command to start the unattended OS installation"
  type        = string
  default     = "30s"
}