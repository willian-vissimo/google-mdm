param(
    [Parameter(Mandatory)]
    [string]$ExplorerMsi,
    [Parameter(Mandatory)]
    [string]$HibernationMsi
)

$ErrorActionPreference = "Stop"
$legacyProduct = "{A650F4CC-7C06-4AB6-BB3D-4F713A55A301}"

function Invoke-Msi {
    param([string]$Arguments, [string]$Operation)

    $process = Start-Process msiexec.exe -ArgumentList $Arguments -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "$Operation failed with exit code $($process.ExitCode)"
    }
}

Invoke-Msi -Operation "Legacy package removal" -Arguments ('/x "{0}" /qn /norestart' -f $legacyProduct)
Invoke-Msi -Operation "Explorer package installation" -Arguments ('/i "{0}" /qn /norestart' -f $ExplorerMsi)
Invoke-Msi -Operation "Hibernation package installation" -Arguments ('/i "{0}" /qn /norestart' -f $HibernationMsi)

$legacyTasks = @(Get-ScheduledTask -TaskName "Evino-ReiniciarExplorer-*", "Evino-SolicitarReinicio-*", "Evino-ReinicioObrigatorio-23h" -ErrorAction SilentlyContinue)
if ($legacyTasks.Count -ne 0) {
    throw "Legacy scheduled tasks remain after migration"
}

$hibernationTask = Get-ScheduledTask -TaskName "Evino-Hibernacao-4h" -ErrorAction Stop
[pscustomobject]@{
    LegacyTasksRemoved = $legacyTasks.Count -eq 0
    HibernationTaskInstalled = $null -ne $hibernationTask
}
