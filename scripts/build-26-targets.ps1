param(
    [string[]]$Targets = @('26.1', '26.1.1', '26.1.2', '26.2'),
    [switch]$SkipTests
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Wrapper = Join-Path $ProjectRoot 'gradlew.bat'
$CollectionRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("carpetlir-26-build-" + [guid]::NewGuid())
$OutputRoot = Join-Path $ProjectRoot 'build\multiversion'

New-Item -ItemType Directory -Path $CollectionRoot | Out-Null

try {
    foreach ($target in $Targets) {
        $profile = Join-Path $ProjectRoot "versions\targets\$target.properties"
        if (-not (Test-Path -LiteralPath $profile -PathType Leaf)) {
            throw "Unknown or non-build-ready 26.x target '$target'."
        }

        Write-Host "Building Carpet LIR Addition for Minecraft $target..." -ForegroundColor Cyan
        $task = if ($SkipTests) { 'assemble' } else { 'build' }
        & $Wrapper clean $task "-PtargetVersion=$target" --no-daemon --console=plain
        if ($LASTEXITCODE -ne 0) {
            throw "Minecraft $target build failed with exit code $LASTEXITCODE."
        }

        $jars = @(Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'build\libs') -Filter '*.jar' |
                Where-Object { $_.Name -notlike '*-sources.jar' })
        if ($jars.Count -ne 1) {
            throw "Expected one release JAR for Minecraft $target, found $($jars.Count)."
        }
        $jar = $jars[0]
        Copy-Item -LiteralPath $jar.FullName -Destination (Join-Path $CollectionRoot $jar.Name)
    }

    New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
    Get-ChildItem -LiteralPath $OutputRoot -File -ErrorAction SilentlyContinue |
            Remove-Item -Force
    Get-ChildItem -LiteralPath $CollectionRoot -File |
            Copy-Item -Destination $OutputRoot

    Write-Host "Built $($Targets.Count) target(s) into $OutputRoot" -ForegroundColor Green
    Get-ChildItem -LiteralPath $OutputRoot -File | Select-Object Name, Length
} finally {
    if (Test-Path -LiteralPath $CollectionRoot) {
        $resolvedTemp = (Resolve-Path -LiteralPath $CollectionRoot).Path
        $systemTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\')
        if (-not $resolvedTemp.StartsWith($systemTemp + '\carpetlir-26-build-', [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove unexpected temporary path '$resolvedTemp'."
        }
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
    }
}
