[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot '.env'

if (-not (Test-Path -LiteralPath $envFile)) {
    throw 'Falta .env. Ejecuta scripts/bootstrap.ps1 primero.'
}

$settings = @{}
Get-Content -LiteralPath $envFile | Where-Object { $_ -match '^[A-Z0-9_]+=' } | ForEach-Object {
    $key, $value = $_ -split '=', 2
    $settings[$key] = $value.Trim('"')
}

$apiKey = $settings['LOCAL_BACKEND_API_KEY']
$model = $settings['OLLAMA_MODEL']
$contextLength = [int]$settings['OLLAMA_CONTEXT_LENGTH']
if (-not $apiKey -or -not $model) {
    throw 'LOCAL_BACKEND_API_KEY u OLLAMA_MODEL no están definidos en .env.'
}

$headers = @{ 'X-Session-API-Key' = $apiKey }
$baseUri = 'http://127.0.0.1:8000'
$deadline = (Get-Date).AddMinutes(2)
do {
    try {
        Invoke-RestMethod -Uri "$baseUri/ready" -TimeoutSec 5 | Out-Null
        break
    } catch {
        if ((Get-Date) -ge $deadline) { throw 'Agent Canvas no quedó listo en dos minutos.' }
        Start-Sleep -Seconds 2
    }
} while ($true)

$llm = @{
    model               = "openai/$model"
    api_key             = 'local-ollama'
    base_url            = 'http://ollama:11434/v1'
    api_mode            = 'chat'
    max_input_tokens    = $contextLength
    max_output_tokens   = 2048
    temperature         = 0.0
    native_tool_calling = $false
    timeout             = 600
}

$profileName = 'ollama-local'
$validation = Invoke-RestMethod -Method Post -Uri "$baseUri/api/profiles/$profileName/validate" `
    -Headers $headers -ContentType 'application/json' -Body (@{ llm = $llm } | ConvertTo-Json -Depth 10)
if (-not $validation.valid) {
    throw "OpenHands no pudo validar el perfil: $($validation.error.message)"
}

Invoke-RestMethod -Method Post -Uri "$baseUri/api/profiles/$profileName" -Headers $headers `
    -ContentType 'application/json' -Body (@{ llm = $llm; include_secrets = $true } | ConvertTo-Json -Depth 10) | Out-Null
Invoke-RestMethod -Method Post -Uri "$baseUri/api/profiles/$profileName/activate" -Headers $headers | Out-Null

$workspace = @{
    workspaces = @(@{
        id         = 'sandbox-project'
        name       = 'Agent Lab Sandbox'
        path       = '/projects/sandbox-project'
        parentPath = '/projects'
    })
}
Invoke-RestMethod -Method Post -Uri "$baseUri/api/workspaces" -Headers $headers `
    -ContentType 'application/json' -Body ($workspace | ConvertTo-Json -Depth 8) | Out-Null

$agentProfileDetail = Invoke-RestMethod -Uri "$baseUri/api/agent-profiles/default" -Headers $headers
$agentProfile = $agentProfileDetail.profile
$agentProfile.llm_profile_ref = $profileName
Invoke-RestMethod -Method Post -Uri "$baseUri/api/agent-profiles/default" -Headers $headers `
    -ContentType 'application/json' -Body ($agentProfile | ConvertTo-Json -Depth 20) | Out-Null

$agentProfiles = Invoke-RestMethod -Uri "$baseUri/api/agent-profiles" -Headers $headers
$defaultAgent = $agentProfiles.profiles | Where-Object { $_.name -eq 'default' } | Select-Object -First 1
if (-not $defaultAgent) { throw 'No se encontró el perfil de agente OpenHands predeterminado.' }

$diagnostics = Invoke-RestMethod -Method Post -Uri "$baseUri/api/agent-profiles/default/materialize" -Headers $headers
if (-not $diagnostics.valid) {
    throw "El perfil de agente no se pudo materializar: $($diagnostics.errors -join '; ')"
}
Invoke-RestMethod -Method Post -Uri "$baseUri/api/agent-profiles/$($defaultAgent.id)/activate" -Headers $headers | Out-Null

Write-Host "Perfil '$profileName' validado y activado: openai/$model"
Write-Host "Agente OpenHands 'default' enlazado y validado con '$profileName'"
Write-Host 'Workspace registrado: /projects/sandbox-project'
