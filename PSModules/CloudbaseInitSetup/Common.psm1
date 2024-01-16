$ErrorActionPreference = "Stop"

function Start-ExecuteWithRetry {
    Param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock,
        [int]$MaxRetryCount = 10,
        [int]$RetryInterval = 3,
        [string]$RetryMessage,
        [array]$ArgumentList = @()
    )
    $currentErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $retryCount = 0
    while ($true) {
        try {
            $res = Invoke-Command -ScriptBlock $ScriptBlock `
                -ArgumentList $ArgumentList
            $ErrorActionPreference = $currentErrorActionPreference
            return $res
        }
        catch [System.Exception] {
            $retryCount++
            if ($retryCount -gt $MaxRetryCount) {
                $ErrorActionPreference = $currentErrorActionPreference
                throw
            }
            else {
                if ($RetryMessage) {
                    Write-Output "Retry (${retryCount}/${MaxRetryCount}): $RetryMessage"
                }
                elseif ($_) {
                    Write-Output "Retry (${retryCount}/${MaxRetryCount}): $_"
                }
                Start-Sleep $RetryInterval
            }
        }
    }
}

function Start-FileDownload {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$URL,
        [Parameter(Mandatory = $true)]
        [string]$Destination,
        [Parameter(Mandatory = $false)]
        [int]$RetryCount = 10
    )
    Write-Output "Downloading $URL to $Destination"
    Start-ExecuteWithRetry `
        -ScriptBlock { Invoke-Expression "curl.exe --fail -L -s -o $Destination $URL" } `
        -MaxRetryCount $RetryCount `
        -RetryInterval 3 `
        -RetryMessage "Failed to download $URL. Retrying"
}

function Add-ToSystemPath {
    Param(
        [Parameter(Mandatory = $false)]
        [string[]]$Path
    )

    if (!$Path) {
        return
    }

    $systemPath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine).Split(';')
    $currentPath = $env:PATH.Split(';')
    foreach ($p in $Path) {
        if ($p -notin $systemPath) {
            $systemPath += $p
        }
        if ($p -notin $currentPath) {
            $currentPath += $p
        }
    }

    $env:PATH = $currentPath -join ';'
    $newSystemPath = $systemPath -join ';'
    [Environment]::SetEnvironmentVariable("PATH", $newSystemPath, [System.EnvironmentVariableTarget]::Machine)
}

function Confirm-EnvVarsAreSet {
    Param(
        [String[]]$EnvVars
    )
    foreach ($var in $EnvVars) {
        if (!(Test-Path "env:${var}")) {
            Throw "Missing required environment variable: $var"
        }
    }
}

function Install-OpenSSHServer {
    # Install OpenSSH
    Start-ExecuteWithRetry { Get-WindowsCapability -Online -Name OpenSSH* | Add-WindowsCapability -Online }
    Set-Service -Name sshd -StartupType Automatic
    Start-Service sshd

    # Set PowerShell as default shell
    New-ItemProperty `
        -PropertyType String -Force -Name DefaultShell `
        -Path "HKLM:\SOFTWARE\OpenSSH" -Value (Get-Command powershell).Source

    # Remove unified authorized_keys file for admin users
    $configFile = Join-Path $env:ProgramData "ssh\sshd_config"
    $config = Get-Content $configFile | `
        ForEach-Object { $_ -replace '(.*Match Group administrators.*)', '# $1' } | `
        ForEach-Object { $_ -replace '(.*AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys.*)', '# $1' }
    Set-Content -Path $configFile -Value $config -Encoding Ascii
}

function Get-WindowsBuildInfo {
    $p = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $table = New-Object System.Data.DataTable
    $table.Columns.AddRange(@("Release", "Version", "Build"))
    $table.Rows.Add($p.ProductName, $p.ReleaseId, "$($p.CurrentBuild).$($p.UBR)") | Out-Null
    return $table
}
