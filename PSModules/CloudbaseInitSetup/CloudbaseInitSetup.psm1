$ErrorActionPreference = "Stop"

function Install-CloudbaseInit {
    Param(
        [Parameter(Mandatory=$false)]
        [string]$Version="1.1.4",
        [Parameter(Mandatory=$false)]
        [string]$Arch="x64"
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
}

function Invoke-CloudbaseInitSetupComplete {
    Write-Output "Running cloudbase-init SetSetupComplete.cmd"
    $setupCompleteScript = Join-Path $env:windir "Setup\Scripts\SetupComplete.cmd"
    if(Test-Path $setupCompleteScript) {
        Remove-Item -Force $setupCompleteScript
    }
    & "$env:ProgramFiles\Cloudbase Solutions\Cloudbase-Init\bin\SetSetupComplete.cmd"
    if ($LASTEXITCODE) {
        Throw "Failed to run Cloudbase-Init\bin\SetSetupComplete.cmd"
    }
}
