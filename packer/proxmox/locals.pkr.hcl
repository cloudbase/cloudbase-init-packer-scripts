locals {
  // only used for Packer image generation
  admin_user     = "Administrator"
  admin_password = "Passw0rd"

  // the key is the unattended subfolder name as given by "unattended_os" variable
  os_map = {
    "ws2022" = {
      "vm_os"             = "win11"
      "vm_bios"           = "ovmf"
      "efi_shell_command" = ["<enter><enter>", "\\efi\\boot\\bootx64.efi<enter><wait>", "<enter>"]
    }
  }
}
