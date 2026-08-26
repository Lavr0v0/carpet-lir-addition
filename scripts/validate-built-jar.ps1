param(
    [Parameter(Mandatory = $true)]
    [string]$JarPath,

    [Parameter(Mandatory = $true)]
    [string]$MinecraftVersion,

    [string]$MatrixPath,

    [string]$ProfilePath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($MatrixPath)) {
    $MatrixPath = Join-Path $PSScriptRoot '..\versions\support-matrix.json'
}

function Convert-ToTargetVersion {
    param([string]$Target)

    $parts = @($Target.Split('.') | ForEach-Object { [int]$_ })
    while ($parts.Count -lt 3) {
        $parts += 0
    }
    return [version]("{0}.{1}.{2}" -f $parts[0], $parts[1], $parts[2])
}

function Get-CoveredVersions {
    param([object]$Target)

    return @(
        if ($Target.PSObject.Properties.Name -contains 'minecraftVersions') {
            $Target.minecraftVersions | ForEach-Object { [string]$_ }
        } else {
            [string]$Target.target
        }
    )
}

function Get-ZipEntryText {
    param(
        [System.IO.Compression.ZipArchiveEntry]$Entry
    )

    $reader = New-Object System.IO.StreamReader($Entry.Open())
    try {
        return $reader.ReadToEnd()
    } finally {
        $reader.Dispose()
    }
}

function Get-ZipEntryBytes {
    param(
        [System.IO.Compression.ZipArchiveEntry]$Entry
    )

    $stream = $Entry.Open()
    $memory = New-Object System.IO.MemoryStream
    try {
        $stream.CopyTo($memory)
        return $memory.ToArray()
    } finally {
        $memory.Dispose()
        $stream.Dispose()
    }
}

