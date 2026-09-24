[CmdletBinding()]
param(
    [string]$IdServer = "remote.tyberian.com",
    [string]$RelayServer = "",
    [Parameter(Mandatory = $false)][string]$ServerKey = "",
    [string]$ProductName = "Tyberian Remote Support",
    [string]$CompanyName = "Tyberian",
    [string]$SupportUrl = "https://remote.tyberian.com",
    [string]$SupportEmail = "",
    [string]$SourceCodeUrl = "https://github.com/rustdesk/rustdesk",
    [string]$Icon = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

if ([string]::IsNullOrWhiteSpace($IdServer)) {
    throw "IdServer must not be blank."
}
if ($env:SERVER_PRIVATE_KEY) {
    throw "SERVER_PRIVATE_KEY must not be supplied to a client build."
}

$defines = @{
    QUICK_SUPPORT_MODE = "true"
    PRODUCT_NAME = $ProductName
    COMPANY_NAME = $CompanyName
    SUPPORT_URL = $SupportUrl
    SUPPORT_EMAIL = $SupportEmail
    SOURCE_CODE_URL = $SourceCodeUrl
    ID_SERVER = $IdServer
    RELAY_SERVER = $RelayServer
    SERVER_PUBLIC_KEY = $ServerKey
}
$env:TYBERIAN_QUICK_SUPPORT = "1"
$defineFile = Join-Path $env:TEMP "tyberian-build-defines.json"
$defines | ConvertTo-Json | Set-Content -Encoding UTF8 $defineFile
$env:FLUTTER_BUILD_ARGS = "--dart-define-from-file=`"$defineFile`""

$iconTarget = Join-Path $root "flutter\windows\runner\resources\app_icon.ico"
$iconBackup = "$iconTarget.tyberian-backup"
try {
    Remove-Item (Join-Path $root "TyberianRemoteSupport.exe") -ErrorAction SilentlyContinue
    if ($Icon) {
        if (-not (Test-Path $Icon)) { throw "Icon file not found: $Icon" }
        Copy-Item $iconTarget $iconBackup -Force
        Copy-Item $Icon $iconTarget -Force
    }
    py -3 build.py --flutter
    if (-not (Test-Path (Join-Path $root "TyberianRemoteSupport.exe"))) {
        throw "Build completed without producing TyberianRemoteSupport.exe"
    }
    Write-Host "Created $root\TyberianRemoteSupport.exe"
}
finally {
    if (Test-Path $iconBackup) {
        Move-Item $iconBackup $iconTarget -Force
    }
    Remove-Item $defineFile -ErrorAction SilentlyContinue
    Remove-Item Env:FLUTTER_BUILD_ARGS -ErrorAction SilentlyContinue
    Remove-Item Env:TYBERIAN_QUICK_SUPPORT -ErrorAction SilentlyContinue
}
