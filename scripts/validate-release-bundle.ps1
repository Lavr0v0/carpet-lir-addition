param(
    [string]$BundlePath,
    [switch]$RequireCompleteCatalog
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$JarValidator = Join-Path $PSScriptRoot 'validate-built-jar.ps1'
$MatrixValidator = Join-Path $PSScriptRoot 'validate-version-matrix.ps1'
if ([string]::IsNullOrWhiteSpace($BundlePath)) {
    $BundlePath = Join-Path $ProjectRoot 'build\multiversion'
}
if (-not (Test-Path -LiteralPath $BundlePath -PathType Container)) {
    throw "Release bundle '$BundlePath' does not exist."
}
$resolvedBundle = (Resolve-Path -LiteralPath $BundlePath).Path

function Read-PropertiesFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Profile '$Path' does not exist."
    }
    return ConvertFrom-StringData (Get-Content -LiteralPath $Path -Raw)
}

function Convert-ToTargetVersion {
    param([string]$Target)

    $parts = @($Target.Split('.') | ForEach-Object { [int]$_ })
    while ($parts.Count -lt 3) {
        $parts += 0
    }
    return [version]("{0}.{1}.{2}" -f $parts[0], $parts[1], $parts[2])
}

function Get-ProfileValue {
    param(
        [hashtable]$Profile,
        [string]$Name,
        [string]$DefaultValue
    )

    if ($Profile.ContainsKey($Name)) {
        return [string]$Profile[$Name]
    }
    return $DefaultValue
}

& $MatrixValidator
if ($LASTEXITCODE -ne 0) {
    throw "Version matrix/profile validation failed with exit code $LASTEXITCODE."
}

$directories = @(Get-ChildItem -LiteralPath $resolvedBundle -Directory -Force)
if ($directories.Count -gt 0) {
    throw "Release bundle contains unexpected subdirectories: $($directories.Name -join ', ')."
}

$manifestPath = Join-Path $resolvedBundle 'release-manifest.json'
$checksumPath = Join-Path $resolvedBundle 'SHA256SUMS.txt'
foreach ($requiredPath in @($manifestPath, $checksumPath)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Release bundle is missing '$([System.IO.Path]::GetFileName($requiredPath))'."
    }
}

try {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
} catch {
    throw "Unable to parse release-manifest.json: $($_.Exception.Message)"
}
$requiredManifestFields = @(
    'schemaVersion', 'modId', 'modVersion', 'sourceCommit', 'sourceDirty', 'generatedAtUtc',
    'buildTask', 'testsExecuted', 'artifactCount', 'catalogArtifactCount', 'completeCatalog', 'artifacts'
)
foreach ($field in $requiredManifestFields) {
    if ($manifest.PSObject.Properties.Name -notcontains $field) {
        throw "Release manifest is missing required field '$field'."
    }
}
foreach ($field in @('sourceDirty', 'testsExecuted', 'completeCatalog')) {
    if ($manifest.$field -isnot [bool]) {
        throw "Release manifest field '$field' must be a JSON boolean."
    }
}
if ([int]$manifest.schemaVersion -ne 1) {
    throw "Unsupported release manifest schema '$($manifest.schemaVersion)'."
}
if ([string]$manifest.modId -cne 'carpetlir') {
    throw "Unexpected release manifest mod id '$($manifest.modId)'."
}
$modVersion = [string]$manifest.modVersion
if ([string]::IsNullOrWhiteSpace($modVersion) -or $modVersion -match '\$\{') {
    throw "Release manifest has invalid mod version '$modVersion'."
}
if ([string]$manifest.sourceCommit -cnotmatch '^[0-9a-f]{40}$') {
    throw "Release manifest has invalid source commit '$($manifest.sourceCommit)'."
}
$buildTask = [string]$manifest.buildTask
if ($buildTask -cne 'build' -and $buildTask -cne 'assemble') {
    throw "Release manifest has invalid build task '$buildTask'."
}
if (($buildTask -ceq 'build') -ne [bool]$manifest.testsExecuted) {
    throw "Release manifest buildTask '$buildTask' conflicts with testsExecuted '$($manifest.testsExecuted)'."
}

$artifacts = @($manifest.artifacts)
if ([int]$manifest.artifactCount -ne $artifacts.Count) {
    throw "Manifest artifactCount $($manifest.artifactCount) does not match $($artifacts.Count) artifact entries."
}
if ($artifacts.Count -eq 0) {
    throw 'Release manifest contains no artifacts.'
}

$catalogRootTargets = @(Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'versions\targets') -Filter '*.properties' -File |
        ForEach-Object { $_.BaseName })
