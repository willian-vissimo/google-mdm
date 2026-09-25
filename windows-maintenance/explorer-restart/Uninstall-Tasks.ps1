$ErrorActionPreference = "SilentlyContinue"

Get-ScheduledTask -TaskName "Evino-ExplorerRestart-*" |
    Unregister-ScheduledTask -Confirm:$false
exit 0
