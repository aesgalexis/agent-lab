[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot
try {
    docker compose down
} finally {
    Pop-Location
}

Write-Host 'Stack detenido. Los datos persistentes se conservan.'
