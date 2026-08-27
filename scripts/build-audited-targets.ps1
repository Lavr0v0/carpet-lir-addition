param(
    [string[]]$RootTargets = @(),
    [switch]$SkipClassic,
    [switch]$SkipTests,
    [switch]$ListTargets,
    [switch]$RequireCleanGit
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Wrapper = Join-Path $ProjectRoot 'gradlew.bat'
$Validator = Join-Path $PSScriptRoot 'validate-built-jar.ps1'
$BundleValidator = Join-Path $PSScriptRoot 'validate-release-bundle.ps1'
$MatrixValidator = Join-Path $PSScriptRoot 'validate-version-matrix.ps1'
$ClassicRoot = Join-Path $ProjectRoot 'classic\1.14.4'
$CollectionRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("carpetlir-audited-build-" + [guid]::NewGuid())
$OutputRoot = Join-Path $ProjectRoot 'build\multiversion'
$BuiltTargets = New-Object 'System.Collections.Generic.List[string]'
$ManifestEntries = New-Object 'System.Collections.Generic.List[object]'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-PropertiesFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Properties file '$Path' does not exist."
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

$rootBuildProperties = Read-PropertiesFile (Join-Path $ProjectRoot 'gradle.properties')
$classicBuildProperties = Read-PropertiesFile (Join-Path $ClassicRoot 'gradle.properties')
$ReleaseVersion = [string]$rootBuildProperties.mod_version
if ([string]::IsNullOrWhiteSpace($ReleaseVersion)) {
    throw 'Root gradle.properties does not declare mod_version.'
}
if ([string]$classicBuildProperties.mod_version -cne $ReleaseVersion) {
    throw "Root release version '$ReleaseVersion' does not match classic release version '$($classicBuildProperties.mod_version)'."
}
if ($RequireCleanGit -and $SkipTests) {
    throw 'Release acceptance cannot skip tests.'
}

$sourceCommitOutput = @(& git -C $ProjectRoot rev-parse HEAD 2>&1)
if ($LASTEXITCODE -ne 0 -or $sourceCommitOutput.Count -ne 1) {
    throw "Unable to resolve the source commit: $($sourceCommitOutput -join [Environment]::NewLine)"
}
$SourceCommit = ([string]$sourceCommitOutput[0]).Trim()
if ($SourceCommit -notmatch '^[0-9a-fA-F]{40}$') {
    throw "Git returned an invalid source commit '$SourceCommit'."
}

$SourceStatus = @(& git -C $ProjectRoot status --porcelain=v1 --untracked-files=all 2>&1)
if ($LASTEXITCODE -ne 0) {
    throw "Unable to inspect the source worktree: $($SourceStatus -join [Environment]::NewLine)"
}
$SourceDirty = $SourceStatus.Count -gt 0
if ($RequireCleanGit -and $SourceDirty) {
    throw "Release acceptance requires a clean Git worktree. Commit or remove these changes first:$([Environment]::NewLine)$($SourceStatus -join [Environment]::NewLine)"
}

$CatalogRootTargets = @(Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'versions\targets') -Filter '*.properties' -File |
        Sort-Object { Convert-ToTargetVersion $_.BaseName } |
        ForEach-Object { $_.BaseName })
$CatalogTargets = @('1.14.4') + $CatalogRootTargets
if ($RootTargets.Count -eq 0) {
    $RootTargets = $CatalogRootTargets
}

$duplicateTargets = @($RootTargets | Group-Object | Where-Object Count -gt 1 | ForEach-Object Name)
if ($duplicateTargets.Count -gt 0) {
    throw "Duplicate root target(s): $($duplicateTargets -join ', ')."
}
foreach ($target in $RootTargets) {
    $profile = Join-Path $ProjectRoot "versions\targets\$target.properties"
    if (-not (Test-Path -LiteralPath $profile -PathType Leaf)) {
        throw "Unknown or non-build-ready root target '$target'."
    }
}

& $MatrixValidator
if ($LASTEXITCODE -ne 0) {
    throw "Version matrix/profile validation failed with exit code $LASTEXITCODE."
}

if ($ListTargets) {
    if (-not $SkipClassic) {
        Write-Output '1.14.4'
    }
    $RootTargets | ForEach-Object { Write-Output $_ }
    return
}

$expectedOutputRoot = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot 'build\multiversion'))
if ([System.IO.Path]::GetFullPath($OutputRoot) -ne $expectedOutputRoot) {
    throw "Refusing to replace unexpected output path '$OutputRoot'."
}
if (Test-Path -LiteralPath $OutputRoot) {
    $preexistingOutputDirectories = @(Get-ChildItem -LiteralPath $OutputRoot -Directory -ErrorAction SilentlyContinue)
    if ($preexistingOutputDirectories.Count -gt 0) {
        throw "Refusing to build while unexpected output subdirectories exist: $($preexistingOutputDirectories.Name -join ', ')."
    }
}

