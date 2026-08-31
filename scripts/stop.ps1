[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'common.ps1')
$docker = Get-AgentLabDockerPath
Push-Location $repoRoot
try {
    & $docker compose down
} finally {
    Pop-Location
}

Write-Host 'Stack detenido. Los datos persistentes se conservan.'