function Assert-RecipeIngredientSchema {
    param(
        [AllowNull()]
        [object]$Ingredient,
        [string]$RecipeSchema,
        [string]$RecipePath
    )

    if ($Ingredient -is [System.Collections.IList]) {
        if ($Ingredient.Count -eq 0) {
            throw "Recipe '$RecipePath' must not use an empty ingredient alternative list."
        }
        foreach ($alternative in $Ingredient) {
            Assert-RecipeIngredientSchema `
                    -Ingredient $alternative `
                    -RecipeSchema $RecipeSchema `
                    -RecipePath $RecipePath
        }
        return
    }

    $isStringIngredient = $Ingredient -is [string]
    if ($RecipeSchema -eq 'modern-shorthand-result-id' -and
            (-not $isStringIngredient -or [string]::IsNullOrWhiteSpace([string]$Ingredient))) {
        throw "Recipe '$RecipePath' must use modern string ingredient shorthand."
    }
    if ($RecipeSchema -in @('ingredient-objects-result-id', 'ingredient-objects-legacy-result')) {
        $propertyNames = if ($null -eq $Ingredient) {
            @()
        } else {
            @($Ingredient.PSObject.Properties.Name)
        }
        $hasItem = $propertyNames -contains 'item' -and
                -not [string]::IsNullOrWhiteSpace([string]$Ingredient.item)
        $hasTag = $propertyNames -contains 'tag' -and
                -not [string]::IsNullOrWhiteSpace([string]$Ingredient.tag)
        if ($isStringIngredient -or $hasItem -eq $hasTag) {
            throw "Recipe '$RecipePath' must use an ingredient object with exactly one non-empty item or tag id."
        }
    }
}

function Test-VersionPredicate {
    param(
        [string]$Predicate,
        [version]$ActualVersion
    )

    if ([string]::IsNullOrWhiteSpace($Predicate) -or $Predicate.Trim() -eq '*') {
        return $false
    }

    foreach ($alternative in @($Predicate -split '\|\|')) {
        $matchesAlternative = $true
        $tokens = @($alternative.Replace(',', ' ').Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries))
        foreach ($token in $tokens) {
            if ($token -notmatch '^(>=|<=|>|<|=|~|\^)?(\d+(?:\.\d+){1,2})$') {
                throw "Unsupported Minecraft dependency token '$token'."
            }
            $operator = [string]$Matches[1]
            $requiredVersion = Convert-ToTargetVersion ([string]$Matches[2])
            $matchesToken = switch ($operator) {
                '>=' { $ActualVersion -ge $requiredVersion }
                '<=' { $ActualVersion -le $requiredVersion }
                '>' { $ActualVersion -gt $requiredVersion }
                '<' { $ActualVersion -lt $requiredVersion }
                '=' { $ActualVersion -eq $requiredVersion }
                '~' {
                    $upperBound = [version]("{0}.{1}.0" -f $requiredVersion.Major, ($requiredVersion.Minor + 1))
                    $ActualVersion -ge $requiredVersion -and $ActualVersion -lt $upperBound
                }
                '^' {
                    $upperBound = [version]("{0}.0.0" -f ($requiredVersion.Major + 1))
                    $ActualVersion -ge $requiredVersion -and $ActualVersion -lt $upperBound
                }
                default { $ActualVersion -eq $requiredVersion }
            }
            if (-not $matchesToken) {
                $matchesAlternative = $false
                break
            }
        }
        if ($matchesAlternative) {
            return $true
        }
    }
    return $false
}

$resolvedJar = (Resolve-Path -LiteralPath $JarPath).Path
$resolvedMatrix = (Resolve-Path -LiteralPath $MatrixPath).Path
$matrix = Get-Content -LiteralPath $resolvedMatrix -Raw | ConvertFrom-Json

$resolvedProfile = $null
if (-not [string]::IsNullOrWhiteSpace($ProfilePath)) {
    $resolvedProfile = (Resolve-Path -LiteralPath $ProfilePath).Path
} else {
    $projectRoot = Split-Path -Parent (Split-Path -Parent $resolvedMatrix)
    $profileCandidate = Join-Path $projectRoot "versions\targets\$MinecraftVersion.properties"
    if (Test-Path -LiteralPath $profileCandidate -PathType Leaf) {
        $resolvedProfile = (Resolve-Path -LiteralPath $profileCandidate).Path
    }
}
$profile = if ($null -ne $resolvedProfile) {
    ConvertFrom-StringData (Get-Content -LiteralPath $resolvedProfile -Raw)
} else {
    $null
}

$matchingTargets = @($matrix.targets | Where-Object {
    (Get-CoveredVersions $_) -contains $MinecraftVersion
})
if ($matchingTargets.Count -ne 1) {
    throw "Minecraft $MinecraftVersion maps to $($matchingTargets.Count) support-matrix targets; expected exactly one."
}
$target = $matchingTargets[0]
$tiers = @($matrix.capabilityTiers)
$matchingTiers = @($tiers | Where-Object { [string]$_.id -eq [string]$target.capabilityTier })
if ($matchingTiers.Count -ne 1) {
    throw "Target '$($target.target)' does not map to exactly one capability tier."
}
$tier = $matchingTiers[0]
$allRules = @($tiers[-1].availableRules | ForEach-Object { [string]$_ })
$expectedRules = @($tier.availableRules | ForEach-Object { [string]$_ })
$expectedRecipes = @($tier.availableRecipes | ForEach-Object { [string]$_ } | Sort-Object)
$targetVersion = Convert-ToTargetVersion $MinecraftVersion
$recipeSchema = if ($null -ne $profile -and $profile.ContainsKey('recipe_schema')) {
    [string]$profile.recipe_schema
} else {
    'modern-shorthand-result-id'
}
if ($recipeSchema -notin @(
        'modern-shorthand-result-id',
        'ingredient-objects-result-id',
        'ingredient-objects-legacy-result'
)) {
    throw "Unsupported recipe schema '$recipeSchema' in profile '$resolvedProfile'."
}
$recipeDirectory = if ($null -ne $profile -and $profile.ContainsKey('recipe_directory')) {
    [string]$profile.recipe_directory
} else {
    'recipe'
}
if ($recipeDirectory -notin @('recipe', 'recipes')) {
    throw "Unsupported recipe directory '$recipeDirectory' in profile '$resolvedProfile'."
}

$forbiddenBefore = @{
    'org/lavro/carpetlir/features/renewable/CalciteGeneratorFeature.class' = '1.17'
    'org/lavro/carpetlir/features/renewable/PistonHarvestableAmethystFeature.class' = '1.17'
    'org/lavro/carpetlir/helpers/PistonHarvestContext.class' = '1.17'
    'org/lavro/carpetlir/mixins/BlockMixin.class' = '1.17'
    'org/lavro/carpetlir/mixins/FluidBlockMixin.class' = '1.17'
    'org/lavro/carpetlir/mixins/PistonBlockMixin.class' = '1.17'
    'org/lavro/carpetlir/mixins/PistonMoveMixin.class' = '1.17'
    'org/lavro/carpetlir/features/renewable/ReinforcedDeepslateFeature.class' = '1.19'
    'org/lavro/carpetlir/mixins/AbstractBlockStateMixin.class' = '1.19'
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($resolvedJar)
try {
    $metadataEntry = $zip.GetEntry('fabric.mod.json')
    if ($null -eq $metadataEntry) {
        throw 'Release JAR has no fabric.mod.json.'
    }
    $metadata = Get-ZipEntryText $metadataEntry | ConvertFrom-Json
    if ([string]$metadata.id -ne 'carpetlir') {
        throw "Release JAR has unexpected mod id '$($metadata.id)'."
    }
    if ([string]::IsNullOrWhiteSpace([string]$metadata.version) -or [string]$metadata.version -match '\$\{') {
        throw "Release JAR has unresolved or empty mod version '$($metadata.version)'."
    }
    $minecraftDependencies = @($metadata.depends.minecraft | ForEach-Object { [string]$_ })
    $boundedMinecraftDependencies = @($minecraftDependencies | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_) -and $_.Trim() -ne '*'
    })
    if ($boundedMinecraftDependencies.Count -eq 0 -or -not @($boundedMinecraftDependencies | Where-Object {
        Test-VersionPredicate $_ $targetVersion
    }).Count) {
        throw "Release JAR must declare a bounded Minecraft dependency covering $MinecraftVersion; found '$($minecraftDependencies -join ', ')'."
    }
    $loaderDependency = [string]$metadata.depends.fabricloader
    if ([string]::IsNullOrWhiteSpace($loaderDependency) -or $loaderDependency -eq '*') {
        throw 'Release JAR must declare a bounded fabricloader dependency.'
    }
    $fabricDependencyIds = @(@('fabric-api', 'fabric') | Where-Object {
        $null -ne $metadata.depends.PSObject.Properties[$_]
    })
    if ($fabricDependencyIds.Count -ne 1) {
        throw "Release JAR must declare exactly one Fabric API dependency id; found '$($fabricDependencyIds -join ', ')'."
    }
    $fabricDependencyId = $fabricDependencyIds[0]
    $fabricDependency = [string]$metadata.depends.PSObject.Properties[$fabricDependencyId].Value
    if ([string]::IsNullOrWhiteSpace($fabricDependency) -or $fabricDependency -eq '*') {
        throw "Release JAR must declare a bounded Fabric API dependency using the target generation's mod id."
    }
    $carpetDependency = [string]$metadata.depends.carpet
    if ([string]::IsNullOrWhiteSpace($carpetDependency) -or $carpetDependency -eq '*') {
        throw 'Release JAR must declare a bounded Fabric Carpet dependency.'
    }
    $escapedCarpetModVersion = [regex]::Escape([string]$target.carpetModVersion)
    $carpetDependencyTokens = @($carpetDependency.Replace(',', ' ').Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries))
    $matchingRuntimeTokens = @($carpetDependencyTokens | Where-Object {
        $_ -match "^(?:=|>=|<=|~|\^)?$escapedCarpetModVersion$"
    })
    if ($matchingRuntimeTokens.Count -eq 0) {
        throw "Release JAR Carpet dependency '$carpetDependency' does not target runtime mod version '$($target.carpetModVersion)'."
    }

    if ($null -ne $profile) {
        $expectedMinecraftDependency = [string]$profile.minecraft_dependency
        $expectedLoaderDependency = if ($profile.ContainsKey('loader_dependency')) {
            [string]$profile.loader_dependency
        } else {
            ">=$([string]$profile.loader_version)"
        }
        $expectedFabricDependencyId = if ($profile.ContainsKey('fabric_api_mod_id')) {
            [string]$profile.fabric_api_mod_id
        } else {
            'fabric-api'
        }
        $expectedFabricDependency = if ($profile.ContainsKey('fabric_api_dependency')) {
            [string]$profile.fabric_api_dependency
        } else {
            ">=$([string]$profile.fabric_api_version)"
        }
        $profileCarpetModVersion = if ($profile.ContainsKey('carpet_mod_version')) {
            [string]$profile.carpet_mod_version
        } else {
            [string]$profile.carpet_core_version
        }
        $expectedCarpetDependency = if ($profile.ContainsKey('carpet_dependency')) {
            [string]$profile.carpet_dependency
        } else {
            ">=$profileCarpetModVersion"
        }

        if ($profile.ContainsKey('archive_minecraft_label')) {
            $expectedJarPrefix = "carpet-lir-addition-mc$([string]$profile.archive_minecraft_label)-"
            $actualJarName = [System.IO.Path]::GetFileName($resolvedJar)
            if (-not $actualJarName.StartsWith($expectedJarPrefix, [System.StringComparison]::Ordinal)) {
                throw "Release JAR name '$actualJarName' does not start with profile prefix '$expectedJarPrefix'."
            }
        }

        if ($minecraftDependencies.Count -ne 1 -or $minecraftDependencies[0] -ne $expectedMinecraftDependency) {
            throw "Release JAR Minecraft dependency '$($minecraftDependencies -join ', ')' does not match profile '$expectedMinecraftDependency'."
        }
        if ($loaderDependency -ne $expectedLoaderDependency) {
            throw "Release JAR fabricloader dependency '$loaderDependency' does not match profile '$expectedLoaderDependency'."
        }
        if ($fabricDependencyId -ne $expectedFabricDependencyId -or $fabricDependency -ne $expectedFabricDependency) {
            throw "Release JAR Fabric API dependency '${fabricDependencyId}: $fabricDependency' does not match profile '${expectedFabricDependencyId}: $expectedFabricDependency'."
        }
        if ($carpetDependency -ne $expectedCarpetDependency) {
            throw "Release JAR Carpet dependency '$carpetDependency' does not match profile '$expectedCarpetDependency'."
        }

        $profileName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedProfile)
        $expectedTargetProfile = if ($profile.ContainsKey('target_profile')) {
            [string]$profile.target_profile
        } elseif ($profileName -eq $MinecraftVersion) {
            $MinecraftVersion
        } else {
            $null
        }
        if ($null -ne $expectedTargetProfile) {
            $actualTargetProfile = [string]$metadata.custom.'carpetlir:build'.target_profile
            if ($actualTargetProfile -ne $expectedTargetProfile) {
                throw "Release JAR target-profile metadata '$actualTargetProfile' does not match profile '$expectedTargetProfile'."
            }
        }
    }

    $testEntries = @($zip.Entries | Where-Object {
        $_.FullName -like '*GameTest*' -or $_.FullName -like '*/gametest/*'
    })
    if ($testEntries.Count -ne 0) {
        throw 'Release JAR contains GameTest classes or resources.'
    }

    $settingsEntry = $zip.GetEntry('org/lavro/carpetlir/LIRSettings.class')
    if ($null -eq $settingsEntry) {
        throw 'Release JAR has no LIRSettings.class.'
    }
    $settingsText = [System.Text.Encoding]::UTF8.GetString((Get-ZipEntryBytes $settingsEntry))
    $isLegacyYarnProfile = $null -ne $profile -and [string]$profile.source_family -eq 'legacy-yarn'
    if ($isLegacyYarnProfile) {
        $settingsSourceOverlay = if ($profile.ContainsKey('settings_source_overlay')) {
            [string]$profile.settings_source_overlay
        } else {
            'rule-categories'
        }
        $expectedRuleAnnotation = switch ($settingsSourceOverlay) {
            'rule-category' { 'carpet/settings/Rule' }
            'rule-categories' { 'carpet/api/settings/Rule' }
            default { throw "Unsupported settings source overlay '$settingsSourceOverlay'." }
        }
        $unexpectedRuleAnnotation = if ($expectedRuleAnnotation -eq 'carpet/settings/Rule') {
            'carpet/api/settings/Rule'
        } else {
            'carpet/settings/Rule'
        }
        if (-not $settingsText.Contains($expectedRuleAnnotation) -or
                $settingsText.Contains($unexpectedRuleAnnotation)) {
            throw "LIRSettings does not use only the rule annotation selected by '$settingsSourceOverlay'."
        }

        $fluidBlockMixinEntry = $zip.GetEntry('org/lavro/carpetlir/mixins/FluidBlockMixin.class')
        $fluidTagCompatibilityEntry = $zip.GetEntry('org/lavro/carpetlir/helpers/FluidTagCompatibility.class')
        if ($null -eq $fluidBlockMixinEntry -or $null -eq $fluidTagCompatibilityEntry -or
                -not [System.Text.Encoding]::UTF8.GetString(
                        (Get-ZipEntryBytes $fluidBlockMixinEntry)
                ).Contains('FluidTagCompatibility')) {
            throw 'Legacy Yarn JAR does not retain the selected FluidTags compatibility adapter.'
        }
    }
    $initializerEntry = $zip.GetEntry('org/lavro/carpetlir/CarpetLIRAddition.class')
    if ($null -eq $initializerEntry) {
        throw 'Release JAR has no CarpetLIRAddition.class.'
    }
    $initializerText = [System.Text.Encoding]::UTF8.GetString((Get-ZipEntryBytes $initializerEntry))
    if ($initializerText.Contains('${version}')) {
        throw 'Release JAR initializer contains an unresolved version placeholder.'
    }
    foreach ($rule in $allRules) {
        $isPresent = $settingsText.Contains($rule)
        $isExpected = $expectedRules -contains $rule
        if ($isPresent -ne $isExpected) {
            $expectation = if ($isExpected) { 'present' } else { 'absent' }
            throw "Rule field '$rule' must be $expectation for Minecraft $MinecraftVersion."
        }
    }

    $recipeEntries = @($zip.Entries | Where-Object {
        $_.FullName -match '^data/carpetlir/recipes?/[^/]+\.json$'
    })
    $expectedRecipePrefix = "data/carpetlir/$recipeDirectory/"
    $wrongDirectoryEntries = @($recipeEntries | Where-Object {
        -not $_.FullName.StartsWith($expectedRecipePrefix, [System.StringComparison]::Ordinal)
    })
    if ($wrongDirectoryEntries.Count -ne 0) {
        throw "Recipe resources must use '$expectedRecipePrefix'; found: $($wrongDirectoryEntries.FullName -join ', ')."
    }
    $actualRecipes = @($recipeEntries | ForEach-Object {
        [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    } | Sort-Object)
    $recipeDifference = @(Compare-Object -ReferenceObject $expectedRecipes -DifferenceObject $actualRecipes)
    if ($recipeDifference.Count -ne 0) {
        $missingRecipes = @($expectedRecipes | Where-Object { $actualRecipes -notcontains $_ })
        $unexpectedRecipes = @($actualRecipes | Where-Object { $expectedRecipes -notcontains $_ })
        throw "Recipe capability mismatch. Missing: [$($missingRecipes -join ', ')]. Unexpected: [$($unexpectedRecipes -join ', ')]."
    }
    foreach ($recipeEntry in $recipeEntries) {
        $recipe = Get-ZipEntryText $recipeEntry | ConvertFrom-Json
        $ingredientValues = [System.Collections.Generic.List[object]]::new()
        if ($recipe.PSObject.Properties.Name -contains 'ingredient') {
            $ingredientValues.Add($recipe.ingredient)
        }
        if ($recipe.PSObject.Properties.Name -contains 'ingredients') {
            foreach ($ingredient in @($recipe.ingredients)) {
                $ingredientValues.Add($ingredient)
            }
        }
        if ($recipe.PSObject.Properties.Name -contains 'key') {
            foreach ($property in $recipe.key.PSObject.Properties) {
                $ingredientValues.Add($property.Value)
            }
        }
        if ($ingredientValues.Count -eq 0) {
            throw "Recipe '$($recipeEntry.FullName)' has no ingredient, ingredients, or key entries."
        }
        foreach ($ingredient in $ingredientValues) {
            Assert-RecipeIngredientSchema `
                    -Ingredient $ingredient `
                    -RecipeSchema $recipeSchema `
                    -RecipePath $recipeEntry.FullName
        }
        if ($recipe.PSObject.Properties.Name -notcontains 'result') {
            throw "Recipe '$($recipeEntry.FullName)' has no result."
        }
        if ($recipeSchema -eq 'ingredient-objects-legacy-result') {
            $cookingRecipeTypes = @(
                'minecraft:smelting',
                'minecraft:blasting',
                'minecraft:smoking',
                'minecraft:campfire_cooking'
            )
            if ($cookingRecipeTypes -contains [string]$recipe.type) {
                if ($recipe.result -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$recipe.result)) {
                    throw "Cooking recipe '$($recipeEntry.FullName)' must use a legacy string result."
                }
            } elseif ($recipe.result -is [string] -or
                    $recipe.result.PSObject.Properties.Name -notcontains 'item' -or
                    [string]::IsNullOrWhiteSpace([string]$recipe.result.item)) {
                throw "Crafting recipe '$($recipeEntry.FullName)' must use a legacy object result with an item id."
            }
        } elseif ($recipe.result -is [string] -or
                $recipe.result.PSObject.Properties.Name -notcontains 'id' -or
                [string]::IsNullOrWhiteSpace([string]$recipe.result.id)) {
            throw "Recipe '$($recipeEntry.FullName)' must use an object result with an id."
        }
    }

    $languageEntries = @($zip.Entries | Where-Object {
        $_.FullName -match '^assets/carpetlir/lang/[^/]+\.json$'
    })
    if (@($languageEntries | Where-Object Name -eq 'en_us.json').Count -ne 1) {
        throw 'Release JAR must contain exactly one en_us language file.'
    }
    foreach ($languageEntry in $languageEntries) {
        $language = Get-ZipEntryText $languageEntry | ConvertFrom-Json
        $keys = @($language.PSObject.Properties.Name)
        foreach ($rule in $allRules) {
            $nameKey = "carpet.rule.$rule.name"
            $descriptionKey = "carpet.rule.$rule.desc"
            $namePresent = $keys -contains $nameKey
            $descriptionPresent = $keys -contains $descriptionKey
            $isExpected = $expectedRules -contains $rule
            if ($isExpected -and (-not $namePresent -or -not $descriptionPresent)) {
                throw "Language '$($languageEntry.Name)' is missing translations for rule '$rule'."
            }
            if (-not $isExpected -and ($namePresent -or $descriptionPresent)) {
                throw "Language '$($languageEntry.Name)' exposes unavailable rule '$rule'."
            }
        }
    }

    foreach ($classPath in $forbiddenBefore.Keys) {
        $minimumVersion = Convert-ToTargetVersion $forbiddenBefore[$classPath]
        if ($targetVersion -lt $minimumVersion -and $null -ne $zip.GetEntry($classPath)) {
            throw "Minecraft $MinecraftVersion JAR contains unavailable class '$classPath'."
        }
    }

    if ($isLegacyYarnProfile -and
            $targetVersion -ge (Convert-ToTargetVersion '1.19') -and
            $targetVersion -lt (Convert-ToTargetVersion '1.20')) {
        $legacyLootClassPaths = @(
            'org/lavro/carpetlir/features/renewable/ReinforcedDeepslateFeature.class',
            'org/lavro/carpetlir/mixins/AbstractBlockStateMixin.class'
        )
        foreach ($legacyLootClassPath in $legacyLootClassPaths) {
            $legacyLootEntry = $zip.GetEntry($legacyLootClassPath)
            if ($null -eq $legacyLootEntry) {
                throw "Minecraft 1.19 JAR is missing '$legacyLootClassPath'."
            }
            $legacyLootText = [System.Text.Encoding]::UTF8.GetString((Get-ZipEntryBytes $legacyLootEntry))
            if (-not $legacyLootText.Contains('net/minecraft/class_47$class_48') -or
                    $legacyLootText.Contains('net/minecraft/class_8567$class_8568')) {
                throw "Minecraft 1.19 class '$legacyLootClassPath' does not use the legacy loot-context builder."
            }
        }

        $legacyRecipeMixinEntry = $zip.GetEntry('org/lavro/carpetlir/mixins/RecipeManagerMixin.class')
        if ($null -eq $legacyRecipeMixinEntry) {
            throw 'Minecraft 1.19 JAR is missing RecipeManagerMixin.'
        }
        $legacyRecipeMixinText = [System.Text.Encoding]::UTF8.GetString(
                (Get-ZipEntryBytes $legacyRecipeMixinEntry)
        )
        if (-not $legacyRecipeMixinText.Contains('net/minecraft/class_1860') -or
                -not $legacyRecipeMixinText.Contains('com/mojang/datafixers/util/Pair') -or
                $legacyRecipeMixinText.Contains('net/minecraft/class_8786')) {
            throw 'Minecraft 1.19 RecipeManagerMixin does not use the pre-RecipeEntry Pair API.'
        }
    }

    $requiredServerMixinClassPaths = @()
    if ($isLegacyYarnProfile) {
        if ($expectedRules -contains 'renewableCalcite') {
            $requiredServerMixinClassPaths += 'org/lavro/carpetlir/mixins/FluidBlockMixin.class'
        }
        if (@($expectedRules | Where-Object {
            $_ -in @('obsidianHardnessReinforcedDeepslate', 'silkTouchableReinforcedDeepslate')
        }).Count -gt 0) {
            $requiredServerMixinClassPaths += 'org/lavro/carpetlir/mixins/AbstractBlockStateMixin.class'
        }
        if ($expectedRecipes.Count -gt 0) {
            $requiredServerMixinClassPaths += 'org/lavro/carpetlir/mixins/RecipeManagerMixin.class'
        }
    }

    $requiredPistonMixinClassPaths = @()
    if ($isLegacyYarnProfile -and $expectedRules -contains 'pistonHarvestableAmethysts') {
        if ($targetVersion -ge (Convert-ToTargetVersion '1.21.11')) {
            $requiredPistonMixinClassPaths = @('org/lavro/carpetlir/mixins/PistonMoveMixin.class')
            $pistonMoveMixinEntry = $zip.GetEntry('org/lavro/carpetlir/mixins/PistonMoveMixin.class')
            if ($null -eq $pistonMoveMixinEntry -or
                    -not [System.Text.Encoding]::UTF8.GetString(
                            (Get-ZipEntryBytes $pistonMoveMixinEntry)
                    ).Contains('PistonHarvestableAmethystFeature')) {
                throw 'PistonMoveMixin does not retain the budding-amethyst drop hook.'
            }
        } else {
            $requiredPistonMixinClassPaths = @(
                'org/lavro/carpetlir/mixins/BlockMixin.class',
                'org/lavro/carpetlir/mixins/PistonBlockMixin.class'
            )
            $blockMixinEntry = $zip.GetEntry('org/lavro/carpetlir/mixins/BlockMixin.class')
            $pistonBlockMixinEntry = $zip.GetEntry('org/lavro/carpetlir/mixins/PistonBlockMixin.class')
            $pistonHarvestContextEntry = $zip.GetEntry('org/lavro/carpetlir/helpers/PistonHarvestContext.class')
            if ($null -eq $blockMixinEntry -or
                    -not [System.Text.Encoding]::UTF8.GetString(
                            (Get-ZipEntryBytes $blockMixinEntry)
                    ).Contains('PistonHarvestableAmethystFeature')) {
                throw 'BlockMixin does not retain the budding-amethyst drop hook.'
            }
            if ($null -eq $pistonBlockMixinEntry -or
                    -not [System.Text.Encoding]::UTF8.GetString(
                            (Get-ZipEntryBytes $pistonBlockMixinEntry)
                    ).Contains('PistonHarvestContext')) {
                throw 'PistonBlockMixin does not retain the piston-only harvest context.'
            }
            if ($null -eq $pistonHarvestContextEntry) {
                throw 'PistonHarvestContext is absent from the release JAR.'
            }
        }
    }
    $requiredServerMixinClassPaths += $requiredPistonMixinClassPaths

    $mixinConfigs = @($metadata.mixins | ForEach-Object {
        if ($_ -is [string]) { $_ } else { $_.config }
    })
    $packagedMixinConfigs = @($zip.Entries | Where-Object {
        $_.FullName -match '(^|/)[^/]+\.mixins\.json$'
    } | ForEach-Object FullName)
    $unexpectedMixinConfigs = @($packagedMixinConfigs | Where-Object { $mixinConfigs -notcontains $_ })
    if ($unexpectedMixinConfigs.Count -ne 0) {
        throw "Release JAR contains undeclared mixin config(s): $($unexpectedMixinConfigs -join ', ')."
    }
    $serverActiveMixinClassPaths = @()
    foreach ($mixinConfigPath in $mixinConfigs) {
        $mixinConfigEntry = $zip.GetEntry([string]$mixinConfigPath)
        if ($null -eq $mixinConfigEntry) {
            throw "Mixin config '$mixinConfigPath' is declared but absent."
        }
        $mixinConfig = Get-ZipEntryText $mixinConfigEntry | ConvertFrom-Json
        $mixinPackage = ([string]$mixinConfig.package).Replace('.', '/')
        $mixinNames = @($mixinConfig.mixins) + @($mixinConfig.server) + @($mixinConfig.client)
        $mixinDeclaration = @($metadata.mixins | Where-Object {
            $declaredPath = if ($_ -is [string]) { [string]$_ } else { [string]$_.config }
            $declaredPath -eq [string]$mixinConfigPath
        }) | Select-Object -First 1
        $mixinEnvironment = if ($mixinDeclaration -is [string]) {
            '*'
        } elseif ($null -ne $mixinDeclaration -and
                $mixinDeclaration.PSObject.Properties.Name -contains 'environment') {
            [string]$mixinDeclaration.environment
        } else {
            '*'
        }
        if ($mixinEnvironment -ne 'client') {
            $serverMixinNames = @($mixinConfig.mixins) + @($mixinConfig.server)
            $serverActiveMixinClassPaths += @($serverMixinNames | Where-Object {
                -not [string]::IsNullOrWhiteSpace([string]$_)
            } | ForEach-Object { "$mixinPackage/$_.class" })
        }
        foreach ($mixinName in $mixinNames) {
            if ([string]::IsNullOrWhiteSpace([string]$mixinName)) {
                continue
            }
            $mixinClassPath = "$mixinPackage/$mixinName.class"
            if ($null -eq $zip.GetEntry($mixinClassPath)) {
                throw "Mixin config '$mixinConfigPath' references absent class '$mixinClassPath'."
            }
        }
    }
    foreach ($requiredServerMixinClassPath in @($requiredServerMixinClassPaths | Sort-Object -Unique)) {
        if ($serverActiveMixinClassPaths -notcontains $requiredServerMixinClassPath) {
            throw "Required server adapter '$requiredServerMixinClassPath' is not registered in a server-active mixin config."
        }
    }

    $expectedClassMajor = 44 + [int]$target.java
    $classEntries = @($zip.Entries | Where-Object { $_.FullName.EndsWith('.class') })
    if ($classEntries.Count -eq 0) {
        throw 'Release JAR contains no classes.'
    }
    foreach ($classEntry in $classEntries) {
        $stream = $classEntry.Open()
        try {
            $header = New-Object byte[] 8
            if ($stream.Read($header, 0, 8) -ne 8) {
                throw "Class '$($classEntry.FullName)' has a truncated header."
            }
            $major = ([int]$header[6] -shl 8) -bor [int]$header[7]
            if ($major -gt $expectedClassMajor) {
                throw "Class '$($classEntry.FullName)' requires bytecode level $major, above Java $($target.java) level $expectedClassMajor."
            }
        } finally {
            $stream.Dispose()
        }
    }
} finally {
    $zip.Dispose()
}

Write-Host "JAR capability audit passed for Minecraft $MinecraftVersion ($($target.capabilityTier)): $resolvedJar" -ForegroundColor Green
