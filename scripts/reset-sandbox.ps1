[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot 'fixtures\text_stats.broken.py'
$target = Join-Path $repoRoot 'sandbox-project\src\text_stats.py'
$result = Join-Path $repoRoot 'sandbox-project\AGENT_RESULT.md'

if ($PSCmdlet.ShouldProcess('sandbox-project', 'Restaurar el defecto deliberado y eliminar AGENT_RESULT.md')) {
    Copy-Item -LiteralPath $source -Destination $target -Force
    if (Test-Path -LiteralPath $result) {
        Remove-Item -LiteralPath $result -Force
    }
    Write-Host 'Sandbox restaurado al fixture inicial. Los tests deben fallar antes de ejecutar el agente.'
}
