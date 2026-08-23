param(
    [string]$MatrixPath = (Join-Path $PSScriptRoot '..\versions\support-matrix.json'),
    [switch]$VerifyMaven,
    [string]$CarpetMavenMetadataUrl = 'https://masa.dy.fi/maven/carpet/fabric-carpet/maven-metadata.xml'
)

$ErrorActionPreference = 'Stop'

$KnownStatuses = @('verified', 'released-legacy', 'planned')
$KnownRules = @(
    'boneMealGrassifyDirt',
    'renewableLeavesCrafting',
    'renewableHoneycombCrafting',
    'renewableCalcite',
    'renewableTuff',
    'renewableLapisOre',
    'renewableRawOresCrafting',
    'pistonHarvestableAmethysts',
    'obsidianHardnessReinforcedDeepslate',
    'silkTouchableReinforcedDeepslate',
    'wardensDropReinforcedDeepslate'
)
$KnownLeafVariants = @(
    'oak',
    'spruce',
    'birch',
    'jungle',
    'acacia',
    'dark_oak',
    'mangrove',
    'cherry',
    'pale_oak'
)
$RuleMinimumTargets = @{
    boneMealGrassifyDirt = '1.14.4'
    renewableLeavesCrafting = '1.14.4'
    renewableHoneycombCrafting = '1.15'
    renewableCalcite = '1.17'
    renewableTuff = '1.17'
    renewableLapisOre = '1.17'
    renewableRawOresCrafting = '1.17'
    pistonHarvestableAmethysts = '1.17'
    obsidianHardnessReinforcedDeepslate = '1.19'
    silkTouchableReinforcedDeepslate = '1.19'
    wardensDropReinforcedDeepslate = '1.19'
}
$LeafMinimumTargets = @{
    oak = '1.14.4'
    spruce = '1.14.4'
    birch = '1.14.4'
    jungle = '1.14.4'
    acacia = '1.14.4'
    dark_oak = '1.14.4'
    mangrove = '1.19'
    cherry = '1.20'
    pale_oak = '1.21.4'
}
$KnownSourceFamilies = @(
    'yarn-1.14',
    'yarn-1.15',
    'yarn-1.16',
    'yarn-1.17',
    'yarn-1.18',
    'yarn-1.19',
    'yarn-1.20.1',
    'yarn-1.20.2-plus',
    'yarn-1.21.1',
    'yarn-1.21.2-plus',
    'yarn-1.21.8',
    'yarn-1.21.11',
    'mojang-26'
)
$ExpectedTargets = @(
    '1.14.4',
    '1.15',
    '1.15.1',
    '1.15.2',
    '1.16',
    '1.16.2',
    '1.16.3',
    '1.16.4',
    '1.16.5',
    '1.17',
    '1.17.1',
    '1.18',
    '1.18.1',
    '1.18.2',
    '1.19',
    '1.19.1',
    '1.19.2',
    '1.19.3',
    '1.19.4',
    '1.20',
    '1.20.2',
    '1.20.3',
    '1.20.5',
    '1.20.6',
    '1.21',
    '1.21.2',
    '1.21.4',
    '1.21.5',
    '1.21.6',
    '1.21.7',
    '1.21.9',
    '1.21.10',
    '1.21.11',
    '26.1',
    '26.2'
)
$ExpectedMinecraftVersions = @(
    '1.14.4',
    '1.15',
    '1.15.1',
    '1.15.2',
    '1.16',
    '1.16.2',
    '1.16.3',
    '1.16.4',
    '1.16.5',
    '1.17',
    '1.17.1',
    '1.18',
    '1.18.1',
    '1.18.2',
    '1.19',
    '1.19.1',
    '1.19.2',
    '1.19.3',
    '1.19.4',
    '1.20',
    '1.20.1',
    '1.20.2',
    '1.20.3',
    '1.20.4',
    '1.20.5',
    '1.20.6',
    '1.21',
    '1.21.1',
    '1.21.2',
    '1.21.3',
    '1.21.4',
    '1.21.5',
    '1.21.6',
    '1.21.7',
    '1.21.8',
    '1.21.9',
    '1.21.10',
    '1.21.11',
    '26.1',
    '26.1.1',
    '26.1.2',
    '26.2'
)

$Errors = New-Object 'System.Collections.Generic.List[string]'

