$ErrorActionPreference = "Stop"

$sessionId = [System.Diagnostics.Process]::GetCurrentProcess().SessionId
$explorerProcesses = Get-Process -Name explorer -ErrorAction SilentlyContinue |
    Where-Object { $_.SessionId -eq $sessionId }

if (-not $explorerProcesses) {
    exit 0
}

$explorerProcesses | Stop-Process -Force

$deadline = (Get-Date).AddSeconds(10)
do {
    Start-Sleep -Milliseconds 500
    $shell = Get-Process -Name explorer -ErrorAction SilentlyContinue |
        Where-Object { $_.SessionId -eq $sessionId }
} while (-not $shell -and (Get-Date) -lt $deadline)

if (-not $shell) {
    Start-Process "$env:WINDIR\explorer.exe"
}
