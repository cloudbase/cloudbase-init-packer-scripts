$ErrorActionPreference = "Stop"

# Install OpenSSH Server
Get-WindowsCapability -Online -Name OpenSSH* | Add-WindowsCapability -Online
Set-Service -Name "sshd" -StartupType Automatic
Start-Service -Name "sshd"

# Set PowerShell as default shell
New-ItemProperty `
    -PropertyType String -Force -Name DefaultShell `
    -Path "HKLM:\SOFTWARE\OpenSSH" -Value (Get-Command powershell).Source

# Add SSH firewall rule
New-NetFirewallRule `
    -Name "sshd" -DisplayName 'OpenSSH Server (sshd)' `
    -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -Enabled True