function Add-ValidationError {
    param([string]$Message)
    $Errors.Add($Message)
}

function Convert-ToTargetVersion {
    param([string]$Target)

    $parts = @($Target.Split('.') | ForEach-Object { [int]$_ })
    while ($parts.Count -lt 3) {
        $parts += 0
    }
    return [version]("{0}.{1}.{2}" -f $parts[0], $parts[1], $parts[2])
}

function Test-SetEquality {
    param(
        [object[]]$Actual,
        [object[]]$Expected
    )

    $difference = @(Compare-Object -ReferenceObject @($Expected) -DifferenceObject @($Actual))
    return $difference.Count -eq 0
}

function Assert-KnownUniqueValues {
    param(
        [string]$Context,
        [object[]]$Values,
        [string[]]$KnownValues
    )

    $strings = @($Values | ForEach-Object { [string]$_ })
    $duplicates = @($strings | Group-Object | Where-Object Count -gt 1 | ForEach-Object Name)
    foreach ($duplicate in $duplicates) {
        Add-ValidationError "$Context contains duplicate value '$duplicate'."
    }
    foreach ($value in $strings) {
        if ($KnownValues -notcontains $value) {
            Add-ValidationError "$Context contains unknown value '$value'."
        }
    }
}

function Get-ExpectedJavaVersion {
    param([version]$TargetVersion)

    if ($TargetVersion -ge (Convert-ToTargetVersion '26.1')) { return 25 }
    if ($TargetVersion -ge (Convert-ToTargetVersion '1.20.5')) { return 21 }
    if ($TargetVersion -ge (Convert-ToTargetVersion '1.18')) { return 17 }
    if ($TargetVersion -ge (Convert-ToTargetVersion '1.17')) { return 16 }
    return 8
}

try {
    $resolvedMatrixPath = (Resolve-Path -LiteralPath $MatrixPath).Path
    $matrix = Get-Content -LiteralPath $resolvedMatrixPath -Raw | ConvertFrom-Json
} catch {
    Write-Error "Unable to parse version matrix '$MatrixPath': $($_.Exception.Message)"
    exit 1
}

if ($matrix.schemaVersion -ne 2) {
    Add-ValidationError "schemaVersion must be 2."
}

$tiers = @($matrix.capabilityTiers)
$targets = @($matrix.targets)
if ($tiers.Count -eq 0) {
    Add-ValidationError 'capabilityTiers must not be empty.'
}
if ($targets.Count -eq 0) {
    Add-ValidationError 'targets must not be empty.'
}

$tierById = @{}
$previousTierVersion = $null
$previousTierRules = @()
$previousTierLeaves = @()

