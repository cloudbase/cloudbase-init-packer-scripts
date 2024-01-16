$ErrorActionPreference = "Stop"

function Install-CloudbaseInit {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$Version = "1.1.4",
        [Parameter(Mandatory = $false)]
        [string]$Arch = "x64"
    )
    Write-Output "Downloading cloudbase-init"

    $cbslInitInstallerPath = Join-Path $env:TEMP "CloudbaseInitSetup_x64.msi"
    Start-FileDownload `
        -URL "https://github.com/cloudbase/cloudbase-init/releases/download/${Version}/CloudbaseInitSetup_$($Version -replace '\.', '_')_${Arch}.msi" `
        -Destination $cbslInitInstallerPath

    Write-Output "Installing cloudbase-init"
    $p = Start-Process -Wait -PassThru -FilePath "msiexec.exe" -ArgumentList @("/i", $cbslInitInstallerPath, "/qn")
    if ($p.ExitCode -ne 0) {
        Throw "Failed to install cloudbase-init"
    }

    Write-Output "Cloudbase-init installed"
}

function Invoke-CloudbaseInitSetupComplete {
    Write-Output "Running cloudbase-init SetSetupComplete.cmd"
    $setupCompleteScript = Join-Path $env:windir "Setup\Scripts\SetupComplete.cmd"
    if (Test-Path $setupCompleteScript) {
        Remove-Item -Force $setupCompleteScript
    }
    & "$env:ProgramFiles\Cloudbase Solutions\Cloudbase-Init\bin\SetSetupComplete.cmd"
    if ($LASTEXITCODE) {
        Throw "Failed to run Cloudbase-Init\bin\SetSetupComplete.cmd"
    }
}

function Invoke-Sysprep {
    $systemUnattendFile = Join-Path $env:SystemRoot "system32\Sysprep\unattend.xml"
    if (Test-Path $systemUnattendFile) {
        Remove-Item -Force -Path $systemUnattendFile
    }

    Write-Output "Running Sysprep"

    # Use the unattend.xml provided by cloudbase-init
    $unattendedXml = Join-Path $env:ProgramFiles "Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
    & $env:SystemRoot\System32\Sysprep\Sysprep.exe /oobe /generalize /mode:vm /quit /quiet /unattend:$unattendedXml
    if ($LASTEXITCODE) {
        Throw "Failed to run Sysprep.exe"
    }

    while ($true) {
        $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select-Object ImageState
        Write-Output "ImageState: $($imageState.ImageState)"
        if ($imageState.ImageState -eq 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') {
            break
        }
        Start-Sleep -Seconds 5
    }

    Write-Output "Sysprep completed"
}
