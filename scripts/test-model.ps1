[CmdletBinding()]
param(
    [string]$BaseUrl = 'http://127.0.0.1:11434/v1'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot '.env'
$model = 'qwen2.5-coder:7b'
if (Test-Path -LiteralPath $envFile) {
    $modelLine = Get-Content -LiteralPath $envFile | Where-Object { $_ -match '^OLLAMA_MODEL=' } | Select-Object -First 1
    if ($modelLine) { $model = ($modelLine -split '=', 2)[1] }
}

$inventory = Invoke-RestMethod -Uri "$BaseUrl/models" -TimeoutSec 15
if ($inventory.data.id -notcontains $model) {
    throw "El modelo $model no aparece en $BaseUrl/models."
}

$body = @{
    model = $model
    messages = @(@{ role = 'user'; content = 'Responde exactamente con: AGENT_LAB_MODEL_OK' })
    temperature = 0
    max_tokens = 32
    stream = $false
} | ConvertTo-Json -Depth 6

$timer = [Diagnostics.Stopwatch]::StartNew()
$response = Invoke-RestMethod -Method Post -Uri "$BaseUrl/chat/completions" -ContentType 'application/json' -Body $body -TimeoutSec 900
$timer.Stop()
$text = $response.choices[0].message.content.Trim()
if ($text -ne 'AGENT_LAB_MODEL_OK') {
    throw "Respuesta inesperada: $text"
}

Write-Host "Modelo: $model"
Write-Host "Respuesta: $text"
Write-Host "Tiempo: $([math]::Round($timer.Elapsed.TotalSeconds, 1)) s"
