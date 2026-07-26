# SPDX-FileCopyrightText: 2026 Elan8
# SPDX-License-Identifier: MIT

[CmdletBinding()]
param([string]$ModelPath = "model")

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$resolvedModelPath = Join-Path $repoRoot $ModelPath
$modelFiles = Get-ChildItem -LiteralPath $resolvedModelPath -Recurse -Filter "*.sysml"
$modelText = ($modelFiles | Get-Content -Raw) -join "`n"
$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure([string]$message) {
    $failures.Add($message)
}

$forbiddenIdentityFields = @(
    "taskPath", "physicalFeaturePath", "functionPath", "requirementRefs",
    "verificationRefs", "relatedContractRefs", "payloadType",
    "producerPath", "consumerPath", "selectedModelElementPaths",
    "changedImplementationPaths", "selectedOptions", "excludedOptions",
    "authoritativeSourcePath", "sourcePackage", "primaryElementKind", "joinHint"
)
$identityPattern = "\b(" + (($forbiddenIdentityFields | ForEach-Object {
    [regex]::Escape($_)
}) -join "|") + ")\b"
if ($modelText -match $identityPattern) {
    Add-Failure "internal model identity must use semantic references, not path/reference fields"
}

$removedNames = @(
    "Implementation", "Elan8Methodology", "Elan8ProjectMethodology",
    "ElectronicsComponentSelection", "ElectronicsInterfaceControl",
    "ProductVariants", "TradeStudies", "SafetyAnalysis",
    "ComponentCandidate", "TradeOption", "VariantOption",
    "VerificationEvidence", "DataFlowContract"
)
foreach ($name in $removedNames) {
    if ($modelText -match ("\b" + [regex]::Escape($name) + "\b")) {
        Add-Failure "removed model element '$name' must not return"
    }
}
if ($modelText -match "\b[A-Za-z_][A-Za-z0-9_]*Handoff[A-Za-z0-9_]*\b") {
    Add-Failure "handoff record/view elements must not return"
}
if ($modelText -match "(?m)^\s*(?:part|item|metadata)\s+def\s+Hazard\b") {
    Add-Failure "the removed custom Hazard record must not return; HazardEvent is allowed"
}

$requirementNames = @(
    "cleanAtLeastEighty", "coverFloor", "avoidObstacles", "detectCliffs",
    "superviseHazards", "localizeReliably", "updateCoverageMap",
    "recoverFromStall", "returnToDock", "chargeSafely",
    "reportCleaningStatus", "protectMapPrivacy"
)
foreach ($requirement in $requirementNames) {
    if ($modelText -notmatch ("(?m)^\s*satisfy\s+" + [regex]::Escape($requirement) + "\s+by\s+")) {
        Add-Failure "requirement '$requirement' has no satisfaction path"
    }
    if ($modelText -notmatch ("(?m)^\s*verify\s+requirement\s+" + [regex]::Escape($requirement) + "\s*;")) {
        Add-Failure "requirement '$requirement' has no verification path"
    }
}

$catalogParts = @(
    "STM32U575VGT6", "DRV8316R", "VL53L1CX",
    "RPLIDARC1", "ESP32C3MINI1", "BQ40Z50R2"
)
$purchasedPartsText = Get-Content -Raw (
    Join-Path $resolvedModelPath "libraries\PurchasedParts.sysml"
)
$physicalText = Get-Content -Raw (
    Join-Path $resolvedModelPath "architecture\PhysicalArchitecture.sysml"
)
foreach ($part in $catalogParts) {
    if ($purchasedPartsText -notmatch ("part\s+def\s+" + $part + "\b")) {
        Add-Failure "catalog part '$part' is missing"
    }
    if ($physicalText -notmatch (":>\s*" + $part + "\b")) {
        Add-Failure "catalog part '$part' has no project specialization"
    }
}
if ([regex]::Matches($purchasedPartsText, "@BuyPart\s*\{").Count -ne 6) {
    Add-Failure "PurchasedParts must contain exactly six BuyPart annotations"
}
foreach ($field in @(
    "manufacturer", "manufacturerPartNumber", "productPageUrl", "datasheetUrl",
    "datasheetDocumentId", "datasheetRevision", "lifecycleStatus", "sourceCheckedOn"
)) {
    if ([regex]::Matches($purchasedPartsText, ("\b" + $field + "\s*=")).Count -ne 6) {
        Add-Failure "every BuyPart annotation must set '$field'"
    }
}

$firmwareText = Get-Content -Raw (
    Join-Path $resolvedModelPath "implementation\FirmwareArchitecture.sysml"
)
if ([regex]::Matches($firmwareText, "part\s+def\s+\w+Task\s*:>\s*FirmwareTask").Count -ne 7) {
    Add-Failure "FirmwareArchitecture must define exactly seven concrete firmware tasks"
}
foreach ($queue in @(
    "hazardQueue", "userCommandQueue", "plannerCommandQueue",
    "safetyCommandQueue", "mapUpdateQueue"
)) {
    if ($firmwareText -notmatch ("part\s+" + $queue + "\s*:")) {
        Add-Failure "runtime queue '$queue' is missing"
    }
    if ($firmwareText -notmatch ([regex]::Escape($queue) + "\.transfer\.enqueue")) {
        Add-Failure "runtime queue '$queue' has no typed producer flow"
    }
    if ($firmwareText -notmatch ([regex]::Escape($queue) + "\.transfer\.dequeue")) {
        Add-Failure "runtime queue '$queue' has no typed consumer flow"
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Model guards passed: lean graph, purchased parts, runtime queues, and traceability are clean."
