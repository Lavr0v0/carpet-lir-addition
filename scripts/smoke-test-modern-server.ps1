param(
    [Parameter(Mandatory = $true)]
    [string]$TargetVersion,
    [string]$EulaSourcePath,
    [int]$StartupTimeoutSeconds = 240,
    [int]$CommandDelayMilliseconds = 1200,
    [switch]$CleanRunDirectory
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Wrapper = Join-Path $ProjectRoot 'gradlew.bat'
$ProfilePath = Join-Path $ProjectRoot "versions\targets\$TargetVersion.properties"
$RunRoot = Join-Path $ProjectRoot 'run'
$RunDirectoryName = "$TargetVersion-smoke-$([guid]::NewGuid().ToString('N'))"
$RunDirectory = Join-Path $RunRoot $RunDirectoryName
$EvidenceRoot = Join-Path $ProjectRoot 'build\server-smoke'
$EvidencePath = Join-Path $EvidenceRoot "minecraft-$TargetVersion.log"

if (-not (Test-Path -LiteralPath $ProfilePath -PathType Leaf)) {
    throw "Unknown or non-build-ready target '$TargetVersion'."
}
$profile = ConvertFrom-StringData (Get-Content -LiteralPath $ProfilePath -Raw)
if ([string]$profile.source_family -ne 'legacy-yarn' -or [int]$profile.java_version -lt 21) {
    throw "Target '$TargetVersion' is not supported by the modern Yarn server smoke harness."
}

if ([string]::IsNullOrWhiteSpace($EulaSourcePath)) {
    $EulaSourcePath = @(
        (Join-Path $RunRoot 'eula.txt'),
        (Join-Path $RunRoot '1.21.11\eula.txt')
    ) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
}
if ([string]::IsNullOrWhiteSpace($EulaSourcePath) -or
        -not (Test-Path -LiteralPath $EulaSourcePath -PathType Leaf) -or
        -not (Select-String -LiteralPath $EulaSourcePath -Pattern '^eula=true$' -Quiet)) {
    throw 'A previously accepted Minecraft EULA file containing eula=true is required.'
}

$resolvedEulaSource = (Resolve-Path -LiteralPath $EulaSourcePath).Path
$eulaDestination = [System.IO.Path]::GetFullPath((Join-Path $RunDirectory 'eula.txt'))
New-Item -ItemType Directory -Path $EvidenceRoot -Force | Out-Null

$startupCommands = @(
    'forceload add 0 0',
    'fill -2 100 -2 4 104 4 minecraft:air',
    'setblock 0 100 0 minecraft:stone',
    'setblock 0 101 2 minecraft:dirt',
    'carpet boneMealGrassifyDirt true',
    'player Notch spawn'
)
$gameplayCommands = @(
    'tp Notch 0.5 101 0.5',
    'effect give Notch minecraft:water_breathing infinite 0 true',
    'player Notch look at 0.5 101.5 2.5',
    'item replace entity Notch weapon.mainhand with minecraft:bone_meal 3',
    'player Notch use once',
    'execute if block 0 101 2 minecraft:grass_block run say CARPETLIR_BONEMEAL_ENABLED_PASS',
    'setblock 0 101 2 minecraft:dirt',
    'setblock 0 102 2 minecraft:snow[layers=1]',
    'player Notch use once',
    'execute if block 0 101 2 minecraft:grass_block[snowy=true] run say CARPETLIR_BONEMEAL_SNOWY_PASS',
    'setblock 0 102 2 minecraft:air',
    'carpet boneMealGrassifyDirt false',
    'setblock 0 101 2 minecraft:dirt',
    'player Notch use once',
    'execute if block 0 101 2 minecraft:dirt run say CARPETLIR_BONEMEAL_DISABLED_PASS',
    'carpet boneMealGrassifyDirt true',
    'gamemode spectator Notch',
    'setblock 0 101 2 minecraft:dirt',
    'player Notch use once',
    'execute if block 0 101 2 minecraft:dirt run say CARPETLIR_BONEMEAL_SPECTATOR_PASS',
    'gamemode survival Notch',
    'tp Notch 0.5 101 0.5',
    'carpet renewableLeavesCrafting true',
    'recipe give Notch carpetlir:oak_leaves_from_oak_log_and_sticks',
    'carpet renewableLeavesCrafting false',
    'setblock 2 101 2 minecraft:furnace',
    'carpet renewableTuff true',
    'item replace block 2 101 2 container.0 with minecraft:gravel 2',
    'item replace block 2 101 2 container.1 with minecraft:coal 1',
    'execute if items block 2 101 2 container.2 minecraft:tuff run say CARPETLIR_RECIPE_ENABLED_PASS',
    'item replace block 2 101 2 container.2 with minecraft:air',
    'carpet renewableTuff false',
    'execute unless items block 2 101 2 container.2 minecraft:tuff run say CARPETLIR_RECIPE_CACHED_DISABLED_PASS',
    'player Notch kill',
    'say CARPETLIR_SMOKE_COMPLETE'
)
$extendedCommandDelays = @{
    'item replace block 2 101 2 container.1 with minecraft:coal 1' = 12000
    'carpet renewableTuff false' = 12000
}
$requiredMarkers = @(
    'CARPETLIR_BONEMEAL_ENABLED_PASS',
    'CARPETLIR_BONEMEAL_SNOWY_PASS',
    'CARPETLIR_BONEMEAL_DISABLED_PASS',
    'CARPETLIR_BONEMEAL_SPECTATOR_PASS',
    'CARPETLIR_RECIPE_ENABLED_PASS',
    'CARPETLIR_RECIPE_CACHED_DISABLED_PASS',
    'Notch lost connection: Killed',
    'CARPETLIR_SMOKE_COMPLETE'
)
$forbiddenPatterns = @(
    'Mixin apply failed',
    'Could not execute entrypoint',
    'Unknown recipe',
    'Unknown or incomplete command',
    'Incorrect argument for command',
    'That position is not loaded',
    'No entity was found',
    'No player was found',
    'Can only manipulate existing players',
    'Notch drowned'
)

$commandLine = '"{0}" runServer "-PtargetVersion={1}" "-PrunDirectoryName={2}" --no-daemon --console=plain 2>&1' -f $Wrapper, $TargetVersion, $RunDirectoryName
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $env:ComSpec
$startInfo.Arguments = "/d /s /c `"$commandLine`""
$startInfo.WorkingDirectory = $ProjectRoot
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardInput = $true
$startInfo.RedirectStandardOutput = $true

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $startInfo
$output = New-Object 'System.Collections.Generic.List[string]'
$serverOutput = New-Object 'System.Collections.Generic.List[string]'
$serverReady = $false
$gameplayCommandsSent = $false
$processStarted = $false
$runDirectoryCreated = $false
$cleanupErrorMessage = $null
$exitCode = $null
$readTask = $null
$deadline = [DateTime]::UtcNow.AddSeconds($StartupTimeoutSeconds)

try {
    if (Test-Path -LiteralPath $RunDirectory) {
        throw "Refusing to reuse pre-existing smoke directory '$RunDirectory'."
    }
    New-Item -ItemType Directory -Path $RunDirectory | Out-Null
    $runDirectoryCreated = $true
    Copy-Item -LiteralPath $resolvedEulaSource -Destination $eulaDestination
    [System.IO.File]::WriteAllLines(
            (Join-Path $RunDirectory 'server.properties'),
            @(
                'online-mode=false',
                'spawn-protection=0',
                'view-distance=4',
                'simulation-distance=4'
            )
    )

    if (-not $process.Start()) {
        throw "Unable to start the Minecraft $TargetVersion server smoke test."
    }
    $processStarted = $true
    $process.StandardInput.AutoFlush = $true

    while (-not $process.HasExited) {
        if ([DateTime]::UtcNow -ge $deadline) {
            throw "Minecraft $TargetVersion did not finish its smoke test within $StartupTimeoutSeconds seconds."
        }

        if ($null -eq $readTask) {
            $readTask = $process.StandardOutput.ReadLineAsync()
        }
        if (-not $readTask.Wait(1000)) {
            continue
        }
        $line = $readTask.Result
        $readTask = $null
        if ($null -eq $line) {
            continue
        }
        $output.Add($line)
        $serverOutput.Add($line)
        Write-Host $line

        if (-not $serverReady -and $line -match '\bDone \(') {
            $serverReady = $true
            foreach ($command in $startupCommands) {
                $output.Add(">>> $command")
                Write-Host ">>> $command" -ForegroundColor Cyan
                $process.StandardInput.WriteLine($command)
                Start-Sleep -Milliseconds $CommandDelayMilliseconds
            }
        } elseif ($serverReady -and -not $gameplayCommandsSent -and $line -match '\bNotch joined the game\b') {
            $gameplayCommandsSent = $true
            foreach ($command in $gameplayCommands) {
                $output.Add(">>> $command")
                Write-Host ">>> $command" -ForegroundColor Cyan
                $process.StandardInput.WriteLine($command)
                $delay = if ($extendedCommandDelays.ContainsKey($command)) {
                    [int]$extendedCommandDelays[$command]
                } else {
                    $CommandDelayMilliseconds
                }
                Start-Sleep -Milliseconds $delay
            }
            $output.Add('>>> stop')
            Write-Host '>>> stop' -ForegroundColor Cyan
            $process.StandardInput.WriteLine('stop')
        }
    }

    while (-not $process.StandardOutput.EndOfStream) {
        $line = $process.StandardOutput.ReadLine()
        if ($null -ne $line) {
            $output.Add($line)
            $serverOutput.Add($line)
            Write-Host $line
        }
    }
    $exitCode = $process.ExitCode
} finally {
    if ($processStarted -and -not $process.HasExited) {
        & taskkill.exe /PID $process.Id /T /F 2>$null | Out-Null
        [void]$process.WaitForExit(10000)
    }
    [System.IO.File]::WriteAllLines($EvidencePath, $output)
    $process.Dispose()
    if ($CleanRunDirectory -and $runDirectoryCreated -and (Test-Path -LiteralPath $RunDirectory)) {
        try {
            $expectedRunRoot = [System.IO.Path]::GetFullPath($RunRoot).TrimEnd('\')
            $resolvedRunDirectory = (Resolve-Path -LiteralPath $RunDirectory).Path.TrimEnd('\')
            if (-not $resolvedRunDirectory.StartsWith($expectedRunRoot + '\', [System.StringComparison]::OrdinalIgnoreCase) -or
                    (Split-Path -Leaf $resolvedRunDirectory) -ne $RunDirectoryName -or
                    -not $RunDirectoryName.StartsWith("$TargetVersion-smoke-", [System.StringComparison]::Ordinal)) {
                throw "Refusing to remove unexpected run directory '$resolvedRunDirectory'."
            }
            Remove-Item -LiteralPath $resolvedRunDirectory -Recurse -Force
            Write-Host "Removed generated test server directory: $resolvedRunDirectory" -ForegroundColor Green
        } catch {
            $cleanupErrorMessage = "Unable to remove generated smoke directory '$RunDirectory': $($_.Exception.Message)"
            Write-Warning $cleanupErrorMessage
        }
    }
}

if ($null -ne $cleanupErrorMessage) {
    throw $cleanupErrorMessage
}
if (-not $serverReady) {
    throw "Minecraft $TargetVersion exited before reaching a ready server state. Evidence: $EvidencePath"
}
if ($exitCode -ne 0) {
    throw "Minecraft $TargetVersion server process exited with code $exitCode. Evidence: $EvidencePath"
}

$combinedOutput = $serverOutput -join "`n"
foreach ($marker in $requiredMarkers) {
    if ($combinedOutput -notmatch [regex]::Escape($marker)) {
        throw "Minecraft $TargetVersion did not produce required marker '$marker'. Evidence: $EvidencePath"
    }
}
foreach ($pattern in $forbiddenPatterns) {
    if ($combinedOutput -match $pattern) {
        throw "Minecraft $TargetVersion emitted forbidden server output '$pattern'. Evidence: $EvidencePath"
    }
}
if ($combinedOutput -notmatch '(?:Gave|Unlocked) 1 recipe') {
    throw "Minecraft $TargetVersion did not confirm the renewable recipe was loaded. Evidence: $EvidencePath"
}

Write-Host "Minecraft $TargetVersion server smoke passed: rule-on, rule-off, spectator, recipe cache invalidation, and clean shutdown." -ForegroundColor Green
Write-Host "Evidence: $EvidencePath" -ForegroundColor Green
