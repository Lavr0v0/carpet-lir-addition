param(
    [string[]]$RootTargets = @('1.21.11', '26.1', '26.1.1', '26.1.2', '26.2'),
    [switch]$SkipClassic,
    [switch]$SkipTests
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Wrapper = Join-Path $ProjectRoot 'gradlew.bat'
$Validator = Join-Path $PSScriptRoot 'validate-built-jar.ps1'
$ClassicRoot = Join-Path $ProjectRoot 'classic\1.14.4'
$CollectionRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("carpetlir-audited-build-" + [guid]::NewGuid())
$OutputRoot = Join-Path $ProjectRoot 'build\multiversion'
$BuiltTargets = New-Object 'System.Collections.Generic.List[string]'

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

    & $Validator -JarPath $Jar.FullName -MinecraftVersion $Target -ProfilePath $ProfilePath
    if (-not $?) {
        throw "Minecraft $Target JAR capability audit failed."
    }
    Copy-Item -LiteralPath $Jar.FullName -Destination (Join-Path $CollectionRoot $Jar.Name)
    $BuiltTargets.Add($Target)
}

New-Item -ItemType Directory -Path $CollectionRoot | Out-Null

try {
    $task = if ($SkipTests) { 'assemble' } else { 'build' }
    foreach ($target in $RootTargets) {
        $profile = Join-Path $ProjectRoot "versions\targets\$target.properties"
        if (-not (Test-Path -LiteralPath $profile -PathType Leaf)) {
            throw "Unknown or non-build-ready root target '$target'."
        }

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

    $expectedOutputRoot = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot 'build\multiversion'))
    if ([System.IO.Path]::GetFullPath($OutputRoot) -ne $expectedOutputRoot) {
        throw "Refusing to replace unexpected output path '$OutputRoot'."
    }
    New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
    Get-ChildItem -LiteralPath $OutputRoot -File -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem -LiteralPath $CollectionRoot -File | Copy-Item -Destination $OutputRoot

    Write-Host "Built and audited $($BuiltTargets.Count) target(s) into $OutputRoot" -ForegroundColor Green
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
