$ErrorActionPreference = "Stop"
$toolsDirectory = Join-Path $env:TEMP "wix-3.14.1"
$archive = Join-Path $env:TEMP "wix-3.14.1.zip"

if (-not (Test-Path (Join-Path $toolsDirectory "candle.exe"))) {
    if (-not (Test-Path $archive)) {
        Invoke-WebRequest -Uri "https://github.com/wixtoolset/wix3/releases/download/wix3141rtm/wix314-binaries.zip" -OutFile $archive
    }
    if (Test-Path $toolsDirectory) { Remove-Item $toolsDirectory -Recurse -Force }
    Expand-Archive -Path $archive -DestinationPath $toolsDirectory
}

$output = Join-Path $PSScriptRoot "dist"
New-Item -ItemType Directory -Path $output -Force | Out-Null
$object = Join-Path $output "Product.wixobj"
$msi = Join-Path $output "Evino-Explorer-Restart-1.0.0.msi"

& (Join-Path $toolsDirectory "candle.exe") -nologo -arch x64 -out $object (Join-Path $PSScriptRoot "Product.wxs")
if ($LASTEXITCODE -ne 0) { throw "candle.exe failed: $LASTEXITCODE" }
& (Join-Path $toolsDirectory "light.exe") -nologo -out $msi $object
if ($LASTEXITCODE -ne 0) { throw "light.exe failed: $LASTEXITCODE" }

[pscustomobject]@{
    File = $msi
    ProductCode = "{EAE6D451-9055-4F80-B46F-75B758310A31}"
    SHA256 = (Get-FileHash $msi -Algorithm SHA256).Hash
}
