# Proxmox Windows VM Templates with Cloudbase-init

This directory contains the scripts and configuration files necessary for generating Proxmox VM templates with cloudbase-init.

## Supported Windows Versions

Currently, the following Windows versions are supported:

* Windows Server 2022

### How to Generate Proxmox VM Template

Before proceeding:

* Download the official Windows ISO file from the Microsoft website and upload it to a Proxmox storage pool.
* Download the [latest stable Windows VirtIO drivers ISO](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso) and upload it to a Proxmox storage pool.

In the following steps, we will refer to these ISO files as:

* `san-repo:iso/windows_server_2022_EVAL_x64.iso` for the Windows Server 2022 ISO file.
* `san-repo:iso/virtio-win.iso` for the Windows VirtIO drivers ISO file.

The next step involves setting up environment variables with Packer variables:

```bash
#
# Proxmox API connection details
#
export PKR_VAR_proxmox_url="https://PROXMOX_ADDRESS:8006/api2/json"
export PKR_VAR_insecure_skip_tls_verify="true"
export PKR_VAR_username="root@pam"
export PKR_VAR_password="SuperStrongPassw0rd!"

#
# Proxmox builder VM details
#
export PKR_VAR_node="proxmox03"
export PKR_VAR_vm_template_name="ws2022-cbsl-init"
export PKR_VAR_unattended_os="ws2022"
export PKR_VAR_iso_file="san-repo:iso/windows_server_2022_EVAL_x64.iso"
export PKR_VAR_virtio_win_iso_file="san-repo:iso/virtio-win.iso"

# Increase this value if the Packer builder VM takes longer to reach the EFI shell.
export PKR_VAR_boot_wait="35s"
```

Now, you may proceed to execute the Packer build to generate the VM template:

```bash
packer build .
```
