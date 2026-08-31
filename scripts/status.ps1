[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'common.ps1')
$docker = Get-AgentLabDockerPath
Push-Location $repoRoot
try {
    & $docker compose ps
    $version = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/version' -TimeoutSec 10
    $models = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/v1/models' -TimeoutSec 10
    $canvas = Invoke-WebRequest -Uri 'http://127.0.0.1:8000/canvas' -TimeoutSec 15 -UseBasicParsing
    Write-Host "Ollama: $($version.version)"
    Write-Host "Modelos: $($models.data.id -join ', ')"
    Write-Host "Agent Canvas HTTP: $($canvas.StatusCode)"
} finally {
    Pop-Location
}
