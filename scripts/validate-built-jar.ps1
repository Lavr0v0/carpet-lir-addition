param(
    [Parameter(Mandatory = $true)]
    [string]$JarPath,

    [Parameter(Mandatory = $true)]
    [string]$MinecraftVersion,

    [string]$MatrixPath
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

function Test-VersionPredicate {
    param(
        [string]$Predicate,
        [version]$ActualVersion
    )

    if ([string]::IsNullOrWhiteSpace($Predicate) -or $Predicate.Trim() -eq '*') {
        return $true
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

$forbiddenBefore = @{
    'org/lavro/carpetlir/features/renewable/CalciteGeneratorFeature.class' = '1.17'
    'org/lavro/carpetlir/features/renewable/PistonHarvestableAmethystFeature.class' = '1.17'
    'org/lavro/carpetlir/helpers/PistonHarvestContext.class' = '1.17'
    'org/lavro/carpetlir/mixins/BlockMixin.class' = '1.17'
    'org/lavro/carpetlir/mixins/FluidBlockMixin.class' = '1.17'
    'org/lavro/carpetlir/mixins/PistonBlockMixin.class' = '1.17'
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
    $minecraftDependencies = @($metadata.depends.minecraft | ForEach-Object { [string]$_ })
    if ($minecraftDependencies.Count -eq 0 -or -not @($minecraftDependencies | Where-Object {
        Test-VersionPredicate $_ $targetVersion
    }).Count) {
        throw "Release JAR Minecraft dependency '$($minecraftDependencies -join ', ')' does not cover $MinecraftVersion."
    }
    foreach ($dependencyId in @('fabricloader', 'fabric-api')) {
        $dependencyValue = [string]$metadata.depends.$dependencyId
        if ([string]::IsNullOrWhiteSpace($dependencyValue) -or $dependencyValue -eq '*') {
            throw "Release JAR must declare a bounded $dependencyId dependency."
        }
    }
    $carpetDependency = [string]$metadata.depends.carpet
    if ([string]::IsNullOrWhiteSpace($carpetDependency) -or $carpetDependency -eq '*') {
        throw 'Release JAR must declare a bounded Fabric Carpet dependency.'
    }
    if (-not $carpetDependency.Contains([string]$target.carpetVersion)) {
        throw "Release JAR Carpet dependency '$carpetDependency' does not include audited coordinate '$($target.carpetVersion)'."
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
    $actualRecipes = @($recipeEntries | ForEach-Object {
        [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    } | Sort-Object)
    $recipeDifference = @(Compare-Object -ReferenceObject $expectedRecipes -DifferenceObject $actualRecipes)
    if ($recipeDifference.Count -ne 0) {
        $missingRecipes = @($expectedRecipes | Where-Object { $actualRecipes -notcontains $_ })
        $unexpectedRecipes = @($actualRecipes | Where-Object { $expectedRecipes -notcontains $_ })
        throw "Recipe capability mismatch. Missing: [$($missingRecipes -join ', ')]. Unexpected: [$($unexpectedRecipes -join ', ')]."
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

    $mixinConfigs = @($metadata.mixins | ForEach-Object {
        if ($_ -is [string]) { $_ } else { $_.config }
    })
    foreach ($mixinConfigPath in $mixinConfigs) {
        $mixinConfigEntry = $zip.GetEntry([string]$mixinConfigPath)
        if ($null -eq $mixinConfigEntry) {
            throw "Mixin config '$mixinConfigPath' is declared but absent."
        }
        $mixinConfig = Get-ZipEntryText $mixinConfigEntry | ConvertFrom-Json
        $mixinPackage = ([string]$mixinConfig.package).Replace('.', '/')
        $mixinNames = @($mixinConfig.mixins) + @($mixinConfig.server) + @($mixinConfig.client)
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
