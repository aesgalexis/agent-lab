[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$result = Join-Path $repoRoot 'sandbox-project\AGENT_RESULT.md'
if (-not (Test-Path -LiteralPath $result)) {
    throw 'Falta sandbox-project/AGENT_RESULT.md; el agente no ha terminado la tarea esperada.'
}

Push-Location $repoRoot
try {
    docker compose exec -T agent-canvas bash -lc 'cd /projects/sandbox-project && python -m unittest discover -s tests -v'
    git diff --check -- sandbox-project
    git status --short -- sandbox-project
    git diff -- sandbox-project
} finally {
    Pop-Location
}