foreach ($tier in $tiers) {
    $tierId = [string]$tier.id
    if ([string]::IsNullOrWhiteSpace($tierId)) {
        Add-ValidationError 'Every capability tier requires a non-empty id.'
        continue
    }
    if ($tierById.ContainsKey($tierId)) {
        Add-ValidationError "Duplicate capability tier id '$tierId'."
        continue
    }

    try {
        $tierVersion = Convert-ToTargetVersion ([string]$tier.minimumTarget)
    } catch {
        Add-ValidationError "Capability tier '$tierId' has invalid minimumTarget '$($tier.minimumTarget)'."
        continue
    }

    if ($null -ne $previousTierVersion -and $tierVersion -le $previousTierVersion) {
        Add-ValidationError "Capability tier '$tierId' is not in strictly increasing version order."
    }

    $tierRules = @($tier.availableRules | ForEach-Object { [string]$_ })
    $tierLeaves = @($tier.leafRecipeVariants | ForEach-Object { [string]$_ })
    Assert-KnownUniqueValues "Capability tier '$tierId' rules" $tierRules $KnownRules
    Assert-KnownUniqueValues "Capability tier '$tierId' leaves" $tierLeaves $KnownLeafVariants

    $expectedTierRules = @($KnownRules | Where-Object {
        $tierVersion -ge (Convert-ToTargetVersion $RuleMinimumTargets[$_])
    })
    if (-not (Test-SetEquality $tierRules $expectedTierRules)) {
        $missingRules = @($expectedTierRules | Where-Object { $tierRules -notcontains $_ })
        $prematureRules = @($tierRules | Where-Object {
            $tierVersion -lt (Convert-ToTargetVersion $RuleMinimumTargets[$_])
        })
        if ($missingRules.Count -gt 0) {
            Add-ValidationError "Capability tier '$tierId' is missing required rules: $($missingRules -join ', ')."
        }
        if ($prematureRules.Count -gt 0) {
            Add-ValidationError "Capability tier '$tierId' enables rules before their prerequisites: $($prematureRules -join ', ')."
        }
    }

    $expectedTierLeaves = @($KnownLeafVariants | Where-Object {
        $tierVersion -ge (Convert-ToTargetVersion $LeafMinimumTargets[$_])
    })
    if (-not (Test-SetEquality $tierLeaves $expectedTierLeaves)) {
        $missingLeaves = @($expectedTierLeaves | Where-Object { $tierLeaves -notcontains $_ })
        $prematureLeaves = @($tierLeaves | Where-Object {
            $tierVersion -lt (Convert-ToTargetVersion $LeafMinimumTargets[$_])
        })
        if ($missingLeaves.Count -gt 0) {
            Add-ValidationError "Capability tier '$tierId' is missing required leaf variants: $($missingLeaves -join ', ')."
        }
        if ($prematureLeaves.Count -gt 0) {
            Add-ValidationError "Capability tier '$tierId' enables leaf variants before their prerequisites: $($prematureLeaves -join ', ')."
        }
    }

    foreach ($rule in $previousTierRules) {
        if ($tierRules -notcontains $rule) {
            Add-ValidationError "Capability tier '$tierId' removes earlier rule '$rule'."
        }
    }
    foreach ($leaf in $previousTierLeaves) {
        if ($tierLeaves -notcontains $leaf) {
            Add-ValidationError "Capability tier '$tierId' removes earlier leaf variant '$leaf'."
        }
    }

    $tierById[$tierId] = @{
        Version = $tierVersion
        Rules = $tierRules
        Leaves = $tierLeaves
    }
    $previousTierVersion = $tierVersion
    $previousTierRules = $tierRules
    $previousTierLeaves = $tierLeaves
}

$actualTargets = @($targets | ForEach-Object { [string]$_.target })
if (-not (Test-SetEquality $actualTargets $ExpectedTargets)) {
    $missing = @($ExpectedTargets | Where-Object { $actualTargets -notcontains $_ })
    $unexpected = @($actualTargets | Where-Object { $ExpectedTargets -notcontains $_ })
    if ($missing.Count -gt 0) {
        Add-ValidationError "Stable target catalog is missing: $($missing -join ', ')."
    }
    if ($unexpected.Count -gt 0) {
        Add-ValidationError "Stable target catalog contains unexpected targets: $($unexpected -join ', ')."
    }
}

$actualMinecraftVersions = New-Object 'System.Collections.Generic.List[string]'
foreach ($target in $targets) {
    $targetName = [string]$target.target
    $coveredVersions = @(
        if ($target.PSObject.Properties.Name -contains 'minecraftVersions') {
            $target.minecraftVersions | ForEach-Object { [string]$_ }
        } else {
            $targetName
        }
    )

    if ($coveredVersions.Count -eq 0) {
        Add-ValidationError "Target '$targetName' must cover at least one Minecraft version."
        continue
    }
    if ($coveredVersions[0] -ne $targetName) {
        Add-ValidationError "Target '$targetName' must list its Carpet coordinate first in minecraftVersions."
    }

    $previousCoveredVersion = $null
    foreach ($coveredVersion in $coveredVersions) {
        try {
            $parsedCoveredVersion = Convert-ToTargetVersion $coveredVersion
        } catch {
            Add-ValidationError "Target '$targetName' covers invalid Minecraft version '$coveredVersion'."
            continue
        }
        if ($null -ne $previousCoveredVersion -and $parsedCoveredVersion -le $previousCoveredVersion) {
            Add-ValidationError "Target '$targetName' minecraftVersions must be unique and chronological."
        }
        $actualMinecraftVersions.Add($coveredVersion)
        $previousCoveredVersion = $parsedCoveredVersion
    }
}

