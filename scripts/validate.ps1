# SPDX-FileCopyrightText: 2026 Elan8
# SPDX-License-Identifier: MIT

[CmdletBinding()]
param(
    [string]$Spec42Exe,
    [string]$DomainLibrariesRoot,
    [string]$ModelPath = "model",
    [ValidateSet("text", "json")]
    [string]$Format = "text"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$resolvedModelPath = Join-Path $repoRoot $ModelPath
$parentRoot = Split-Path -Parent $repoRoot

if (-not $Spec42Exe) {
    if ($env:SPEC42_EXE) {
        $Spec42Exe = $env:SPEC42_EXE
    } elseif (Test-Path "C:\Git\elan8\spec42\target\debug\spec42.exe") {
        $Spec42Exe = "C:\Git\elan8\spec42\target\debug\spec42.exe"
    } else {
        $Spec42Exe = "spec42"
    }
}

if (-not $DomainLibrariesRoot) {
    if ($env:SYSML_DOMAIN_LIBRARIES_ROOT) {
        $DomainLibrariesRoot = $env:SYSML_DOMAIN_LIBRARIES_ROOT
    } else {
        $siblingDomainLibrariesRoot = Join-Path $parentRoot "sysml-domain-libraries"
        if (Test-Path $siblingDomainLibrariesRoot) {
            $DomainLibrariesRoot = $siblingDomainLibrariesRoot
        }
    }
}

# Validate against the explicitly selected source libraries. Disabling managed
# KPAR variants prevents stale installed packages from masking migration errors;
# `method` is the managed archive older Spec42 releases bundle.
$arguments = @(
    "--disable-kpar-library", "domain",
    "--disable-kpar-library", "method"
)

if ($DomainLibrariesRoot) {
    # The domain libraries live under one root that Elan8.sysml ties together.
    $libraryPath = Join-Path $DomainLibrariesRoot "model"
    if (Test-Path $libraryPath) {
        $arguments += @("--library-path", (Resolve-Path $libraryPath))
    } else {
        Write-Warning "Domain library path not found: $libraryPath"
    }
}

$arguments += @("check", $resolvedModelPath, "--format", $Format, "--warnings-as-errors")

Write-Host "Running: $Spec42Exe $($arguments -join ' ')"
& $Spec42Exe @arguments
$spec42ExitCode = $LASTEXITCODE
if ($spec42ExitCode -ne 0) {
    exit $spec42ExitCode
}

$guardScript = Join-Path $PSScriptRoot "check-model-guards.ps1"
& $guardScript -ModelPath $ModelPath
exit $LASTEXITCODE
