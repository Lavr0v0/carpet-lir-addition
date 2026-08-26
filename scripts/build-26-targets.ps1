param(
    [string[]]$Targets = @('26.1', '26.1.1', '26.1.2', '26.2'),
    [switch]$SkipTests,
    [switch]$RequireCleanGit
)

$ErrorActionPreference = 'Stop'
$AuditedBuilder = Join-Path $PSScriptRoot 'build-audited-targets.ps1'
$arguments = @{
    RootTargets = $Targets
    SkipClassic = $true
    SkipTests = $SkipTests.IsPresent
    RequireCleanGit = $RequireCleanGit.IsPresent
}

& $AuditedBuilder @arguments