$duplicateMinecraftVersions = @($actualMinecraftVersions | Group-Object | Where-Object Count -gt 1 | ForEach-Object Name)
foreach ($duplicate in $duplicateMinecraftVersions) {
    Add-ValidationError "Minecraft version '$duplicate' is covered by more than one Carpet target."
}
if (-not (Test-SetEquality @($actualMinecraftVersions) $ExpectedMinecraftVersions)) {
    $missingMinecraftVersions = @($ExpectedMinecraftVersions | Where-Object { $actualMinecraftVersions -notcontains $_ })
    $unexpectedMinecraftVersions = @($actualMinecraftVersions | Where-Object { $ExpectedMinecraftVersions -notcontains $_ })
    if ($missingMinecraftVersions.Count -gt 0) {
        Add-ValidationError "Minecraft coverage is missing: $($missingMinecraftVersions -join ', ')."
    }
    if ($unexpectedMinecraftVersions.Count -gt 0) {
        Add-ValidationError "Minecraft coverage contains unexpected versions: $($unexpectedMinecraftVersions -join ', ')."
    }
}

$seenTargets = @{}
$seenProfiles = @{}
$seenCarpetVersions = @{}
$previousTargetVersion = $null
$previousJava = 0
$previousRules = @()
$previousLeaves = @()

foreach ($target in $targets) {
    $targetName = [string]$target.target
    $profile = [string]$target.profile
    $context = "Target '$targetName'"

    if ([string]::IsNullOrWhiteSpace($targetName)) {
        Add-ValidationError 'Every target requires a non-empty target value.'
        continue
    }
    if ($seenTargets.ContainsKey($targetName)) {
        Add-ValidationError "Duplicate target '$targetName'."
    } else {
        $seenTargets[$targetName] = $true
    }
    if ([string]::IsNullOrWhiteSpace($profile)) {
        Add-ValidationError "$context requires a non-empty profile."
    } elseif ($seenProfiles.ContainsKey($profile)) {
        Add-ValidationError "Duplicate profile '$profile'."
    } else {
        $seenProfiles[$profile] = $true
    }

    try {
        $targetVersion = Convert-ToTargetVersion $targetName
    } catch {
        Add-ValidationError "$context is not a numeric stable version."
        continue
    }

    if ($null -ne $previousTargetVersion -and $targetVersion -le $previousTargetVersion) {
        Add-ValidationError "$context is not in strictly increasing chronological order."
    }

    $status = [string]$target.status
    if ($KnownStatuses -notcontains $status) {
        Add-ValidationError "$context has unknown status '$status'."
    }
    $sourceFamily = [string]$target.sourceFamily
    if ($KnownSourceFamilies -notcontains $sourceFamily) {
        Add-ValidationError "$context has unknown sourceFamily '$sourceFamily'."
    }
    if ([string]::IsNullOrWhiteSpace([string]$target.notes)) {
        Add-ValidationError "$context requires non-empty notes."
    }

    $carpetVersion = [string]$target.carpetVersion
    if ([string]::IsNullOrWhiteSpace($carpetVersion)) {
        Add-ValidationError "$context requires an exact carpetVersion."
    } else {
        if ($seenCarpetVersions.ContainsKey($carpetVersion)) {
            Add-ValidationError "Duplicate Carpet version '$carpetVersion'."
        } else {
            $seenCarpetVersions[$carpetVersion] = $true
        }
        $escapedTarget = [regex]::Escape($targetName)
        $coordinatePattern = if ($targetVersion -ge (Convert-ToTargetVersion '26.1')) {
            "^$escapedTarget\+v\d{6}$"
        } else {
            "^$escapedTarget-1\.\d+\.\d+\+v\d{6}$"
        }
        if ($carpetVersion -notmatch $coordinatePattern) {
            Add-ValidationError "$context has malformed Carpet coordinate '$carpetVersion'."
        }
    }

    $javaVersion = [int]$target.java
    $expectedJava = Get-ExpectedJavaVersion $targetVersion
    if ($javaVersion -ne $expectedJava) {
        Add-ValidationError "$context requires Java $expectedJava but declares Java $javaVersion."
    }
    if ($javaVersion -lt $previousJava) {
        Add-ValidationError "$context decreases the Java level from $previousJava to $javaVersion."
    }

    $tierId = [string]$target.capabilityTier
    if (-not $tierById.ContainsKey($tierId)) {
        Add-ValidationError "$context references unknown capability tier '$tierId'."
        $previousTargetVersion = $targetVersion
        $previousJava = $javaVersion
        continue
    }

    $selectedTier = $tierById[$tierId]
    if ($targetVersion -lt $selectedTier.Version) {
        Add-ValidationError "$context uses capability tier '$tierId' before its minimum target."
    }

    $expectedTierId = $null
    foreach ($candidate in $tiers) {
        $candidateId = [string]$candidate.id
        if ($tierById.ContainsKey($candidateId) -and $targetVersion -ge $tierById[$candidateId].Version) {
            $expectedTierId = $candidateId
        }
    }
    if ($tierId -ne $expectedTierId) {
        Add-ValidationError "$context should use latest applicable capability tier '$expectedTierId', not '$tierId'."
    }

    $rules = @($selectedTier.Rules)
    $leaves = @($selectedTier.Leaves)
    foreach ($rule in $previousRules) {
        if ($rules -notcontains $rule) {
            Add-ValidationError "$context loses earlier rule '$rule'."
        }
    }
    foreach ($leaf in $previousLeaves) {
        if ($leaves -notcontains $leaf) {
            Add-ValidationError "$context loses earlier leaf variant '$leaf'."
        }
    }

    if (($rules -contains 'renewableLeavesCrafting') -and $leaves.Count -eq 0) {
        Add-ValidationError "$context enables leaves crafting without leaf recipe variants."
    }
    if (($rules -notcontains 'renewableLeavesCrafting') -and $leaves.Count -gt 0) {
        Add-ValidationError "$context declares leaf recipes without renewableLeavesCrafting."
    }

    $reinforcedRules = @(
        'obsidianHardnessReinforcedDeepslate',
        'silkTouchableReinforcedDeepslate',
        'wardensDropReinforcedDeepslate'
    )
    $reinforcedCount = @($reinforcedRules | Where-Object { $rules -contains $_ }).Count
    if ($reinforcedCount -ne 0 -and $reinforcedCount -ne $reinforcedRules.Count) {
        Add-ValidationError "$context must add the reinforced-deepslate/Warden rule group atomically."
    }

    $previousTargetVersion = $targetVersion
    $previousJava = $javaVersion
    $previousRules = $rules
    $previousLeaves = $leaves
}

