$ErrorActionPreference = "Stop"

Import-Module CloudbaseInitSetup

Confirm-EnvVarsAreSet -EnvVars @("CLOUDBASE_INIT_VERSION")

Get-NetAdapter -Physical | Rename-NetAdapter -NewName "packer"

Get-WindowsBuildInfo
Install-OpenSSHServer
Install-CloudbaseInit -Version $env:CLOUDBASE_INIT_VERSION
