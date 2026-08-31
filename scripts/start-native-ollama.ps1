[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$runtimeLogs = Join-Path $repoRoot '.runtime\logs'
New-Item -ItemType Directory -Force -Path $runtimeLogs | Out-Null

$ollama = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $ollama) {
    $fallback = Join-Path $env:LOCALAPPDATA 'Programs\Ollama\ollama.exe'
    if (-not (Test-Path -LiteralPath $fallback)) { throw 'Ollama no está instalado.' }
    $ollamaPath = $fallback
} else {
    $ollamaPath = $ollama.Source
}

if (Get-NetTCPConnection -LocalPort 11434 -State Listen -ErrorAction SilentlyContinue) {
    Write-Host 'Ollama ya escucha en 127.0.0.1:11434.'
    return
}

$env:OLLAMA_HOST = '127.0.0.1:11434'
$env:OLLAMA_CONTEXT_LENGTH = '32768'
Start-Process -FilePath $ollamaPath -ArgumentList 'serve' -WindowStyle Hidden `
    -RedirectStandardOutput (Join-Path $runtimeLogs 'ollama-native.out.log') `
    -RedirectStandardError (Join-Path $runtimeLogs 'ollama-native.err.log')

foreach ($attempt in 1..30) {
    Start-Sleep -Seconds 1
    try {
        $null = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/version' -TimeoutSec 2
        Write-Host 'Ollama nativo iniciado en http://127.0.0.1:11434.'
        return
    } catch {}
}

throw 'Ollama no inició. Revisa .runtime/logs/ollama-native.err.log.'
