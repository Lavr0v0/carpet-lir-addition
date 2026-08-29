param(
    [string]$MatrixPath = (Join-Path $PSScriptRoot '..\versions\support-matrix.json'),
    [string]$ProfilesPath,
    [switch]$VerifyMaven,
    [switch]$VerifyArtifactMetadata,
    [string]$CarpetMavenMetadataUrl = 'https://masa.dy.fi/maven/carpet/fabric-carpet/maven-metadata.xml'
)

$ErrorActionPreference = 'Stop'

$KnownStatuses = @('verified', 'build-only', 'released-legacy', 'planned')
$KnownRules = @(
    'boneMealGrassifyDirt',
    'renewableLeavesCrafting',
    'renewableHoneycombCrafting',
    'renewableCalcite',
    'renewableCinnabar',
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
$KnownRecipes = @(
    'acacia_leaves_from_acacia_log_and_sticks',
    'birch_leaves_from_birch_log_and_sticks',
    'cherry_leaves_from_cherry_log_and_sticks',
    'dark_oak_leaves_from_dark_oak_log_and_sticks',
    'gravel_to_tuff_smelting',
    'honeycomb_from_honeycomb_block',
    'jungle_leaves_from_jungle_log_and_sticks',
    'lapis_ore_from_calcite_and_amethyst_shard',
    'mangrove_leaves_from_mangrove_log_and_sticks',
    'oak_leaves_from_oak_log_and_sticks',
    'pale_oak_leaves_from_pale_oak_log_and_sticks',
    'raw_copper_from_cobblestone_and_copper_ingot',
    'raw_gold_from_cobblestone_and_gold_ingot',
    'raw_iron_from_cobblestone_and_iron_ingot',
    'spruce_leaves_from_spruce_log_and_sticks'
)
$RuleMinimumTargets = @{
    boneMealGrassifyDirt = '1.14.4'
    renewableLeavesCrafting = '1.14.4'
    renewableHoneycombCrafting = '1.15'
    renewableCalcite = '1.17'
    renewableCinnabar = '26.2'
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
$RecipeMinimumTargets = @{
    acacia_leaves_from_acacia_log_and_sticks = '1.14.4'
    birch_leaves_from_birch_log_and_sticks = '1.14.4'
    cherry_leaves_from_cherry_log_and_sticks = '1.20'
    dark_oak_leaves_from_dark_oak_log_and_sticks = '1.14.4'
    gravel_to_tuff_smelting = '1.17'
    honeycomb_from_honeycomb_block = '1.15'
    jungle_leaves_from_jungle_log_and_sticks = '1.14.4'
    lapis_ore_from_calcite_and_amethyst_shard = '1.17'
    mangrove_leaves_from_mangrove_log_and_sticks = '1.19'
    oak_leaves_from_oak_log_and_sticks = '1.14.4'
    pale_oak_leaves_from_pale_oak_log_and_sticks = '1.21.4'
    raw_copper_from_cobblestone_and_copper_ingot = '1.17'
    raw_gold_from_cobblestone_and_gold_ingot = '1.17'
    raw_iron_from_cobblestone_and_iron_ingot = '1.17'
    spruce_leaves_from_spruce_log_and_sticks = '1.14.4'
}
$RecipeRuleMap = @{
    acacia_leaves_from_acacia_log_and_sticks = 'renewableLeavesCrafting'
    birch_leaves_from_birch_log_and_sticks = 'renewableLeavesCrafting'
    cherry_leaves_from_cherry_log_and_sticks = 'renewableLeavesCrafting'
    dark_oak_leaves_from_dark_oak_log_and_sticks = 'renewableLeavesCrafting'
    gravel_to_tuff_smelting = 'renewableTuff'
    honeycomb_from_honeycomb_block = 'renewableHoneycombCrafting'
    jungle_leaves_from_jungle_log_and_sticks = 'renewableLeavesCrafting'
    lapis_ore_from_calcite_and_amethyst_shard = 'renewableLapisOre'
    mangrove_leaves_from_mangrove_log_and_sticks = 'renewableLeavesCrafting'
    oak_leaves_from_oak_log_and_sticks = 'renewableLeavesCrafting'
    pale_oak_leaves_from_pale_oak_log_and_sticks = 'renewableLeavesCrafting'
    raw_copper_from_cobblestone_and_copper_ingot = 'renewableRawOresCrafting'
    raw_gold_from_cobblestone_and_gold_ingot = 'renewableRawOresCrafting'
    raw_iron_from_cobblestone_and_iron_ingot = 'renewableRawOresCrafting'
    spruce_leaves_from_spruce_log_and_sticks = 'renewableLeavesCrafting'
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
    'yarn-1.21.9-1.21.10',
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
    '1.16.1',
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

if ([string]::IsNullOrWhiteSpace($ProfilesPath)) {
    $ProfilesPath = Join-Path (Split-Path -Parent $resolvedMatrixPath) 'targets'
}
try {
    $resolvedProfilesPath = (Resolve-Path -LiteralPath $ProfilesPath).Path
} catch {
    Write-Error "Unable to resolve active profile directory '$ProfilesPath': $($_.Exception.Message)"
    exit 1
}

if ($matrix.schemaVersion -ne 4) {
    Add-ValidationError "schemaVersion must be 4."
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
$previousTierRecipes = @()

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
    $tierRecipes = @($tier.availableRecipes | ForEach-Object { [string]$_ })
    Assert-KnownUniqueValues "Capability tier '$tierId' rules" $tierRules $KnownRules
    Assert-KnownUniqueValues "Capability tier '$tierId' leaves" $tierLeaves $KnownLeafVariants
    Assert-KnownUniqueValues "Capability tier '$tierId' recipes" $tierRecipes $KnownRecipes

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

    $expectedTierRecipes = @($KnownRecipes | Where-Object {
        $tierVersion -ge (Convert-ToTargetVersion $RecipeMinimumTargets[$_])
    })
    if (-not (Test-SetEquality $tierRecipes $expectedTierRecipes)) {
        $missingRecipes = @($expectedTierRecipes | Where-Object { $tierRecipes -notcontains $_ })
        $prematureRecipes = @($tierRecipes | Where-Object {
            $tierVersion -lt (Convert-ToTargetVersion $RecipeMinimumTargets[$_])
        })
        if ($missingRecipes.Count -gt 0) {
            Add-ValidationError "Capability tier '$tierId' is missing required recipes: $($missingRecipes -join ', ')."
        }
        if ($prematureRecipes.Count -gt 0) {
            Add-ValidationError "Capability tier '$tierId' enables recipes before their prerequisites: $($prematureRecipes -join ', ')."
        }
    }
    foreach ($recipe in $tierRecipes) {
        $guardRule = $RecipeRuleMap[$recipe]
        if ($tierRules -notcontains $guardRule) {
            Add-ValidationError "Capability tier '$tierId' includes recipe '$recipe' without guard rule '$guardRule'."
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
    foreach ($recipe in $previousTierRecipes) {
        if ($tierRecipes -notcontains $recipe) {
            Add-ValidationError "Capability tier '$tierId' removes earlier recipe '$recipe'."
        }
    }

    $tierById[$tierId] = @{
        Version = $tierVersion
        Rules = $tierRules
        Leaves = $tierLeaves
        Recipes = $tierRecipes
    }
    $previousTierVersion = $tierVersion
    $previousTierRules = $tierRules
    $previousTierLeaves = $tierLeaves
    $previousTierRecipes = $tierRecipes
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
$seenCarpetArtifacts = @{}
$previousTargetVersion = $null
$previousJava = 0
$previousRules = @()
$previousLeaves = @()
$previousRecipes = @()

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

    $carpetArtifact = [string]$target.carpetArtifact
    $carpetModVersion = [string]$target.carpetModVersion
    if ([string]::IsNullOrWhiteSpace($carpetArtifact)) {
        Add-ValidationError "$context requires an exact carpetArtifact."
    } else {
        if ($seenCarpetArtifacts.ContainsKey($carpetArtifact)) {
            Add-ValidationError "Duplicate Carpet artifact '$carpetArtifact'."
        } else {
            $seenCarpetArtifacts[$carpetArtifact] = $true
        }
        $escapedTarget = [regex]::Escape($targetName)
        $coordinatePattern = if ($targetVersion -ge (Convert-ToTargetVersion '26.1')) {
            "^$escapedTarget\+v\d{6}$"
        } else {
            "^$escapedTarget-1\.\d+\.\d+\+v\d{6}$"
        }
        if ($carpetArtifact -notmatch $coordinatePattern) {
            Add-ValidationError "$context has malformed Carpet artifact '$carpetArtifact'."
        }
    }
    if ([string]::IsNullOrWhiteSpace($carpetModVersion)) {
        Add-ValidationError "$context requires an exact carpetModVersion."
    } elseif (-not [string]::IsNullOrWhiteSpace($carpetArtifact)) {
        if ($carpetModVersion -notmatch '^(?:1\.\d+\.\d+|26\.\d+)(?:\+v\d{6})?$') {
            Add-ValidationError "$context has malformed Carpet mod version '$carpetModVersion'."
        }
        $escapedModVersion = [regex]::Escape($carpetModVersion)
        $matchesArtifact = if ($targetVersion -ge (Convert-ToTargetVersion '26.1')) {
            $carpetArtifact -eq $carpetModVersion
        } else {
            $carpetArtifact -match "-$escapedModVersion(?:\+v\d{6})?$"
        }
        if (-not $matchesArtifact) {
            Add-ValidationError "$context Carpet mod version '$carpetModVersion' is inconsistent with artifact '$carpetArtifact'."
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
    $recipes = @($selectedTier.Recipes)
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
    foreach ($recipe in $previousRecipes) {
        if ($recipes -notcontains $recipe) {
            Add-ValidationError "$context loses earlier recipe '$recipe'."
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
    $previousRecipes = $recipes
}

if ($targets.Count -gt 0) {
    if ([string]$targets[0].target -ne [string]$matrix.scope.minimumTarget) {
        Add-ValidationError 'scope.minimumTarget does not match the first target.'
    }
    if ([string]$targets[-1].target -ne [string]$matrix.scope.maximumTarget) {
        Add-ValidationError 'scope.maximumTarget does not match the last target.'
    }
}

$targetByName = @{}
$targetByMinecraftVersion = @{}
foreach ($target in $targets) {
    $targetName = [string]$target.target
    $targetByName[$targetName] = $target
    $coveredVersions = @(
        if ($target.PSObject.Properties.Name -contains 'minecraftVersions') {
            $target.minecraftVersions | ForEach-Object { [string]$_ }
        } else {
            $targetName
        }
    )
    foreach ($coveredVersion in $coveredVersions) {
        $targetByMinecraftVersion[$coveredVersion] = $target
    }
}

$projectRoot = Split-Path -Parent (Split-Path -Parent $resolvedMatrixPath)
$profileFiles = @(Get-ChildItem -LiteralPath $resolvedProfilesPath -Filter '*.properties' -File)
$profileByMinecraftVersion = @{}
$requiredProfileKeys = @(
    'minecraft_version',
    'minecraft_dependency',
    'archive_minecraft_label',
    'loader_version',
    'fabric_api_version',
    'carpet_core_version',
    'loom_version',
    'source_family',
    'matrix_source_family',
    'java_version',
    'mappings_mode',
    'mixin_config',
    'matrix_target',
    'capability_tier',
    'support_status'
)
foreach ($profileFile in $profileFiles) {
    try {
        $profile = ConvertFrom-StringData (Get-Content -LiteralPath $profileFile.FullName -Raw)
    } catch {
        Add-ValidationError "Unable to parse active profile '$($profileFile.Name)': $($_.Exception.Message)"
        continue
    }

    $profileVersion = [string]$profile.minecraft_version
    $context = "Active profile '$($profileFile.Name)'"
    foreach ($key in $requiredProfileKeys) {
        if (-not $profile.ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$profile[$key])) {
            Add-ValidationError "$context requires '$key'."
        }
    }
    if ([string]::IsNullOrWhiteSpace($profileVersion)) {
        continue
    }
    if ($profileFile.BaseName -ne $profileVersion) {
        Add-ValidationError "$context filename must match minecraft_version '$profileVersion'."
    }
    if ($profileByMinecraftVersion.ContainsKey($profileVersion)) {
        Add-ValidationError "Minecraft $profileVersion has more than one active profile."
    } else {
        $profileByMinecraftVersion[$profileVersion] = $profile
    }
    if ([string]$profile.minecraft_dependency -ne $profileVersion) {
        Add-ValidationError "$context must declare an exact minecraft_dependency of '$profileVersion'."
    }
    if ([string]$profile.archive_minecraft_label -ne $profileVersion) {
        Add-ValidationError "$context must use exact archive_minecraft_label '$profileVersion'."
    }
    if ($profileVersion -eq '1.16') {
        $expectedFabricDependency = "=$([string]$profile.fabric_api_version)"
        if (-not $profile.ContainsKey('fabric_api_dependency') -or
                [string]$profile.fabric_api_dependency -ne $expectedFabricDependency) {
            Add-ValidationError "$context must pin fabric_api_dependency to '$expectedFabricDependency'; later nominal 1.16 aggregates link Minecraft 1.16.2-only classes."
        }
    }
    if ($profileVersion -in @('1.15', '1.15.1', '1.15.2')) {
        $expectedFabricDependency = "=$([string]$profile.fabric_api_version)"
        if (-not $profile.ContainsKey('fabric_api_dependency') -or
                [string]$profile.fabric_api_dependency -ne $expectedFabricDependency) {
            Add-ValidationError "$context must pin fabric_api_dependency to '$expectedFabricDependency'; 1.15 Fabric API module suffixes are mapping-generation-specific."
        }
    }

    $profileSourceFamily = [string]$profile.source_family
    if ($profileSourceFamily -notin @('legacy-yarn', 'mojang-26')) {
        Add-ValidationError "$context has unsupported source_family '$profileSourceFamily'."
    }
    $profileMappingsMode = [string]$profile.mappings_mode
    if (($profileSourceFamily -eq 'legacy-yarn' -and $profileMappingsMode -ne 'yarn') -or
            ($profileSourceFamily -eq 'mojang-26' -and $profileMappingsMode -ne 'mojang')) {
        Add-ValidationError "$context source_family '$profileSourceFamily' is incompatible with mappings_mode '$profileMappingsMode'."
    }
    if ($profileMappingsMode -eq 'yarn' -and
            (-not $profile.ContainsKey('yarn_mappings') -or [string]::IsNullOrWhiteSpace([string]$profile.yarn_mappings))) {
        Add-ValidationError "$context uses Yarn mappings but has no yarn_mappings coordinate."
    }

    $profileRecipeSchema = if ($profile.ContainsKey('recipe_schema')) {
        [string]$profile.recipe_schema
    } else {
        'modern-shorthand-result-id'
    }
    if ($profileRecipeSchema -notin @(
            'modern-shorthand-result-id',
            'ingredient-objects-result-id',
            'ingredient-objects-legacy-result'
    )) {
        Add-ValidationError "$context has unsupported recipe_schema '$profileRecipeSchema'."
    }
    $profileRecipeDirectory = if ($profile.ContainsKey('recipe_directory')) {
        [string]$profile.recipe_directory
    } else {
        'recipe'
    }
    if ($profileRecipeDirectory -notin @('recipe', 'recipes')) {
        Add-ValidationError "$context has unsupported recipe_directory '$profileRecipeDirectory'."
    }
    if ($profileVersion -in @('1.20.5', '1.20.6') -and
            ($profileRecipeSchema -ne 'ingredient-objects-result-id' -or $profileRecipeDirectory -ne 'recipes')) {
        Add-ValidationError "$context must use ingredient-objects-result-id in the plural recipes directory."
    }
    if ($profileVersion -in @(
            '1.15', '1.15.1', '1.15.2',
            '1.16', '1.16.1', '1.16.2', '1.16.3', '1.16.4', '1.16.5',
            '1.17', '1.17.1',
            '1.18', '1.18.1', '1.18.2',
            '1.19', '1.19.1', '1.19.2', '1.19.3', '1.19.4',
            '1.20', '1.20.1', '1.20.2', '1.20.3', '1.20.4'
    ) -and
            ($profileRecipeSchema -ne 'ingredient-objects-legacy-result' -or $profileRecipeDirectory -ne 'recipes')) {
        Add-ValidationError "$context must use ingredient-objects-legacy-result in the plural recipes directory."
    }
    if ($profileVersion -in @('1.21', '1.21.1') -and
            ($profileRecipeSchema -ne 'ingredient-objects-result-id' -or $profileRecipeDirectory -ne 'recipe')) {
        Add-ValidationError "$context must use ingredient-objects-result-id in the singular recipe directory."
    }
    if ((Convert-ToTargetVersion $profileVersion) -ge [version]'1.21.2' -and
            ($profileRecipeSchema -ne 'modern-shorthand-result-id' -or $profileRecipeDirectory -ne 'recipe')) {
        Add-ValidationError "$context must use modern-shorthand-result-id in the singular recipe directory."
    }

    $profileSupportStatus = [string]$profile.support_status
    if ($profileSupportStatus -notin @('verified', 'build-only')) {
        Add-ValidationError "$context must be verified or build-only before entering the active build profile directory."
    }
    if ([string]$profile.capability_tier -eq 'tier-1.15' -and
            (-not $profile.ContainsKey('rule_command_root') -or
            [string]$profile.rule_command_root -ne 'carpetlir')) {
        Add-ValidationError "$context tier-1.15 adapter must expose its extension-owned settings through rule_command_root 'carpetlir'."
    }

    if ($profileSourceFamily -eq 'legacy-yarn') {
        $sourceOverlayName = if ($profile.ContainsKey('source_overlay')) {
            [string]$profile.source_overlay
        } else {
            ''
        }
        if (-not $profile.ContainsKey('source_overlay') -or [string]::IsNullOrWhiteSpace([string]$profile.source_overlay)) {
            Add-ValidationError "$context requires source_overlay for legacy-yarn."
        } elseif ($sourceOverlayName -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
            Add-ValidationError "$context has unsafe source overlay '$sourceOverlayName'."
        } else {
            $overlayRoot = Join-Path $projectRoot "src\legacy\versioned\$sourceOverlayName"
            if (-not (Test-Path -LiteralPath (Join-Path $overlayRoot 'java') -PathType Container)) {
                Add-ValidationError "$context source overlay Java directory does not exist: '$overlayRoot\java'."
            }
        }
        $resourceOverlayName = if ($profile.ContainsKey('resource_overlay')) {
            [string]$profile.resource_overlay
        } else {
            $sourceOverlayName
        }
        if ([string]::IsNullOrWhiteSpace($resourceOverlayName) -or
                $resourceOverlayName -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
            Add-ValidationError "$context has unsafe or missing resource overlay '$resourceOverlayName'."
        } else {
            $resourceOverlayRoot = Join-Path $projectRoot "src\legacy\versioned\$resourceOverlayName\resources"
            if (-not (Test-Path -LiteralPath (Join-Path $resourceOverlayRoot ([string]$profile.mixin_config)) -PathType Leaf)) {
                Add-ValidationError "$context mixin config does not exist in resource overlay '$resourceOverlayName'."
            }
        }
        if ($profile.ContainsKey('shared_source_overlays')) {
            $sharedSourceOverlayNames = @([string]$profile.shared_source_overlays -split ',' | ForEach-Object {
                $_.Trim()
            } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
            foreach ($sharedSourceOverlayName in $sharedSourceOverlayNames) {
                if ($sharedSourceOverlayName -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
                    Add-ValidationError "$context has unsafe shared source overlay '$sharedSourceOverlayName'."
                    continue
                }
                $sharedSourceOverlayRoot = Join-Path $projectRoot "src\legacy\versioned\$sharedSourceOverlayName\java"
                if (-not (Test-Path -LiteralPath $sharedSourceOverlayRoot -PathType Container)) {
                    Add-ValidationError "$context shared source overlay does not exist: '$sharedSourceOverlayRoot'."
                }
            }
        }
        $compatibilityOverlayDefaults = @{
            settings_source_overlay = 'rule-categories'
            fluid_tag_source_overlay = 'fluid-tags-registry'
            feature_bootstrap_overlay = 'feature-bootstrap-reinforced'
        }
        foreach ($compatibilityOverlay in $compatibilityOverlayDefaults.GetEnumerator()) {
            $compatibilityOverlayName = if ($profile.ContainsKey($compatibilityOverlay.Key)) {
                [string]$profile[$compatibilityOverlay.Key]
            } else {
                [string]$compatibilityOverlay.Value
            }
            if ($compatibilityOverlayName -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
                Add-ValidationError "$context has unsafe $($compatibilityOverlay.Key) '$compatibilityOverlayName'."
                continue
            }
            $compatibilityOverlayRoot = Join-Path $projectRoot "src\legacy\versioned\$compatibilityOverlayName\java"
            if (-not (Test-Path -LiteralPath $compatibilityOverlayRoot -PathType Container)) {
                Add-ValidationError "$context $($compatibilityOverlay.Key) does not exist: '$compatibilityOverlayRoot'."
            }
        }
        $recipeApiOverlayName = if ($profile.ContainsKey('recipe_api_overlay')) {
            [string]$profile.recipe_api_overlay
        } else {
            'shared-modern'
        }
        if ($recipeApiOverlayName -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
            Add-ValidationError "$context has unsafe recipe API overlay '$recipeApiOverlayName'."
        } else {
            $recipeApiOverlayRoot = Join-Path $projectRoot "src\legacy\versioned\$recipeApiOverlayName\java"
            if (-not (Test-Path -LiteralPath $recipeApiOverlayRoot -PathType Container)) {
                Add-ValidationError "$context recipe API overlay does not exist: '$recipeApiOverlayRoot'."
            }
        }
    } elseif ($profileSourceFamily -eq 'mojang-26') {
        if (-not (Test-Path -LiteralPath (Join-Path $projectRoot "src\main\resources\$([string]$profile.mixin_config)") -PathType Leaf)) {
            Add-ValidationError "$context mixin config does not exist in the main resources."
        }
    }

    $matrixTargetName = [string]$profile.matrix_target
    if (-not $targetByName.ContainsKey($matrixTargetName)) {
        Add-ValidationError "$context references unknown matrix_target '$matrixTargetName'."
        continue
    }
    $matrixTarget = $targetByName[$matrixTargetName]
    if (-not $targetByMinecraftVersion.ContainsKey($profileVersion) -or
            [string]$targetByMinecraftVersion[$profileVersion].target -ne $matrixTargetName) {
        Add-ValidationError "$context maps Minecraft $profileVersion to '$matrixTargetName', but the matrix does not."
    }
    if ([int]$profile.java_version -ne [int]$matrixTarget.java) {
        Add-ValidationError "$context Java $($profile.java_version) does not match matrix Java $($matrixTarget.java)."
    }
    if ([string]$profile.capability_tier -ne [string]$matrixTarget.capabilityTier) {
        Add-ValidationError "$context capability tier '$($profile.capability_tier)' does not match matrix '$($matrixTarget.capabilityTier)'."
    }
    if ([string]$profile.matrix_source_family -ne [string]$matrixTarget.sourceFamily) {
        Add-ValidationError "$context matrix source family '$($profile.matrix_source_family)' does not match matrix '$($matrixTarget.sourceFamily)'."
    }
    if ($profileSupportStatus -ne [string]$matrixTarget.status) {
        Add-ValidationError "$context status '$profileSupportStatus' does not match matrix '$($matrixTarget.status)'."
    }
    if ([string]$profile.carpet_core_version -ne [string]$matrixTarget.carpetArtifact) {
        Add-ValidationError "$context Carpet artifact '$($profile.carpet_core_version)' does not match matrix '$($matrixTarget.carpetArtifact)'."
    }
    $profileCarpetModVersion = if ($profile.ContainsKey('carpet_mod_version')) {
        [string]$profile.carpet_mod_version
    } else {
        [string]$profile.carpet_core_version
    }
    if ($profileCarpetModVersion -ne [string]$matrixTarget.carpetModVersion) {
        Add-ValidationError "$context Carpet mod version '$profileCarpetModVersion' does not match matrix '$($matrixTarget.carpetModVersion)'."
    }
}

$classicRoot = Join-Path $projectRoot 'classic\1.14.4'
$classicProfilePath = Join-Path $classicRoot 'gradle.properties'
if (-not (Test-Path -LiteralPath $classicProfilePath -PathType Leaf)) {
    Add-ValidationError 'Verified classic target 1.14.4 has no isolated build profile.'
} else {
    $classicProfile = ConvertFrom-StringData (Get-Content -LiteralPath $classicProfilePath -Raw)
    $classicMatrixTarget = $targetByName['1.14.4']
    $classicChecks = @{
        minecraft_version = '1.14.4'
        minecraft_dependency = '1.14.4'
        archive_minecraft_label = '1.14.4'
        carpet_core_version = [string]$classicMatrixTarget.carpetArtifact
        carpet_mod_version = [string]$classicMatrixTarget.carpetModVersion
        java_version = [string]$classicMatrixTarget.java
        matrix_target = '1.14.4'
        matrix_source_family = [string]$classicMatrixTarget.sourceFamily
        capability_tier = [string]$classicMatrixTarget.capabilityTier
        support_status = [string]$classicMatrixTarget.status
        recipe_schema = 'ingredient-objects-legacy-result'
        recipe_directory = 'recipes'
    }
    foreach ($check in $classicChecks.GetEnumerator()) {
        if ([string]$classicProfile[$check.Key] -ne [string]$check.Value) {
            Add-ValidationError "Classic profile '$($check.Key)' is '$($classicProfile[$check.Key])', expected '$($check.Value)'."
        }
    }
}
foreach ($target in $targets) {
    if ([string]$target.status -notin @('verified', 'build-only')) {
        continue
    }
    $coveredVersions = @(
        if ($target.PSObject.Properties.Name -contains 'minecraftVersions') {
            $target.minecraftVersions | ForEach-Object { [string]$_ }
        } else {
            [string]$target.target
        }
    )
    foreach ($coveredVersion in $coveredVersions) {
        if ($coveredVersion -eq '1.14.4') {
            continue
        }
        if (-not $profileByMinecraftVersion.ContainsKey($coveredVersion)) {
            Add-ValidationError "Current $($target.status) Minecraft target '$coveredVersion' has no active exact build profile."
        }
    }
}

if ($VerifyMaven -or $VerifyArtifactMetadata) {
    try {
        $mavenResponse = Invoke-WebRequest -UseBasicParsing -Uri $CarpetMavenMetadataUrl
        $mavenMetadata = [xml]$mavenResponse.Content
        $mavenBaseUrl = $CarpetMavenMetadataUrl.Substring(0, $CarpetMavenMetadataUrl.LastIndexOf('/') + 1)
        $publishedCarpetVersions = @($mavenMetadata.metadata.versioning.versions.version | ForEach-Object { [string]$_ })
        if ($publishedCarpetVersions.Count -eq 0) {
            throw 'Maven metadata contained no versions.'
        }

        $officialStableTargets = @($publishedCarpetVersions | ForEach-Object {
            if ($_ -match '^(\d+\.\d+(?:\.\d+)?)\+') {
                $Matches[1]
            } elseif ($_ -match '^(\d+\.\d+(?:\.\d+)?)-\d+\.\d+') {
                $Matches[1]
            }
        } | Where-Object { $_ } | Select-Object -Unique)
        $missingOfficialTargets = @($officialStableTargets | Where-Object { $actualTargets -notcontains $_ })
        $nonOfficialTargets = @($actualTargets | Where-Object { $officialStableTargets -notcontains $_ })
        if ($missingOfficialTargets.Count -gt 0) {
            Add-ValidationError "Stable target catalog is stale; official Carpet Maven also contains: $($missingOfficialTargets -join ', ')."
        }
        if ($nonOfficialTargets.Count -gt 0) {
            Add-ValidationError "Stable target catalog contains targets absent from official Carpet Maven: $($nonOfficialTargets -join ', ')."
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
            if ([string]$target.carpetArtifact -ne $latestPublished) {
                Add-ValidationError "Target '$targetName' pins '$($target.carpetArtifact)' but official Maven latest is '$latestPublished'."
            }

            if ($VerifyArtifactMetadata) {
                Add-Type -AssemblyName System.IO.Compression
                $artifact = [string]$target.carpetArtifact
                $artifactUrl = "${mavenBaseUrl}${artifact}/fabric-carpet-${artifact}.jar"
                $artifactResponse = Invoke-WebRequest -UseBasicParsing -Uri $artifactUrl
                $artifactMemory = New-Object System.IO.MemoryStream
                $artifactZip = $null
                try {
                    $artifactResponse.RawContentStream.CopyTo($artifactMemory)
                    $artifactMemory.Position = 0
                    $artifactZip = New-Object System.IO.Compression.ZipArchive(
                            $artifactMemory,
                            [System.IO.Compression.ZipArchiveMode]::Read
                    )
                    $fabricMetadataEntry = $artifactZip.GetEntry('fabric.mod.json')
                    if ($null -eq $fabricMetadataEntry) {
                        Add-ValidationError "Official Carpet artifact '$artifact' has no fabric.mod.json."
                    } else {
                        $fabricMetadataReader = New-Object System.IO.StreamReader($fabricMetadataEntry.Open())
                        try {
                            $fabricMetadata = $fabricMetadataReader.ReadToEnd() | ConvertFrom-Json
                        } finally {
                            $fabricMetadataReader.Dispose()
                        }
                        if ([string]$fabricMetadata.version -ne [string]$target.carpetModVersion) {
                            Add-ValidationError "Target '$targetName' records Carpet mod version '$($target.carpetModVersion)' but official artifact declares '$($fabricMetadata.version)'."
                        }
                    }
                } finally {
                    if ($null -ne $artifactZip) {
                        $artifactZip.Dispose()
                    }
                    $artifactMemory.Dispose()
                }
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

Write-Host "Version matrix is valid: $($targets.Count) stable Carpet targets, $($actualMinecraftVersions.Count) Minecraft versions, $($tiers.Count) capability tiers, $($profileFiles.Count + 1) active exact build profiles." -ForegroundColor Green
exit 0
