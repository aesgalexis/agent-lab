[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'common.ps1')
& (Join-Path $PSScriptRoot 'bootstrap.ps1')

$docker = Get-AgentLabDockerPath
& $docker info *> $null
if ($LASTEXITCODE -ne 0) {
    throw 'Docker Desktop no está iniciado o su engine aún no está listo.'
}

$runningServices = @(& $docker compose --project-directory $repoRoot ps --status running --services 2>$null)
$listener = Get-NetTCPConnection -LocalPort 11434 -State Listen -ErrorAction SilentlyContinue
if ($listener -and $runningServices -notcontains 'ollama') {
    throw 'El puerto 11434 está ocupado. Ejecuta scripts/stop-native-ollama.ps1 y vuelve a intentar.'
}

Push-Location $repoRoot
try {
    & $docker compose up -d ollama
    $modelLine = Get-Content -LiteralPath '.env' | Where-Object { $_ -match '^OLLAMA_MODEL=' } | Select-Object -First 1
    $model = ($modelLine -split '=', 2)[1]
    if (-not $model) { throw 'OLLAMA_MODEL no está definido en .env.' }
    & $docker compose exec -T ollama ollama pull $model
    & $docker compose up -d agent-canvas
    & $docker compose ps
} finally {
    Pop-Location
}

& (Join-Path $PSScriptRoot 'configure-openhands.ps1')
Write-Host 'Agent Canvas: http://127.0.0.1:8000/canvas'