$catalogTargets = @('1.14.4') + $catalogRootTargets
if ([int]$manifest.catalogArtifactCount -ne $catalogTargets.Count) {
    throw "Manifest catalogArtifactCount $($manifest.catalogArtifactCount) does not match the local catalog count $($catalogTargets.Count)."
}
if ([bool]$manifest.completeCatalog) {
    if ([int]$manifest.artifactCount -ne [int]$manifest.catalogArtifactCount) {
        throw 'Manifest marks an incomplete artifact count as a complete catalog.'
    }
    $completeCatalogDifference = @(Compare-Object -ReferenceObject $catalogTargets -DifferenceObject @($artifacts | ForEach-Object { [string]$_.minecraftVersion }))
    if ($completeCatalogDifference.Count -gt 0) {
        throw 'Manifest complete-catalog targets do not exactly match the local catalog.'
    }
}
if ($RequireCompleteCatalog) {
    if (-not [bool]$manifest.completeCatalog) {
        throw 'Release acceptance requires completeCatalog=true.'
    }
    if ([bool]$manifest.sourceDirty) {
        throw 'Release acceptance requires sourceDirty=false.'
    }
    if ([string]$manifest.buildTask -cne 'build' -or -not [bool]$manifest.testsExecuted) {
        throw 'Release acceptance requires the full build task with tests executed.'
    }

    $rootProperties = Read-PropertiesFile (Join-Path $ProjectRoot 'gradle.properties')
    $classicProperties = Read-PropertiesFile (Join-Path $ProjectRoot 'classic\1.14.4\gradle.properties')
    if ([string]$rootProperties.mod_version -cne $modVersion -or
            [string]$classicProperties.mod_version -cne $modVersion) {
        throw "Release manifest version '$modVersion' does not match both current project versions."
    }

    $headOutput = @(& git -C $ProjectRoot rev-parse HEAD 2>&1)
    if ($LASTEXITCODE -ne 0 -or $headOutput.Count -ne 1) {
        throw "Unable to resolve the current source commit: $($headOutput -join [Environment]::NewLine)"
    }
    $currentCommit = ([string]$headOutput[0]).Trim().ToLowerInvariant()
    if ($currentCommit -cne [string]$manifest.sourceCommit) {
        throw "Release manifest commit '$($manifest.sourceCommit)' does not match current HEAD '$currentCommit'."
    }

    $sourceStatus = @(& git -C $ProjectRoot status --porcelain=v1 --untracked-files=all 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to inspect the current source worktree: $($sourceStatus -join [Environment]::NewLine)"
    }
    if ($sourceStatus.Count -gt 0) {
        throw "Release acceptance requires a clean current worktree:$([Environment]::NewLine)$($sourceStatus -join [Environment]::NewLine)"
    }
}

$manifestTargetOrder = @($artifacts | ForEach-Object { [string]$_.minecraftVersion })
$sortedTargetOrder = @($manifestTargetOrder | Sort-Object { Convert-ToTargetVersion $_ })
if (($manifestTargetOrder -join "`n") -cne ($sortedTargetOrder -join "`n")) {
    throw 'Release manifest artifacts are not sorted by Minecraft version.'
}

foreach ($field in @('minecraftVersion', 'fileName', 'sha256')) {
    $duplicates = @($artifacts | Group-Object -Property $field | Where-Object Count -gt 1)
    if ($duplicates.Count -gt 0) {
        throw "Release manifest contains duplicate ${field}: $($duplicates.Name -join ', ')."
    }
}

