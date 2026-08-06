# Runs every quality gate the CI workflow runs, in the same order.
# Usage:  .\tool\check.ps1  [-SkipCodegen]
param(
    [switch]$SkipCodegen
)

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

function Invoke-Step {
    param([string]$Name, [scriptblock]$Body)
    Write-Host ""
    Write-Host "==> $Name" -ForegroundColor Cyan
    & $Body
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: $Name" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

Invoke-Step "Dependencies" { flutter pub get }

if (-not $SkipCodegen) {
    # Drift generates the database code from lib/data/db/tables.dart.
    Invoke-Step "Code generation" { dart run build_runner build }
}

$formatTargets = @('lib', 'test', 'integration_test') | Where-Object { Test-Path $_ }
Invoke-Step "Format check" { dart format --set-exit-if-changed @formatTargets }
Invoke-Step "Analyze" { flutter analyze }
Invoke-Step "Tests" { flutter test --coverage }

Write-Host ""
Write-Host "All checks passed." -ForegroundColor Green
