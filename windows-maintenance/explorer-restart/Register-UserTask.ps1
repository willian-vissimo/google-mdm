$ErrorActionPreference = "Stop"

$installDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$powerShell = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$userName = $identity.Name
$suffix = $identity.User.Value.Replace("-", "_")

$principal = New-ScheduledTaskPrincipal `
    -UserId $userName `
    -LogonType Interactive `
    -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable:$false `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 2) `
    -MultipleInstances IgnoreNew
$action = New-ScheduledTaskAction `
    -Execute $powerShell `
    -Argument ('-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}"' -f (Join-Path $installDirectory "Restart-Explorer.ps1"))
$triggers = @(
    New-ScheduledTaskTrigger -Daily -At "10:00"
    New-ScheduledTaskTrigger -Daily -At "14:00"
    New-ScheduledTaskTrigger -Daily -At "18:00"
)

Register-ScheduledTask `
    -TaskName "Evino-ExplorerRestart-$suffix" `
    -Description "Reinicia o Windows Explorer as 10:00, 14:00 e 18:00." `
    -Action $action `
    -Trigger $triggers `
    -Principal $principal `
    -Settings $settings `
    -Force | Out-Null
