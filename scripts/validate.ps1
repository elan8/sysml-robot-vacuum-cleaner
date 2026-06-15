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

if (-not $Spec42Exe) {
    if ($env:SPEC42_EXE) {
        $Spec42Exe = $env:SPEC42_EXE
    } else {
        $Spec42Exe = "spec42"
    }
}

if (-not $DomainLibrariesRoot) {
    if ($env:SYSML_DOMAIN_LIBRARIES_ROOT) {
        $DomainLibrariesRoot = $env:SYSML_DOMAIN_LIBRARIES_ROOT
    } else {
        $siblingDomainLibrariesRoot = Join-Path (Split-Path -Parent $repoRoot) "sysml-domain-libraries"
        if (Test-Path $siblingDomainLibrariesRoot) {
            $DomainLibrariesRoot = $siblingDomainLibrariesRoot
        }
    }
}

$arguments = @("check", $resolvedModelPath, "--format", $Format)

if ($DomainLibrariesRoot) {
    foreach ($subdir in @("domain", "technical", "generic")) {
        $libraryPath = Join-Path $DomainLibrariesRoot $subdir
        if (Test-Path $libraryPath) {
            $arguments += @("--library-path", $libraryPath)
        } else {
            Write-Warning "Domain library path not found: $libraryPath"
        }
    }
}

Write-Host "Running: $Spec42Exe $($arguments -join ' ')"
& $Spec42Exe @arguments
exit $LASTEXITCODE
