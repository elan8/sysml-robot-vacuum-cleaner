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
    "DataFlowContract"
)
foreach ($name in $removedNames) {
    if ($modelText -match ("\b" + [regex]::Escape($name) + "\b")) {
        Add-Failure "removed model element '$name' must not return"
    }
}
if ($modelText -match "\b[A-Za-z_][A-Za-z0-9_]*Handoff[A-Za-z0-9_]*\b") {
    Add-Failure "handoff record/view elements must not return"
}
if ($modelText -match "(?i)golden[\s_-]*thread|engineering\s+increment") {
    Add-Failure "methodology workflow terminology must not appear as product-model vocabulary"
}
if ($modelText -match "(?m)^\s*(?:part|item|metadata)\s+def\s+Hazard\b") {
    Add-Failure "the removed custom Hazard record must not return; HazardEvent is allowed"
}

$requirementNames = @(
    "'Cleaning area per charge'",
    "'Floor coverage'",
    "'Obstacle avoidance'",
    "'Cliff detection'",
    "'Safe stop on hazard'",
    "'Localization accuracy'",
    "'Coverage map maintenance'",
    "'Wheel stall detection and recovery'",
    "'Return to dock on low battery'",
    "'Charging within the battery safe operating area'",
    "'Mission status reporting'",
    "'Local storage of map data'",
    "'Overall height'",
    "'Acoustic noise'",
    "'Dust bin capacity'",
    "'Threshold climbing'",
    "'Robot mass'",
    "'Recharge time'",
    "'Battery protection independent of firmware'",
    "'Operating modes'",
    "'Safe stop held until cleared'"
)
foreach ($requirement in $requirementNames) {
    $qualifiedPrefix = "(?:[A-Za-z_][A-Za-z0-9_]*(?:::|\.))*"
    if ($modelText -notmatch ("(?m)^\s*satisfy\s+" + $qualifiedPrefix +
            [regex]::Escape($requirement) + "\s+by\s+")) {
        Add-Failure "requirement '$requirement' has no satisfaction path"
    }
    if ($modelText -notmatch ("(?m)^\s*verify\s+" + $qualifiedPrefix +
            [regex]::Escape($requirement) + "\s*;")) {
        Add-Failure "requirement '$requirement' has no verification path"
    }
}

$catalogSelections = [ordered]@{
    "RobotMainMcu" = "STM32U575VGT6"
    "RobotMotorDriver" = "DRV8316R"
    "RobotTofSensor" = "VL53L1CX"
    "RobotLidar" = "RPLIDARC1"
    "RobotWirelessModule" = "ESP32C3MINI1"
    "RobotBms" = "BQ40Z50R2"
}
$purchasedPartsText = Get-Content -Raw (
    Join-Path $resolvedModelPath "50_library/PurchasedParts.sysml"
)
$physicalText = $modelText
foreach ($part in $catalogSelections.Values) {
    if ($purchasedPartsText -notmatch ("part\s+def\s+" + $part + "\b")) {
        Add-Failure "catalog part '$part' is missing"
    }
    if ($physicalText -match (":>\s*" + $part + "\b")) {
        Add-Failure "catalog part '$part' must be selected, not specialized"
    }
}
foreach ($selection in $catalogSelections.GetEnumerator()) {
    $designSuffix = if ($selection.Key -eq "RobotMainMcu") { "Integration" } else { "Architecture" }
    $partBodyPattern = "part\s+def\s+" + [regex]::Escape($selection.Key) + $designSuffix +
        "\b[^{]*\{(?<body>[\s\S]*?)\n\s*\}"
    $partMatch = [regex]::Match($physicalText, $partBodyPattern)
    $dependencyPattern = "dependency\s+selectedImplementation\s+from\s+" +
        [regex]::Escape($selection.Key) + "(?:Architecture|Integration)\s+to\s+" +
        [regex]::Escape($selection.Value) + "\s*;"
    if (-not $partMatch.Success -or
        $partMatch.Groups["body"].Value -notmatch $dependencyPattern) {
        Add-Failure "project part '$($selection.Key)' must own a 'selectedImplementation' dependency to '$($selection.Value)'"
    }
}

$requiredPhysicalConnections = @(
    "connect dockPowerInput to dockInterface.dockPowerInput;",
    "connect dockInterface.chargePowerOutput to powerModule.charger.supplyInput;",
    "connect charger.chargeOutput to bms.chargeInput;",
    "connect battery.terminal to bms.batteryTerminal;",
    "connect bms.protectedOutput to batteryRail;",
    "connect beaconInput to dockInterface.beaconReceiver.beacon;",
    "connect beaconReceiver.detection to beaconDetected;",
    "connect motor.mechanicalOutput to gearbox.rotationalInput;",
    "connect gearbox.rotationalOutput to wheel.axle;",
    "connect base.cleaningHead.debrisOut to dustBin.debrisIn;",
    "connect hmi.control to hmiControl;"
)
foreach ($connection in $requiredPhysicalConnections) {
    if ($physicalText -notmatch [regex]::Escape($connection)) {
        Add-Failure "required physical connection is missing: $connection"
    }
}
foreach ($part in @("baseHarness", "topHarness")) {
    if ($physicalText -notmatch ("part\s+" + $part + "\s*:[^;]+:>>\s*" + $part + "\s*;")) {
        Add-Failure "required robot harness selection is missing: $part"
    }
}
if ($physicalText -match "(?m)^\s*port\s+hazard\s*:\s*GpioPort") {
    Add-Failure "independent safety signals must not be collapsed onto one generic GPIO net"
}

if ([regex]::Matches($purchasedPartsText, "@BuyPart\s*\{").Count -ne 6) {
    Add-Failure "PurchasedParts must contain exactly six BuyPart annotations"
}
foreach ($field in @(
    "manufacturer", "manufacturerPartNumber", "url"
)) {
    if ([regex]::Matches($purchasedPartsText, ("\b" + $field + "\s*=")).Count -ne 6) {
        Add-Failure "every BuyPart annotation must set '$field'"
    }
}

$firmwareText = $modelText
if ([regex]::Matches(
        $firmwareText,
        "part\s+def\s+\w+TaskSpecification\s*:>\s*(?:Periodic|EventDriven)FirmwareTask"
    ).Count -ne 7) {
    Add-Failure "FirmwareArchitecture must define exactly seven concrete firmware tasks"
}
foreach ($queue in @(
    "hazardQueue", "userCommandQueue", "plannerCommandQueue",
    "safetyCommandQueue", "mapUpdateQueue"
)) {
    if ($firmwareText -notmatch ("part\s+" + $queue + "\s*:")) {
        Add-Failure "runtime queue '$queue' is missing"
    }
    if ($firmwareText -notmatch ([regex]::Escape($queue) + "\.messages\.input")) {
        Add-Failure "runtime queue '$queue' has no typed producer flow"
    }
    if ($firmwareText -notmatch ([regex]::Escape($queue) + "\.messages\.output")) {
        Add-Failure "runtime queue '$queue' has no typed consumer flow"
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Model guards passed: physical paths, purchased parts, runtime queues, and traceability are clean."
