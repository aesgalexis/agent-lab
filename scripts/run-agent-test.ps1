[CmdletBinding()]
param(
    [int]$MaxIterations = 20,
    [int]$PollSeconds = 5
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot '.env'
$runtimeRoot = Join-Path $repoRoot '.runtime'

if (-not (Test-Path -LiteralPath $envFile)) { throw 'Falta .env. Ejecuta scripts/bootstrap.ps1.' }
if (Test-Path -LiteralPath (Join-Path $repoRoot 'sandbox-project\AGENT_RESULT.md')) {
    throw 'AGENT_RESULT.md ya existe. Restaura primero el fixture inicial desde Git para repetir la prueba.'
}

$settings = @{}
Get-Content -LiteralPath $envFile | Where-Object { $_ -match '^[A-Z0-9_]+=' } | ForEach-Object {
    $key, $value = $_ -split '=', 2
    $settings[$key] = $value.Trim('"')
}
$headers = @{ 'X-Session-API-Key' = $settings['LOCAL_BACKEND_API_KEY'] }
$baseUri = 'http://127.0.0.1:8000'
$model = $settings['OLLAMA_MODEL']
$llm = @{
    model               = "openai/$model"
    api_key             = 'local-ollama'
    base_url            = 'http://ollama:11434/v1'
    api_mode            = 'chat'
    max_input_tokens    = [int]$settings['OLLAMA_CONTEXT_LENGTH']
    max_output_tokens   = 2048
    temperature         = 0.0
    native_tool_calling = $false
    timeout             = 600
}
$task = @'
Trabaja exclusivamente en este proyecto aislado. Lee TASK.md y cumple exactamente la tarea. Inspecciona los archivos, ejecuta primero los tests para observar el fallo, corrige solo el código de producción necesario, vuelve a ejecutar los tests y crea AGENT_RESULT.md con un resumen breve de archivos modificados y comandos/tests ejecutados. No modifiques los tests. Cuando todo pase, finaliza.
'@
$request = @{
    workspace           = @{ working_dir = '/projects/sandbox-project'; kind = 'LocalWorkspace' }
    worktree            = $false
    confirmation_policy = @{ kind = 'NeverConfirm' }
    initial_message     = @{ role = 'user'; content = @(@{ type = 'text'; text = $task.Trim() }); run = $true }
    max_iterations      = $MaxIterations
    stuck_detection     = $true
    autotitle           = $false
    agent               = @{
        kind  = 'Agent'
        llm   = $llm
        tools = @(
            @{ name = 'terminal'; params = @{} }
            @{ name = 'file_editor'; params = @{} }
        )
    }
}

$conversation = Invoke-RestMethod -Method Post -Uri "$baseUri/api/conversations" -Headers $headers `
    -ContentType 'application/json' -Body ($request | ConvertTo-Json -Depth 20)
New-Item -ItemType Directory -Force -Path $runtimeRoot | Out-Null
Set-Content -LiteralPath (Join-Path $runtimeRoot 'last-conversation-id.txt') -Value $conversation.id -Encoding ascii
Write-Host "Conversación: $($conversation.id)"

do {
    Start-Sleep -Seconds $PollSeconds
    $current = (Invoke-RestMethod -Uri "$baseUri/api/conversations?ids=$($conversation.id)" -Headers $headers)[0]
    $eventCount = Invoke-RestMethod -Uri "$baseUri/api/conversations/$($conversation.id)/events/count" -Headers $headers
    Write-Host "Estado: $($current.execution_status); eventos: $eventCount"
} while ($current.execution_status -eq 'running')

$final = Invoke-RestMethod -Uri "$baseUri/api/conversations/$($conversation.id)/agent_final_response" -Headers $headers
Write-Host "Respuesta final: $($final.response)"
if ($current.execution_status -ne 'finished') {
    throw "La conversación terminó con estado '$($current.execution_status)'."
}

& (Join-Path $PSScriptRoot 'verify-agent-result.ps1')