if ($targets.Count -gt 0) {
    if ([string]$targets[0].target -ne [string]$matrix.scope.minimumTarget) {
        Add-ValidationError 'scope.minimumTarget does not match the first target.'
    }
    if ([string]$targets[-1].target -ne [string]$matrix.scope.maximumTarget) {
        Add-ValidationError 'scope.maximumTarget does not match the last target.'
    }
}

if ($VerifyMaven) {
    try {
        $mavenResponse = Invoke-WebRequest -UseBasicParsing -Uri $CarpetMavenMetadataUrl
        $mavenMetadata = [xml]$mavenResponse.Content
        $publishedCarpetVersions = @($mavenMetadata.metadata.versioning.versions.version | ForEach-Object { [string]$_ })
        if ($publishedCarpetVersions.Count -eq 0) {
            throw 'Maven metadata contained no versions.'
        }

        foreach ($target in $targets) {
            $targetName = [string]$target.target
            $targetVersion = Convert-ToTargetVersion $targetName
            $stablePrefix = if ($targetVersion -ge (Convert-ToTargetVersion '26.1')) {
                '^' + [regex]::Escape($targetName) + '\+'
            } else {
                '^' + [regex]::Escape($targetName) + '-'
            }
            $publishedForTarget = @($publishedCarpetVersions | Where-Object { $_ -match $stablePrefix })
            if ($publishedForTarget.Count -eq 0) {
                Add-ValidationError "Official Carpet Maven has no stable artifact for target '$targetName'."
                continue
            }
            $latestPublished = $publishedForTarget[-1]
            if ([string]$target.carpetVersion -ne $latestPublished) {
                Add-ValidationError "Target '$targetName' pins '$($target.carpetVersion)' but official Maven latest is '$latestPublished'."
            }
        }
    } catch {
        Add-ValidationError "Unable to verify official Carpet Maven metadata: $($_.Exception.Message)"
    }
}

if ($Errors.Count -gt 0) {
    Write-Host "Version matrix validation failed with $($Errors.Count) error(s):" -ForegroundColor Red
    foreach ($message in $Errors) {
        Write-Host " - $message" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Version matrix is valid: $($targets.Count) stable Carpet targets, $($actualMinecraftVersions.Count) Minecraft versions, $($tiers.Count) capability tiers." -ForegroundColor Green
exit 0
