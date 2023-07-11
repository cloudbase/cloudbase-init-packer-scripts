$ErrorActionPreference = "Stop"

while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }
while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }

$systemUnattendFile = Join-Path $env:SystemRoot "system32\Sysprep\unattend.xml"
if (Test-Path $systemUnattendFile) {
    Remove-Item -Force -Path $systemUnattendFile
}

# Use the unattend.xml provided by cloudbase-init
$unattendedXml = Join-Path $env:ProgramFiles "Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
& $env:SystemRoot\System32\Sysprep\Sysprep.exe /oobe /generalize /mode:vm /quit /quiet /unattend:$unattendedXml
if ($LASTEXITCODE) {
    Throw "Failed to run Sysprep.exe"
}

while ($true) {
    $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select-Object ImageState
    Write-Output $imageState.ImageState
    if ($imageState.ImageState -eq 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') {
        break
    }
    Start-Sleep -s 10
}

Write-Output "Sysprep completed"
