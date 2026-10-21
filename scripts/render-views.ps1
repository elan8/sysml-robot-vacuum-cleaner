# SPDX-FileCopyrightText: 2026 Elan8
# SPDX-License-Identifier: MIT

[CmdletBinding()]
param(
    [string]$Spec42Exe = $(if ($env:SPEC42_EXE) { $env:SPEC42_EXE } else { "spec42" }),
    [string]$DomainLibrariesRoot,
    [string]$MethodLibraryRoot,
    [string]$OutputPath = "target/model-views",
    [string]$ResvgExe
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$parentRoot = Split-Path -Parent $repoRoot
if (-not $DomainLibrariesRoot) {
    $DomainLibrariesRoot = Join-Path $parentRoot "sysml-domain-libraries"
}
if (-not $MethodLibraryRoot) {
    $MethodLibraryRoot = Join-Path (Join-Path $parentRoot "mbse-methodology") "library"
}
$outputDirectory = if ([IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath
} else {
    Join-Path $repoRoot $OutputPath
}
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$diagramArguments = @(
    "--disable-kpar-library", "domain",
    "--disable-kpar-library", "method",
    "--library-path", (Resolve-Path $MethodLibraryRoot).Path,
    "--library-path", (Resolve-Path (Join-Path $DomainLibrariesRoot "model")).Path,
    "diagram", (Join-Path $repoRoot "model")
)

# These are presentation depths, not changes to the selected semantic content.
# Module-boundary connections are readable with internals closed. Composition
# views show one level of members; a reviewer can expand further in the editor.
$views = [ordered]@{
    productDecomposition = 1
    baseDecomposition = 1
    topDecomposition = 1
    mainPcbDecomposition = 1
    powerDecomposition = 1
    interconnections = 0
    firmwareDeployment = 0
    systemRequirements = 1
    cliffSafeStopScenario = 1
}
$rows = @()
foreach ($entry in $views.GetEnumerator()) {
    $name = $entry.Key
    $svg = Join-Path $outputDirectory "$name.svg"
    & $Spec42Exe @diagramArguments --view "ModelViews::$name" --depth $entry.Value --format svg --output $svg
    if ($LASTEXITCODE -ne 0) { throw "SVG export failed: $name" }
    $json = Join-Path $outputDirectory "$name.json"
    & $Spec42Exe @diagramArguments --view "ModelViews::$name" --format json --output $json
    if ($LASTEXITCODE -ne 0) { throw "Diagram product export failed: $name" }
    $product = Get-Content -LiteralPath $json -Raw | ConvertFrom-Json
    if ($product.completeness.status -ne "complete") {
        throw "Incomplete diagram projection: $name (see $json)"
    }
    $pngLink = ""
    if ($ResvgExe) {
        & $ResvgExe $svg (Join-Path $outputDirectory "$name.png") --width 1800
        if ($LASTEXITCODE -ne 0) { throw "PNG conversion failed: $name" }
        $pngLink = " | <a href='$name.png'>PNG</a>"
    }
    $rows += "<article><h2>$name</h2><p><a href='$name.svg'>SVG</a>$pngLink | <a href='$name.json'>Diagram product</a></p><img src='$name.svg' alt='$name'></article>"
}
$html = @"
<!doctype html><meta charset="utf-8"><title>Robot model views</title>
<style>body{font:16px system-ui;max-width:1200px;margin:32px auto;padding:16px}article{border-top:1px solid #ccc;margin-top:32px}img{width:100%;max-height:900px;object-fit:contain}</style>
<h1>Robot model views</h1><p>See docs/VIEWS.md for each view's engineering question and scope. All nine exported diagram projections are complete.</p>
$($rows -join "`n")
"@
Set-Content -LiteralPath (Join-Path $outputDirectory "index.html") -Value $html -Encoding utf8
Write-Host "Rendered $($views.Count) views to $outputDirectory"
