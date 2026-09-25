$ErrorActionPreference = "SilentlyContinue"

Unregister-ScheduledTask -TaskName "Evino-Hibernacao-4h" -Confirm:$false

$powerCfg = "$env:SystemRoot\System32\powercfg.exe"
& $powerCfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0
& $powerCfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0
& $powerCfg /setactive SCHEME_CURRENT
exit 0
