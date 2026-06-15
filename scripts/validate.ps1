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
    $localSpec42 = "C:\Git\spec42\target\debug\spec42.exe"
    if (Test-Path $localSpec42) {
        $Spec42Exe = $localSpec42
    } else {
        $Spec42Exe = "spec42"
    }
}

if (-not $DomainLibrariesRoot) {
    $defaultDomainLibrariesRoot = "C:\Git\sysml-domain-libraries"
    if (Test-Path $defaultDomainLibrariesRoot) {
        $DomainLibrariesRoot = $defaultDomainLibrariesRoot
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
