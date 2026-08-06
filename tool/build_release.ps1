# Builds the Android App Bundle to upload to Google Play.
#
#   .\tool\build_release.ps1
#
# Play requires an .aab rather than an .apk for new apps, and it must be signed
# with your upload key - see android/key.properties.example.
#
# Kept to plain ASCII with no here-strings: Windows PowerShell 5.1 reads a
# BOM-less file as ANSI, and both of those trip its parser.

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

# --- Refuse to build something Play will only reject -----------------------

if (-not (Test-Path 'android/key.properties')) {
    Write-Host ""
    Write-Host "No android/key.properties found." -ForegroundColor Red
    Write-Host ""
    Write-Host "Without it the release is signed with the debug key, which the"
    Write-Host "Play Console rejects on upload. To set it up:"
    Write-Host ""
    Write-Host "  1. Create the keystore, OUTSIDE this repository:"
    Write-Host ""
    Write-Host '       keytool -genkey -v -alias upload -keyalg RSA -keysize 2048 \'
    Write-Host '         -validity 10000 -storetype JKS \'
    Write-Host '         -keystore $env:USERPROFILE\baseline-upload-keystore.jks'
    Write-Host ""
    Write-Host "  2. Copy android/key.properties.example to android/key.properties"
    Write-Host "     and fill in the passwords and the path from step 1."
    Write-Host ""
    Write-Host "  3. Back up the .jks file and its passwords somewhere durable."
    Write-Host "     Losing the upload key means you cannot ship an update without"
    Write-Host "     asking Google to reset it."
    Write-Host ""
    exit 1
}

# --- Version ---------------------------------------------------------------

$version = (Select-String -Path 'pubspec.yaml' -Pattern '^version:\s*(.+)$').Matches[0].Groups[1].Value.Trim()
Write-Host "Building Baseline $version" -ForegroundColor Green
Write-Host "Play rejects a versionCode it has already accepted - bump the +N" -ForegroundColor DarkGray
Write-Host "in pubspec.yaml for every upload." -ForegroundColor DarkGray

# --- Gates -----------------------------------------------------------------

Write-Host ""
Write-Host "==> Quality checks" -ForegroundColor Cyan
& "$PSScriptRoot\check.ps1"
if ($LASTEXITCODE -ne 0) { throw "Checks failed; not building a release." }

# --- Build -----------------------------------------------------------------

# Symbols are split out so Play crash reports can be symbolicated without
# shipping debug information inside the bundle itself.
$symbols = 'build/symbols'

Write-Host ""
Write-Host "==> App bundle" -ForegroundColor Cyan
flutter build appbundle --release --obfuscate --split-debug-info=$symbols
if ($LASTEXITCODE -ne 0) { throw "Bundle build failed." }

$aab = 'build/app/outputs/bundle/release/app-release.aab'
$sizeMb = [math]::Round((Get-Item $aab).Length / 1MB, 1)

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "  Bundle   $aab"
Write-Host "  Size     $sizeMb MB"
Write-Host "  Symbols  $symbols"
Write-Host ""
Write-Host "Upload the bundle under Play Console, Production, Create new release."
Write-Host "Attach the symbols directory there too, for readable crash reports."
