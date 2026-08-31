[CmdletBinding()]
param()

$processes = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like 'ollama*' }
if (-not $processes) {
    Write-Host 'No hay procesos Ollama nativos activos.'
    return
}

$processes | Stop-Process -Force
Write-Host 'Procesos Ollama nativos detenidos.'