function Get-ReleaseJar {
    param(
        [string]$LibrariesPath,
        [string]$Target
    )

    $jars = @(Get-ChildItem -LiteralPath $LibrariesPath -Filter '*.jar' |
            Where-Object { $_.Name -notlike '*-sources.jar' -and $_.Name -notlike '*-dev.jar' })
    if ($jars.Count -ne 1) {
        throw "Expected one release JAR for Minecraft $Target, found $($jars.Count)."
    }
    return $jars[0]
}

function Copy-AuditedJar {
    param(
        [System.IO.FileInfo]$Jar,
        [string]$Target,
        [string]$ProfilePath
    )

    $profile = Read-PropertiesFile $ProfilePath
    $expectedJarName = "carpet-lir-addition-mc$([string]$profile.archive_minecraft_label)-$ReleaseVersion.jar"
    if ($Jar.Name -cne $expectedJarName) {
        throw "Minecraft $Target release JAR '$($Jar.Name)' does not match expected name '$expectedJarName'."
    }

    & $Validator -JarPath $Jar.FullName -MinecraftVersion $Target -ProfilePath $ProfilePath -ExpectedModVersion $ReleaseVersion
    if (-not $?) {
        throw "Minecraft $Target JAR capability audit failed."
    }

    $destination = Join-Path $CollectionRoot $Jar.Name
    if (Test-Path -LiteralPath $destination) {
        throw "Duplicate release artifact name '$($Jar.Name)'."
    }
    Copy-Item -LiteralPath $Jar.FullName -Destination $destination

    $loaderDependency = if ($profile.ContainsKey('loader_dependency')) {
        [string]$profile.loader_dependency
    } else {
        ">=$([string]$profile.loader_version)"
    }
    $fabricApiModId = if ($profile.ContainsKey('fabric_api_mod_id')) {
        [string]$profile.fabric_api_mod_id
    } else {
        'fabric-api'
    }
    $fabricApiDependency = if ($profile.ContainsKey('fabric_api_dependency')) {
        [string]$profile.fabric_api_dependency
    } else {
        ">=$([string]$profile.fabric_api_version)"
    }
    $carpetModVersion = if ($profile.ContainsKey('carpet_mod_version')) {
        [string]$profile.carpet_mod_version
    } else {
        [string]$profile.carpet_core_version
    }
    $carpetDependency = if ($profile.ContainsKey('carpet_dependency')) {
        [string]$profile.carpet_dependency
    } else {
        ">=$carpetModVersion"
    }
    $buildSourceFamily = if ($profile.ContainsKey('source_family')) {
        [string]$profile.source_family
    } else {
        [string]$profile.matrix_source_family
    }
    $relativeProfile = [System.IO.Path]::GetFullPath($ProfilePath).Substring($ProjectRoot.Length).TrimStart('\').Replace('\', '/')
    $copiedJar = Get-Item -LiteralPath $destination
    $sha256 = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant()

    $ManifestEntries.Add([pscustomobject][ordered]@{
            minecraftVersion = $Target
            fileName = $copiedJar.Name
            sha256 = $sha256
            sizeBytes = [long]$copiedJar.Length
            java = [int]$profile.java_version
            capabilityTier = [string]$profile.capability_tier
            supportStatus = [string]$profile.support_status
            profile = $relativeProfile
            sourceFamily = [string]$profile.matrix_source_family
            buildSourceFamily = $buildSourceFamily
            minecraftDependency = [string]$profile.minecraft_dependency
            fabricLoader = [pscustomobject][ordered]@{
                version = [string]$profile.loader_version
                dependency = $loaderDependency
            }
            fabricApi = [pscustomobject][ordered]@{
                modId = $fabricApiModId
                version = [string]$profile.fabric_api_version
                dependency = $fabricApiDependency
            }
            carpet = [pscustomobject][ordered]@{
                artifact = [string]$profile.carpet_core_version
                modVersion = $carpetModVersion
                dependency = $carpetDependency
            }
        })
    $BuiltTargets.Add($Target)
}

New-Item -ItemType Directory -Path $CollectionRoot | Out-Null

try {
    $task = if ($SkipTests) { 'assemble' } else { 'build' }
    foreach ($target in $RootTargets) {
        $profile = Join-Path $ProjectRoot "versions\targets\$target.properties"

        Write-Host "Building Carpet LIR Addition for Minecraft $target..." -ForegroundColor Cyan
        & $Wrapper clean $task "-PtargetVersion=$target" --no-daemon --console=plain
        if ($LASTEXITCODE -ne 0) {
            throw "Minecraft $target build failed with exit code $LASTEXITCODE."
        }

        $jar = Get-ReleaseJar -LibrariesPath (Join-Path $ProjectRoot 'build\libs') -Target $target
        Copy-AuditedJar -Jar $jar -Target $target -ProfilePath $profile
    }

    if (-not $SkipClassic) {
        $classicProfile = Join-Path $ClassicRoot 'gradle.properties'
        Write-Host 'Building Carpet LIR Addition for Minecraft 1.14.4...' -ForegroundColor Cyan
        & $Wrapper -p $ClassicRoot clean $task --no-daemon --console=plain
        if ($LASTEXITCODE -ne 0) {
            throw "Minecraft 1.14.4 build failed with exit code $LASTEXITCODE."
        }

        $classicJar = Get-ReleaseJar -LibrariesPath (Join-Path $ClassicRoot 'build\libs') -Target '1.14.4'
        Copy-AuditedJar -Jar $classicJar -Target '1.14.4' -ProfilePath $classicProfile
    }

    if ($BuiltTargets.Count -ne $ManifestEntries.Count) {
        throw "Built target count $($BuiltTargets.Count) does not match manifest entry count $($ManifestEntries.Count)."
    }

    $finalCommitOutput = @(& git -C $ProjectRoot rev-parse HEAD 2>&1)
    if ($LASTEXITCODE -ne 0 -or $finalCommitOutput.Count -ne 1) {
        throw "Unable to re-check the source commit: $($finalCommitOutput -join [Environment]::NewLine)"
    }
    $finalSourceCommit = ([string]$finalCommitOutput[0]).Trim()
    if ($finalSourceCommit -cne $SourceCommit) {
        throw "Source commit changed during the build from '$SourceCommit' to '$finalSourceCommit'."
    }

    $finalSourceStatus = @(& git -C $ProjectRoot status --porcelain=v1 --untracked-files=all 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to re-check the source worktree: $($finalSourceStatus -join [Environment]::NewLine)"
    }
    $finalSourceDirty = $finalSourceStatus.Count -gt 0
    if ($RequireCleanGit -and $finalSourceDirty) {
        throw "Source worktree changed during release acceptance:$([Environment]::NewLine)$($finalSourceStatus -join [Environment]::NewLine)"
    }
    $SourceDirty = $SourceDirty -or $finalSourceDirty

    $orderedManifestEntries = @($ManifestEntries | Sort-Object { Convert-ToTargetVersion $_.minecraftVersion })
    $completeCatalog = (-not $SkipClassic -and
        $BuiltTargets.Count -eq $CatalogTargets.Count -and
        @(Compare-Object -ReferenceObject $CatalogTargets -DifferenceObject @($BuiltTargets)).Count -eq 0)
    $manifest = [pscustomobject][ordered]@{
        schemaVersion = 1
        modId = 'carpetlir'
        modVersion = $ReleaseVersion
        sourceCommit = $SourceCommit.ToLowerInvariant()
        sourceDirty = [bool]$SourceDirty
        generatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
        buildTask = $task
        testsExecuted = [bool](-not $SkipTests)
        artifactCount = [int]$orderedManifestEntries.Count
        catalogArtifactCount = [int]$CatalogTargets.Count
        completeCatalog = [bool]$completeCatalog
        artifacts = $orderedManifestEntries
    }
    $manifestJson = ($manifest | ConvertTo-Json -Depth 8) + [Environment]::NewLine
    [System.IO.File]::WriteAllText((Join-Path $CollectionRoot 'release-manifest.json'), $manifestJson, $Utf8NoBom)

    $checksumLines = @($orderedManifestEntries | ForEach-Object { "$($_.sha256) *$($_.fileName)" })
    $checksumText = if ($checksumLines.Count -gt 0) { ($checksumLines -join "`n") + "`n" } else { '' }
    [System.IO.File]::WriteAllText((Join-Path $CollectionRoot 'SHA256SUMS.txt'), $checksumText, $Utf8NoBom)

    if ([System.IO.Path]::GetFullPath($OutputRoot) -ne $expectedOutputRoot) {
        throw "Refusing to replace unexpected output path '$OutputRoot'."
    }
    New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
    $unexpectedOutputDirectories = @(Get-ChildItem -LiteralPath $OutputRoot -Directory -ErrorAction SilentlyContinue)
    if ($unexpectedOutputDirectories.Count -gt 0) {
        throw "Refusing to replace output while unexpected subdirectories exist: $($unexpectedOutputDirectories.Name -join ', ')."
    }
    Get-ChildItem -LiteralPath $OutputRoot -File -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem -LiteralPath $CollectionRoot -File | Copy-Item -Destination $OutputRoot

    $bundleValidationArguments = @{ BundlePath = $OutputRoot }
    if ($RequireCleanGit -and $completeCatalog) {
        $bundleValidationArguments.RequireCompleteCatalog = $true
    }
    & $BundleValidator @bundleValidationArguments
    if (-not $?) {
        throw 'Collected release bundle validation failed.'
    }

    Write-Host "Built and audited $($BuiltTargets.Count) target(s) into $OutputRoot" -ForegroundColor Green
    Write-Host 'Release metadata: release-manifest.json, SHA256SUMS.txt' -ForegroundColor Green
    Get-ChildItem -LiteralPath $OutputRoot -File | Sort-Object Name | Select-Object Name, Length
} finally {
    if (Test-Path -LiteralPath $CollectionRoot) {
        $resolvedTemp = (Resolve-Path -LiteralPath $CollectionRoot).Path
        $systemTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\')
        if (-not $resolvedTemp.StartsWith($systemTemp + '\carpetlir-audited-build-', [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove unexpected temporary path '$resolvedTemp'."
        }
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
    }
}
