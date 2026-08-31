[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot '.env'
$envExample = Join-Path $repoRoot '.env.example'
$runtimeRoot = Join-Path $repoRoot '.runtime'

New-Item -ItemType Directory -Force -Path (Join-Path $runtimeRoot 'openhands'), (Join-Path $runtimeRoot 'logs') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $env:USERPROFILE '.ollama') | Out-Null

if (-not (Test-Path -LiteralPath $envFile)) {
    $randomBytes = New-Object byte[] 32
    [Security.Cryptography.RandomNumberGenerator]::Fill($randomBytes)
    $backendKey = [Convert]::ToHexString($randomBytes).ToLowerInvariant()
    [Security.Cryptography.RandomNumberGenerator]::Fill($randomBytes)
    $secretKey = [Convert]::ToHexString($randomBytes).ToLowerInvariant()
    $ollamaPath = (Join-Path $env:USERPROFILE '.ollama') -replace '\\', '/'

    $content = Get-Content -LiteralPath $envExample -Raw
    $content = $content.Replace('C:/Users/CHANGE_ME/.ollama', $ollamaPath)
    $content = $content.Replace('LOCAL_BACKEND_API_KEY=CHANGE_ME', "LOCAL_BACKEND_API_KEY=$backendKey")
    $content = $content.Replace('OH_SECRET_KEY=CHANGE_ME', "OH_SECRET_KEY=$secretKey")
    Set-Content -LiteralPath $envFile -Value $content -Encoding utf8NoBOM
    Write-Host "Creado .env con secretos locales aleatorios."
} else {
    Write-Host ".env ya existe; no se ha sobrescrito."
}

Write-Host "Directorios persistentes preparados en $runtimeRoot"
