# SPDX-FileCopyrightText: 2026 Elan8
# SPDX-License-Identifier: MIT

[CmdletBinding()]
param(
    [string]$ModelPath = "model"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$resolvedModelPath = Join-Path $repoRoot $ModelPath
$modelFiles = Get-ChildItem -LiteralPath $resolvedModelPath -Recurse -Filter "*.sysml"
$failures = [System.Collections.Generic.List[string]]::new()

$forbiddenIdentityFields = @(
    "taskPath",
    "physicalFeaturePath",
    "functionPath",
    "requirementRefs",
    "verificationRefs",
    "relatedContractRefs",
    "selectedModelElementPaths",
    "changedImplementationPaths",
    "selectedOptions",
    "excludedOptions",
    "authoritativeSourcePath",
    "sourcePackage",
    "primaryElementKind",
    "joinHint"
)

$forbiddenPattern = "\b(" + (($forbiddenIdentityFields | ForEach-Object {
    [regex]::Escape($_)
}) -join "|") + ")\b"

foreach ($match in $modelFiles | Select-String -Pattern $forbiddenPattern) {
    $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $match.Path)
    $failures.Add(
        "$relativePath`:$($match.LineNumber): internal model identity must be a semantic reference, not '$($match.Matches[0].Value)'"
    )
}

$requirementNames = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)

foreach ($file in $modelFiles) {
    foreach ($line in Get-Content -LiteralPath $file.FullName) {
        if ($line -match "^\s*requirement\s+([A-Za-z_][A-Za-z0-9_]*)\s*(\{|:)") {
            [void]$requirementNames.Add($Matches[1])
        }
    }
}

foreach ($file in $modelFiles) {
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $file.FullName) {
        $lineNumber++
        if ($line -match "^\s*satisfy\s+([A-Za-z_][A-Za-z0-9_:.]*)\s+by\s+") {
            $source = $Matches[1]
            $sourceLeaf = ($source -split "[:.]")[-1]
            if (-not $requirementNames.Contains($sourceLeaf)) {
                $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $file.FullName)
                $failures.Add(
                    "$relativePath`:$lineNumber`: satisfy source '$source' is not a requirement; expected 'satisfy <requirement> by <design>'"
                )
            }
        }
    }
}

$removedRecordTypes = @(
    "SoftwareImplementationRecord",
    "ElectronicsWorkPackage",
    "RailBudgetRecord",
    "VariantOptionRecord",
    "HazardRecord"
)

foreach ($recordType in $removedRecordTypes) {
    foreach ($match in $modelFiles | Select-String -SimpleMatch $recordType) {
        $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $match.Path)
        $failures.Add(
            "$relativePath`:$($match.LineNumber): removed record type '$recordType' must not return"
        )
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Model guards passed: semantic satisfy direction and graph-first identity rules are clean."
