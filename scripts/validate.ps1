# SPDX-FileCopyrightText: 2026 Elan8
# SPDX-License-Identifier: MIT
[CmdletBinding()]
param(
    [string]$Spec42Exe = $env:SPEC42_EXE,
    [string]$DomainLibrariesRoot = $env:SYSML_DOMAIN_LIBRARIES_ROOT,
    [string]$MethodologyRoot = $env:MBSE_METHODOLOGY_ROOT,
    [string]$ModelPath = "model",
    [ValidateSet("text", "json")][string]$Format = "text"
)
$ErrorActionPreference = "Stop"
if ($Spec42Exe) { $env:SPEC42_EXE = $Spec42Exe }
if ($DomainLibrariesRoot) { $env:SYSML_DOMAIN_LIBRARIES_ROOT = $DomainLibrariesRoot }
if ($MethodologyRoot) { $env:MBSE_METHODOLOGY_ROOT = $MethodologyRoot }
python (Join-Path $PSScriptRoot "validate_model.py") --model $ModelPath --format $Format
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& (Join-Path $PSScriptRoot "check-model-guards.ps1") -ModelPath $ModelPath
exit $LASTEXITCODE