$expectedFileNames = New-Object 'System.Collections.Generic.List[string]'
$expectedFileNames.Add('release-manifest.json')
$expectedFileNames.Add('SHA256SUMS.txt')
$expectedChecksumLines = New-Object 'System.Collections.Generic.List[string]'
$rootPrefix = $ProjectRoot.TrimEnd('\') + '\'

foreach ($artifact in $artifacts) {
    $target = [string]$artifact.minecraftVersion
    $fileName = [string]$artifact.fileName
    $hash = [string]$artifact.sha256
    if ([string]::IsNullOrWhiteSpace($target)) {
        throw 'Release manifest contains an artifact without a Minecraft version.'
    }
    if ($target -notin $catalogTargets) {
        throw "Release manifest contains unknown Minecraft target '$target'."
    }
    if ([System.IO.Path]::GetFileName($fileName) -cne $fileName -or [System.IO.Path]::GetExtension($fileName) -cne '.jar') {
        throw "Artifact filename '$fileName' is not a safe JAR basename."
    }
    if ($hash -cnotmatch '^[0-9a-f]{64}$') {
        throw "Artifact '$fileName' has invalid lowercase SHA-256 '$hash'."
    }
    if ([long]$artifact.sizeBytes -le 0) {
        throw "Artifact '$fileName' has invalid size '$($artifact.sizeBytes)'."
    }

    $expectedProfile = if ($target -ceq '1.14.4') {
        'classic/1.14.4/gradle.properties'
    } else {
        "versions/targets/$target.properties"
    }
    if ([string]$artifact.profile -cne $expectedProfile) {
        throw "Artifact '$fileName' profile '$($artifact.profile)' does not match '$expectedProfile'."
    }
    $profilePath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $expectedProfile))
    if (-not $profilePath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Artifact '$fileName' profile resolves outside the project."
    }
    $profile = Read-PropertiesFile $profilePath

    $expectedLoaderDependency = Get-ProfileValue $profile 'loader_dependency' ">=$([string]$profile.loader_version)"
    $expectedFabricId = Get-ProfileValue $profile 'fabric_api_mod_id' 'fabric-api'
    $expectedFabricDependency = Get-ProfileValue $profile 'fabric_api_dependency' ">=$([string]$profile.fabric_api_version)"
    $expectedCarpetModVersion = Get-ProfileValue $profile 'carpet_mod_version' ([string]$profile.carpet_core_version)
    $expectedCarpetDependency = Get-ProfileValue $profile 'carpet_dependency' ">=$expectedCarpetModVersion"
    $expectedBuildSourceFamily = Get-ProfileValue $profile 'source_family' ([string]$profile.matrix_source_family)
    $expectedJarName = "carpet-lir-addition-mc$([string]$profile.archive_minecraft_label)-$modVersion.jar"

    $profileMismatches = @(
        if ($fileName -cne $expectedJarName) { 'fileName' }
        if ([int]$artifact.java -ne [int]$profile.java_version) { 'java' }
        if ([string]$artifact.capabilityTier -cne [string]$profile.capability_tier) { 'capabilityTier' }
        if ([string]$artifact.supportStatus -cne [string]$profile.support_status) { 'supportStatus' }
        if ([string]$artifact.sourceFamily -cne [string]$profile.matrix_source_family) { 'sourceFamily' }
        if ([string]$artifact.buildSourceFamily -cne $expectedBuildSourceFamily) { 'buildSourceFamily' }
        if ([string]$artifact.minecraftDependency -cne [string]$profile.minecraft_dependency) { 'minecraftDependency' }
        if ([string]$artifact.fabricLoader.version -cne [string]$profile.loader_version) { 'fabricLoader.version' }
        if ([string]$artifact.fabricLoader.dependency -cne $expectedLoaderDependency) { 'fabricLoader.dependency' }
        if ([string]$artifact.fabricApi.modId -cne $expectedFabricId) { 'fabricApi.modId' }
        if ([string]$artifact.fabricApi.version -cne [string]$profile.fabric_api_version) { 'fabricApi.version' }
        if ([string]$artifact.fabricApi.dependency -cne $expectedFabricDependency) { 'fabricApi.dependency' }
        if ([string]$artifact.carpet.artifact -cne [string]$profile.carpet_core_version) { 'carpet.artifact' }
        if ([string]$artifact.carpet.modVersion -cne $expectedCarpetModVersion) { 'carpet.modVersion' }
        if ([string]$artifact.carpet.dependency -cne $expectedCarpetDependency) { 'carpet.dependency' }
    )
    if ($profileMismatches.Count -gt 0) {
        throw "Artifact '$fileName' manifest fields do not match its profile: $($profileMismatches -join ', ')."
    }

    $jarPath = Join-Path $resolvedBundle $fileName
    if (-not (Test-Path -LiteralPath $jarPath -PathType Leaf)) {
        throw "Manifest artifact '$fileName' is missing from the bundle."
    }
    $jar = Get-Item -LiteralPath $jarPath
    if ([long]$jar.Length -ne [long]$artifact.sizeBytes) {
        throw "Artifact '$fileName' size $($jar.Length) does not match manifest size $($artifact.sizeBytes)."
    }
    $actualHash = (Get-FileHash -LiteralPath $jar.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -cne $hash) {
        throw "Artifact '$fileName' SHA-256 '$actualHash' does not match manifest '$hash'."
    }

    & $JarValidator -JarPath $jar.FullName -MinecraftVersion $target -ProfilePath $profilePath -ExpectedModVersion $modVersion
    if (-not $?) {
        throw "Artifact '$fileName' failed its JAR capability audit."
    }
    $expectedFileNames.Add($fileName)
    $expectedChecksumLines.Add("$hash *$fileName")
}

$actualFileNames = @(Get-ChildItem -LiteralPath $resolvedBundle -File -Force | ForEach-Object { $_.Name })
$fileDifference = @(Compare-Object -ReferenceObject @($expectedFileNames) -DifferenceObject $actualFileNames)
if ($fileDifference.Count -gt 0) {
    throw "Release bundle file set does not match the manifest: $($fileDifference.InputObject -join ', ')."
}

$expectedChecksumText = ($expectedChecksumLines -join "`n") + "`n"
$actualChecksumText = [System.IO.File]::ReadAllText($checksumPath)
if ($actualChecksumText -cne $expectedChecksumText) {
    throw 'SHA256SUMS.txt does not exactly match the ordered manifest entries.'
}

Write-Host "Release bundle validation passed: $($artifacts.Count) artifact(s), version $modVersion." -ForegroundColor Green
