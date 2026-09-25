$ErrorActionPreference = "Stop"

$installDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$applyScript = Join-Path $installDirectory "Apply-Hibernation.ps1"
$powerShell = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

& $powerShell -NoProfile -ExecutionPolicy Bypass -File $applyScript
if ($LASTEXITCODE -ne 0) { throw "Initial hibernation configuration failed: $LASTEXITCODE" }

$action = New-ScheduledTaskAction `
    -Execute $powerShell `
    -Argument ('-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}"' -f $applyScript)
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
    -MultipleInstances IgnoreNew

Register-ScheduledTask `
    -TaskName "Evino-Hibernacao-4h" `
    -Description "Habilita e aplica hibernacao apos quatro horas de inatividade." `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Force | Out-Null
