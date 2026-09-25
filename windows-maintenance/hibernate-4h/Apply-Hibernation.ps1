$ErrorActionPreference = "Stop"

$powerCfg = "$env:SystemRoot\System32\powercfg.exe"

& $powerCfg /hibernate on
if ($LASTEXITCODE -ne 0) { throw "Failed to enable hibernation: $LASTEXITCODE" }

& $powerCfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 14400
if ($LASTEXITCODE -ne 0) { throw "Failed to set AC hibernation timeout: $LASTEXITCODE" }

& $powerCfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 14400
if ($LASTEXITCODE -ne 0) { throw "Failed to set DC hibernation timeout: $LASTEXITCODE" }

& $powerCfg /setactive SCHEME_CURRENT
if ($LASTEXITCODE -ne 0) { throw "Failed to activate the power scheme: $LASTEXITCODE" }
