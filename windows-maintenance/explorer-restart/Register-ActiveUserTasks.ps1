$ErrorActionPreference = "Stop"

$registerScript = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "Register-UserTask.ps1"
$userSids = Get-CimInstance Win32_Process -Filter "Name = 'explorer.exe'" |
    ForEach-Object { Invoke-CimMethod -InputObject $_ -MethodName GetOwnerSid } |
    Where-Object { $_.ReturnValue -eq 0 -and $_.Sid } |
    Select-Object -ExpandProperty Sid -Unique

foreach ($userSid in $userSids) {
    & $registerScript -UserSid $userSid
}
