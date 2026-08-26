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
$FixtureNamespace = 'zzzz_carpetlir_smoke'
$FixtureFallbackRecipePath = 'zzzz_gravel_to_cobblestone_smelting_fallback'
$FixtureStagingRoot = Join-Path $RunDirectory 'smoke-fixture-datapack'
$FixtureInstallRoot = Join-Path $RunDirectory 'world\datapacks\carpetlir-smoke'
$InstallFixtureCommand = '__INSTALL_RECIPE_FALLBACK_FIXTURE__'
$WaitForPistonSettleCommand = '__WAIT_FOR_PISTON_SETTLE__'
$WaitForEntitySettleCommand = '__WAIT_FOR_ENTITY_SETTLE__'
$PistonDisabledExtendedProbeCommand = 'execute if block 0 103 0 minecraft:piston[extended=true] run say CARPETLIR_PISTON_DISABLED_EXTENDED_PASS'
$PistonDisabledDestroyedProbeCommand = 'execute unless block 1 103 0 minecraft:budding_amethyst run say CARPETLIR_PISTON_DISABLED_DESTROYED_PASS'
$PistonEnabledExtendedProbeCommand = 'execute if block 0 103 0 minecraft:piston[extended=true] run say CARPETLIR_PISTON_ENABLED_EXTENDED_PASS'
$PistonEnabledDestroyedProbeCommand = 'execute unless block 1 103 0 minecraft:budding_amethyst run say CARPETLIR_PISTON_ENABLED_DESTROYED_PASS'
$PistonDropProbeCommand = 'execute if entity @e[type=minecraft:item,nbt={Item:{id:"minecraft:budding_amethyst"}}] run say CARPETLIR_PISTON_ENABLED_DROP_PASS'

if (-not (Test-Path -LiteralPath $ProfilePath -PathType Leaf)) {
    throw "Unknown or non-build-ready target '$TargetVersion'."
}
$profile = ConvertFrom-StringData (Get-Content -LiteralPath $ProfilePath -Raw)
if ([string]$profile.source_family -ne 'legacy-yarn' -or [int]$profile.java_version -lt 17) {
    throw "Target '$TargetVersion' is not supported by the audited Yarn server smoke harness."
}
$recipeSchema = if ($profile.ContainsKey('recipe_schema')) {
    [string]$profile.recipe_schema
} else {
    'modern-shorthand-result-id'
}
$recipeDirectory = if ($profile.ContainsKey('recipe_directory')) {
    [string]$profile.recipe_directory
} else {
    'recipe'
}
if ($recipeSchema -notin @(
        'modern-shorthand-result-id',
        'ingredient-objects-result-id',
        'ingredient-objects-legacy-result'
)) {
    throw "Target '$TargetVersion' has unsupported recipe schema '$recipeSchema'."
}
if ($recipeDirectory -notin @('recipe', 'recipes')) {
    throw "Target '$TargetVersion' has unsupported recipe directory '$recipeDirectory'."
}
$isTier119 = [string]$profile.capability_tier -eq 'tier-1.19'
$dataPackFormats = @{
    '1.19.3' = 10
    '1.19.4' = 12
    '1.20' = 15
    '1.20.1' = 15
    '1.20.2' = 18
    '1.20.3' = 26
    '1.20.4' = 26
    '1.20.5' = 41
    '1.20.6' = 41
    '1.21' = 48
    '1.21.1' = 48
    '1.21.2' = 57
    '1.21.3' = 57
    '1.21.4' = 61
    '1.21.5' = 71
    '1.21.6' = 80
    '1.21.7' = 81
    '1.21.8' = 81
    '1.21.9' = 88
    '1.21.10' = 88
    '1.21.11' = 94
}
if (-not $dataPackFormats.ContainsKey($TargetVersion)) {
    throw "Target '$TargetVersion' has no audited data-pack format for the recipe fallback fixture."
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

$hardnessDisabledCommand = "script run if(hardness(10,101,6)==55 && hardness(11,101,6)==50,run('say CARPETLIR_HARDNESS_DISABLED_PASS'))"
$hardnessEnabledCommand = "script run if(hardness(10,101,6)==50 && hardness(11,101,6)==50,run('say CARPETLIR_HARDNESS_ENABLED_PASS'))"
$silkEnabledDropProbeCommand = 'execute if block 10 101 6 minecraft:air if entity @e[type=minecraft:item,x=10.5,y=101.5,z=6.5,distance=..2,nbt={Item:{id:"minecraft:reinforced_deepslate",Count:1b}}] run say CARPETLIR_SILK_ENABLED_PASS'
$wardenDropPresentProbeCommand = 'execute if entity @e[type=minecraft:item,x=12.5,y=101,z=12.5,distance=..4,nbt={Item:{id:"minecraft:reinforced_deepslate"}}] run say CARPETLIR_WARDEN_DROP_PRESENT'
$mangroveRecipeGiveCommand = 'recipe give Notch carpetlir:mangrove_leaves_from_mangrove_log_and_sticks'

$startupCommands = @(
    'forceload add 0 0',
    'fill -2 100 -2 4 104 4 minecraft:air',
    'setblock 0 100 0 minecraft:stone',
    'setblock 0 101 2 minecraft:dirt',
    'carpet boneMealGrassifyDirt true',
    'player Notch spawn'
)
$tier119Commands = @()
if ($isTier119) {
    $startupCommands += @(
        'fill 8 100 0 15 104 15 minecraft:air',
        'fill 8 100 0 15 100 15 minecraft:stone',
        'scoreboard objectives add clrSmoke dummy'
    )
    $tier119Commands = @(
        'clear Notch',
        'carpet renewableLeavesCrafting true',
        $mangroveRecipeGiveCommand,
        'say CARPETLIR_MANGROVE_RESOURCE_PASS',
        'carpet renewableLeavesCrafting false',
        'clear Notch',
        'setblock 10 101 6 minecraft:reinforced_deepslate',
        'setblock 11 101 6 minecraft:obsidian',
        'carpet obsidianHardnessReinforcedDeepslate false',
        $hardnessDisabledCommand,
        'carpet obsidianHardnessReinforcedDeepslate true',
        $hardnessEnabledCommand,
        'carpet obsidianHardnessReinforcedDeepslate false',
        'setblock 10 101 6 minecraft:air',
        'setblock 11 101 6 minecraft:air',
        'gamemode survival Notch',
        'tp Notch 10.5 101 2.5',
        'player Notch look at 10.5 101.5 6.5',
        'effect give Notch minecraft:haste 120 255 true',
        'execute as @e[type=minecraft:item] run kill @s',
        'clear Notch minecraft:reinforced_deepslate',
        'item replace entity Notch weapon.mainhand with minecraft:diamond_pickaxe',
        'carpet silkTouchableReinforcedDeepslate true',
        'setblock 10 101 6 minecraft:reinforced_deepslate',
        'player Notch attack continuous',
        'player Notch stop',
        $WaitForEntitySettleCommand,
        'execute if block 10 101 6 minecraft:air unless entity @e[type=minecraft:item,nbt={Item:{id:"minecraft:reinforced_deepslate"}}] unless entity @a[name=Notch,nbt={Inventory:[{id:"minecraft:reinforced_deepslate"}]}] run say CARPETLIR_SILK_NON_SILK_PASS',
        'execute as @e[type=minecraft:item] run kill @s',
        'clear Notch minecraft:reinforced_deepslate',
        'item replace entity Notch weapon.mainhand with minecraft:diamond_pickaxe',
        'enchant Notch minecraft:silk_touch 1',
        'carpet silkTouchableReinforcedDeepslate false',
        'setblock 10 101 6 minecraft:reinforced_deepslate',
        'player Notch attack continuous',
        'player Notch stop',
        $WaitForEntitySettleCommand,
        'execute if block 10 101 6 minecraft:air unless entity @e[type=minecraft:item,nbt={Item:{id:"minecraft:reinforced_deepslate"}}] unless entity @a[name=Notch,nbt={Inventory:[{id:"minecraft:reinforced_deepslate"}]}] run say CARPETLIR_SILK_DISABLED_PASS',
        'execute as @e[type=minecraft:item] run kill @s',
        'clear Notch minecraft:reinforced_deepslate',
        'item replace entity Notch weapon.mainhand with minecraft:diamond_pickaxe',
        'enchant Notch minecraft:silk_touch 1',
        'carpet silkTouchableReinforcedDeepslate true',
        'setblock 10 101 6 minecraft:reinforced_deepslate',
        'player Notch attack continuous',
        'player Notch stop',
        $WaitForEntitySettleCommand,
        $silkEnabledDropProbeCommand,
        'execute as @e[type=minecraft:item] run kill @s',
        'carpet silkTouchableReinforcedDeepslate false',
        'effect clear Notch minecraft:haste',
        'gamemode spectator Notch',
        'tp Notch 0.5 101 0.5',
        'execute as @e[type=minecraft:item] run kill @s',
        'gamerule doMobLoot true',
        'carpet wardensDropReinforcedDeepslate false',
        'summon minecraft:warden 12.5 101 12.5 {Tags:["clrWardenOff"],NoAI:1b,Silent:1b,PersistenceRequired:1b}',
        'execute if entity @e[type=minecraft:warden,tag=clrWardenOff,x=12.5,y=101,z=12.5,distance=..2] run say CARPETLIR_WARDEN_OFF_SPAWNED',
        'kill @e[type=minecraft:warden,tag=clrWardenOff,limit=1]',
        $WaitForEntitySettleCommand,
        'execute unless entity @e[type=minecraft:warden,tag=clrWardenOff] unless entity @e[type=minecraft:item,nbt={Item:{id:"minecraft:reinforced_deepslate"}}] run say CARPETLIR_WARDEN_DISABLED_PASS',
        'execute as @e[type=minecraft:item] run kill @s',
        'gamerule doMobLoot false',
        'carpet wardensDropReinforcedDeepslate true',
        'summon minecraft:warden 12.5 101 12.5 {Tags:["clrWardenNoLoot"],NoAI:1b,Silent:1b,PersistenceRequired:1b}',
        'execute if entity @e[type=minecraft:warden,tag=clrWardenNoLoot,x=12.5,y=101,z=12.5,distance=..2] run say CARPETLIR_WARDEN_NOLOOT_SPAWNED',
        'kill @e[type=minecraft:warden,tag=clrWardenNoLoot,limit=1]',
        $WaitForEntitySettleCommand,
        'execute unless entity @e[type=minecraft:warden,tag=clrWardenNoLoot] unless entity @e[type=minecraft:item,nbt={Item:{id:"minecraft:reinforced_deepslate"}}] run say CARPETLIR_WARDEN_NOLOOT_PASS',
        'execute as @e[type=minecraft:item] run kill @s',
        'gamerule doMobLoot true',
        'carpet wardensDropReinforcedDeepslate true',
        'summon minecraft:warden 12.5 101 12.5 {Tags:["clrWardenOn"],NoAI:1b,Silent:1b,PersistenceRequired:1b}',
        'execute if entity @e[type=minecraft:warden,tag=clrWardenOn,x=12.5,y=101,z=12.5,distance=..2] run say CARPETLIR_WARDEN_ON_SPAWNED',
        'kill @e[type=minecraft:warden,tag=clrWardenOn,limit=1]',
        $WaitForEntitySettleCommand,
        $wardenDropPresentProbeCommand,
        'scoreboard players set #warden_entities clrSmoke 0',
        'execute as @e[type=minecraft:item,x=12.5,y=101,z=12.5,distance=..4,nbt={Item:{id:"minecraft:reinforced_deepslate"}}] run scoreboard players add #warden_entities clrSmoke 1',
        'scoreboard players set #warden_count clrSmoke -1',
        'execute store result score #warden_count clrSmoke run data get entity @e[type=minecraft:item,x=12.5,y=101,z=12.5,distance=..4,limit=1,nbt={Item:{id:"minecraft:reinforced_deepslate"}}] Item.Count 1',
        'execute if score #warden_entities clrSmoke matches 1 if score #warden_count clrSmoke matches 1..4 run say CARPETLIR_WARDEN_ENABLED_PASS',
        'execute as @e[type=minecraft:item] run kill @s',
        'carpet wardensDropReinforcedDeepslate false',
        'gamerule doMobLoot true'
    )
}
$preTierGameplayCommands = @(
    'tp Notch 0.5 101 0.5',
    'effect give Notch minecraft:water_breathing 1000000 0 true',
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
    'item replace block 2 101 2 container.0 with minecraft:gravel 1',
    'item replace block 2 101 2 container.1 with minecraft:coal 1',
    'execute if data block 2 101 2 Items[{Slot:2b,id:"minecraft:tuff"}] run say CARPETLIR_RECIPE_ENABLED_PASS',
    $InstallFixtureCommand,
    'clear Notch minecraft:tuff',
    'clear Notch minecraft:cobblestone',
    'loot give Notch loot zzzz_carpetlir_smoke:direct_recipe_fallback',
    'execute if entity @a[name=Notch,nbt={Inventory:[{id:"minecraft:tuff"}]}] run say CARPETLIR_RECIPE_DIRECT_ENABLED_PASS',
    'clear Notch minecraft:tuff',
    'clear Notch minecraft:cobblestone',
    'item replace block 2 101 2 container.2 with minecraft:air',
    'carpet renewableTuff false',
    'item replace block 2 101 2 container.0 with minecraft:gravel 2',
    'execute if data block 2 101 2 Items[{Slot:2b,id:"minecraft:cobblestone"}] run say CARPETLIR_RECIPE_CACHED_FALLBACK_PASS',
    'clear Notch minecraft:cobblestone',
    'loot give Notch loot zzzz_carpetlir_smoke:direct_recipe_fallback',
    'execute if entity @a[name=Notch,nbt={Inventory:[{id:"minecraft:cobblestone"}]}] run say CARPETLIR_RECIPE_DIRECT_FALLBACK_PASS'
)
$postTierGameplayCommands = @(
    'gamemode spectator Notch',
    'tp Notch 10.5 101 10.5',
    'execute as @e[type=minecraft:item] run kill @s',
    'carpet pistonHarvestableAmethysts false',
    'setblock -1 103 0 minecraft:air',
    'setblock 0 103 0 minecraft:piston[facing=east]',
    'setblock 1 103 0 minecraft:budding_amethyst',
    'setblock -1 103 0 minecraft:redstone_block',
    $PistonDisabledExtendedProbeCommand,
    $PistonDisabledDestroyedProbeCommand,
    'setblock -1 103 0 minecraft:air',
    $WaitForPistonSettleCommand,
    'execute unless entity @e[type=minecraft:item,nbt={Item:{id:"minecraft:budding_amethyst"}}] run say CARPETLIR_PISTON_DISABLED_NO_DROP_PASS',
    'setblock 0 103 0 minecraft:air',
    'setblock 1 103 0 minecraft:air',
    'carpet pistonHarvestableAmethysts true',
    'setblock 0 103 0 minecraft:piston[facing=east]',
    'setblock 1 103 0 minecraft:budding_amethyst',
    'setblock -1 103 0 minecraft:redstone_block',
    $PistonEnabledExtendedProbeCommand,
    $PistonEnabledDestroyedProbeCommand,
    'setblock -1 103 0 minecraft:air',
    $WaitForPistonSettleCommand,
    $PistonDropProbeCommand,
    'setblock 0 103 0 minecraft:air',
    'setblock 1 103 0 minecraft:air',
    'execute as @e[type=minecraft:item] run kill @s',
    'carpet pistonHarvestableAmethysts false',
    'gamemode survival Notch',
    'tp Notch 0.5 101 0.5',
    'player Notch kill',
    'say CARPETLIR_SMOKE_COMPLETE'
)
$gameplayCommands = @($preTierGameplayCommands + $tier119Commands + $postTierGameplayCommands)
$extendedCommandDelays = @{
    'item replace block 2 101 2 container.1 with minecraft:coal 1' = 12000
    'item replace block 2 101 2 container.0 with minecraft:gravel 2' = 12000
    'setblock -1 103 0 minecraft:redstone_block' = 1200
    'player Notch attack continuous' = 2000
}
$markerProbeCommands = @{
    $PistonDisabledExtendedProbeCommand = 'CARPETLIR_PISTON_DISABLED_EXTENDED_PASS'
    $PistonDisabledDestroyedProbeCommand = 'CARPETLIR_PISTON_DISABLED_DESTROYED_PASS'
    $PistonEnabledExtendedProbeCommand = 'CARPETLIR_PISTON_ENABLED_EXTENDED_PASS'
    $PistonEnabledDestroyedProbeCommand = 'CARPETLIR_PISTON_ENABLED_DESTROYED_PASS'
    $PistonDropProbeCommand = 'CARPETLIR_PISTON_ENABLED_DROP_PASS'
}
if ($isTier119) {
    $markerProbeCommands[$silkEnabledDropProbeCommand] = 'CARPETLIR_SILK_ENABLED_PASS'
    $markerProbeCommands[$wardenDropPresentProbeCommand] = 'CARPETLIR_WARDEN_DROP_PRESENT'
}
$commandOutputMarkers = @{}
if ($isTier119) {
    $commandOutputMarkers[$mangroveRecipeGiveCommand] = 'Unlocked 1 recipes for Notch'
}
$requiredMarkers = @(
    'CARPETLIR_BONEMEAL_ENABLED_PASS',
    'CARPETLIR_BONEMEAL_SNOWY_PASS',
    'CARPETLIR_BONEMEAL_DISABLED_PASS',
    'CARPETLIR_BONEMEAL_SPECTATOR_PASS',
    'CARPETLIR_RECIPE_ENABLED_PASS',
    'CARPETLIR_RECIPE_DIRECT_ENABLED_PASS',
    'CARPETLIR_RECIPE_CACHED_FALLBACK_PASS',
    'CARPETLIR_RECIPE_DIRECT_FALLBACK_PASS',
    'CARPETLIR_PISTON_DISABLED_EXTENDED_PASS',
    'CARPETLIR_PISTON_DISABLED_DESTROYED_PASS',
    'CARPETLIR_PISTON_DISABLED_NO_DROP_PASS',
    'CARPETLIR_PISTON_ENABLED_EXTENDED_PASS',
    'CARPETLIR_PISTON_ENABLED_DESTROYED_PASS',
    'CARPETLIR_PISTON_ENABLED_DROP_PASS',
    'Notch lost connection: Killed',
    'CARPETLIR_SMOKE_COMPLETE'
)
if ($isTier119) {
    $requiredMarkers += @(
        'CARPETLIR_MANGROVE_RESOURCE_PASS',
        'CARPETLIR_HARDNESS_DISABLED_PASS',
        'CARPETLIR_HARDNESS_ENABLED_PASS',
        'CARPETLIR_SILK_NON_SILK_PASS',
        'CARPETLIR_SILK_DISABLED_PASS',
        'CARPETLIR_SILK_ENABLED_PASS',
        'CARPETLIR_WARDEN_OFF_SPAWNED',
        'CARPETLIR_WARDEN_DISABLED_PASS',
        'CARPETLIR_WARDEN_NOLOOT_SPAWNED',
        'CARPETLIR_WARDEN_NOLOOT_PASS',
        'CARPETLIR_WARDEN_ON_SPAWNED',
        'CARPETLIR_WARDEN_DROP_PRESENT',
        'CARPETLIR_WARDEN_ENABLED_PASS'
    )
}
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
    'Unknown loot table',
    "Can't find element",
    "Couldn't parse data file",
    'pack metadata:',
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
$gameplayCommandsStarted = $false
$gameplayCommandIndex = 0
$nextGameplayCommandAt = [DateTime]::MaxValue
$waitingForRecipeReload = $false
$recipeReloadDeadline = [DateTime]::MaxValue
$waitingForCommandMarker = $false
$commandMarker = $null
$commandMarkerProbe = $null
$commandMarkerDeadline = [DateTime]::MaxValue
$nextCommandMarkerProbeAt = [DateTime]::MaxValue
$stopSent = $false
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

    # Stage the fallback outside the world. It is installed only after the
    # controlled tuff recipe has produced once and populated the furnace cache.
    $fixtureRecipeDirectory = Join-Path $FixtureStagingRoot "data\$FixtureNamespace\$recipeDirectory"
    $lootDirectoryName = if ($recipeDirectory -eq 'recipe') { 'loot_table' } else { 'loot_tables' }
    $fixtureLootDirectory = Join-Path $FixtureStagingRoot "data\$FixtureNamespace\$lootDirectoryName"
    New-Item -ItemType Directory -Path $fixtureRecipeDirectory -Force | Out-Null
    New-Item -ItemType Directory -Path $fixtureLootDirectory -Force | Out-Null

    $fixtureIngredient = if ($recipeSchema -eq 'modern-shorthand-result-id') {
        'minecraft:gravel'
    } else {
        [ordered]@{ item = 'minecraft:gravel' }
    }
    $fixtureResult = if ($recipeSchema -eq 'ingredient-objects-legacy-result') {
        'minecraft:cobblestone'
    } else {
        [ordered]@{ id = 'minecraft:cobblestone' }
    }
    $fixtureRecipe = [ordered]@{
        type = 'minecraft:smelting'
        category = 'misc'
        ingredient = $fixtureIngredient
        result = $fixtureResult
        experience = 0.0
        cookingtime = 20
    }
    $fixtureLootTable = [ordered]@{
        type = 'minecraft:command'
        pools = @(
            [ordered]@{
                rolls = 1
                entries = @(
                    [ordered]@{
                        type = 'minecraft:item'
                        name = 'minecraft:gravel'
                        functions = @([ordered]@{ function = 'minecraft:furnace_smelt' })
                    }
                )
            }
        )
    }
    $fixturePack = [ordered]@{
        description = 'Disposable Carpet LIR recipe fallback smoke fixture'
    }
    if ($dataPackFormats[$TargetVersion] -le 81) {
        $fixturePack['pack_format'] = $dataPackFormats[$TargetVersion]
    } else {
        $fixturePack['min_format'] = $dataPackFormats[$TargetVersion]
        $fixturePack['max_format'] = $dataPackFormats[$TargetVersion]
    }
    $fixturePackMetadata = [ordered]@{ pack = $fixturePack }
    [System.IO.File]::WriteAllText(
            (Join-Path $FixtureStagingRoot 'pack.mcmeta'),
            ($fixturePackMetadata | ConvertTo-Json -Depth 20)
    )
    # Keep the fallback after carpetlir:gravel_to_tuff_smelting in both the
    # audited HashMap bucket ranges and newer sorted recipe maps. The enabled
    # direct-query assertion below still fails closed if ordering ever changes.
    [System.IO.File]::WriteAllText(
            (Join-Path $fixtureRecipeDirectory "$FixtureFallbackRecipePath.json"),
            ($fixtureRecipe | ConvertTo-Json -Depth 20)
    )
    [System.IO.File]::WriteAllText(
            (Join-Path $fixtureLootDirectory 'direct_recipe_fallback.json'),
            ($fixtureLootTable | ConvertTo-Json -Depth 20)
    )

    if (-not $process.Start()) {
        throw "Unable to start the Minecraft $TargetVersion server smoke test."
    }
    $processStarted = $true
    $process.StandardInput.AutoFlush = $true

    while (-not $process.HasExited) {
        $now = [DateTime]::UtcNow
        if ($now -ge $deadline) {
            throw "Minecraft $TargetVersion did not finish its smoke test within $StartupTimeoutSeconds seconds."
        }

        if ($waitingForRecipeReload -and $now -ge $recipeReloadDeadline) {
            throw "Minecraft $TargetVersion did not report a completed recipe reload within 60 seconds."
        }

        if ($waitingForCommandMarker) {
            if ($now -ge $commandMarkerDeadline) {
                throw "Minecraft $TargetVersion did not produce awaited marker '$commandMarker' within 10 seconds."
            }
            if ($null -ne $commandMarkerProbe -and $now -ge $nextCommandMarkerProbeAt) {
                $process.StandardInput.WriteLine($commandMarkerProbe)
                $nextCommandMarkerProbeAt = $now.AddMilliseconds(250)
            }
        }

        if ($gameplayCommandsStarted -and
                -not $waitingForRecipeReload -and
                -not $waitingForCommandMarker -and
                -not $stopSent -and
                $now -ge $nextGameplayCommandAt) {
            if ($gameplayCommandIndex -lt $gameplayCommands.Count) {
                $command = $gameplayCommands[$gameplayCommandIndex]
                $gameplayCommandIndex++

                if ($command -eq $InstallFixtureCommand) {
                    if (Test-Path -LiteralPath $FixtureInstallRoot) {
                        throw "Refusing to overwrite existing smoke fixture '$FixtureInstallRoot'."
                    }
                    Copy-Item -LiteralPath $FixtureStagingRoot -Destination $FixtureInstallRoot -Recurse
                    $output.Add('>>> [installed fallback fixture]')
                    Write-Host '>>> [installed fallback fixture]' -ForegroundColor Cyan
                    $output.Add('>>> reload')
                    Write-Host '>>> reload' -ForegroundColor Cyan
                    $process.StandardInput.WriteLine('reload')
                    $waitingForRecipeReload = $true
                    $recipeReloadDeadline = $now.AddSeconds(60)
                } elseif ($command -in @($WaitForPistonSettleCommand, $WaitForEntitySettleCommand)) {
                    $settleLabel = if ($command -eq $WaitForPistonSettleCommand) {
                        'piston cycle'
                    } else {
                        'entity state'
                    }
                    $output.Add(">>> [waiting for $settleLabel to settle]")
                    Write-Host ">>> [waiting for $settleLabel to settle]" -ForegroundColor Cyan
                    $nextGameplayCommandAt = $now.AddMilliseconds(2000)
                } else {
                    $output.Add(">>> $command")
                    Write-Host ">>> $command" -ForegroundColor Cyan
                    $process.StandardInput.WriteLine($command)
                    if ($markerProbeCommands.ContainsKey($command)) {
                        $waitingForCommandMarker = $true
                        $commandMarker = [string]$markerProbeCommands[$command]
                        $commandMarkerProbe = $command
                        $commandMarkerDeadline = $now.AddSeconds(10)
                        $nextCommandMarkerProbeAt = $now.AddMilliseconds(250)
                    } elseif ($commandOutputMarkers.ContainsKey($command)) {
                        $waitingForCommandMarker = $true
                        $commandMarker = [string]$commandOutputMarkers[$command]
                        $commandMarkerProbe = $null
                        $commandMarkerDeadline = $now.AddSeconds(10)
                    } else {
                        $delay = if ($extendedCommandDelays.ContainsKey($command)) {
                            [int]$extendedCommandDelays[$command]
                        } else {
                            $CommandDelayMilliseconds
                        }
                        $nextGameplayCommandAt = $now.AddMilliseconds($delay)
                    }
                }
            } else {
                $output.Add('>>> stop')
                Write-Host '>>> stop' -ForegroundColor Cyan
                $process.StandardInput.WriteLine('stop')
                $stopSent = $true
            }
        }

        if ($null -eq $readTask) {
            $readTask = $process.StandardOutput.ReadLineAsync()
        }
        if (-not $readTask.Wait(100)) {
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

        if ($waitingForRecipeReload -and $line -match '\bLoaded [0-9]+ recipes\b') {
            $waitingForRecipeReload = $false
            $reloadEvidence = $line
            $output.Add(">>> [reload complete: $reloadEvidence]")
            Write-Host ">>> [reload complete: $reloadEvidence]" -ForegroundColor Cyan
            $nextGameplayCommandAt = [DateTime]::UtcNow.AddMilliseconds($CommandDelayMilliseconds)
        }
        if ($waitingForCommandMarker -and $line -match [regex]::Escape($commandMarker)) {
            $waitingForCommandMarker = $false
            $output.Add(">>> [marker observed: $commandMarker]")
            Write-Host ">>> [marker observed: $commandMarker]" -ForegroundColor Cyan
            $nextGameplayCommandAt = [DateTime]::UtcNow.AddMilliseconds($CommandDelayMilliseconds)
        }

        if (-not $serverReady -and $line -match '\bDone \(') {
            $serverReady = $true
            foreach ($command in $startupCommands) {
                $output.Add(">>> $command")
                Write-Host ">>> $command" -ForegroundColor Cyan
                $process.StandardInput.WriteLine($command)
                Start-Sleep -Milliseconds $CommandDelayMilliseconds
            }
        } elseif ($serverReady -and -not $gameplayCommandsStarted -and $line -match '\bNotch joined the game\b') {
            $gameplayCommandsStarted = $true
            $nextGameplayCommandAt = [DateTime]::UtcNow
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
            $runCleanupError = "Unable to remove generated smoke directory '$RunDirectory': $($_.Exception.Message)"
            $cleanupErrorMessage = if ($null -eq $cleanupErrorMessage) {
                $runCleanupError
            } else {
                "$cleanupErrorMessage $runCleanupError"
            }
            Write-Warning $runCleanupError
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

$coverageSummary = if ($isTier119) {
    'dirt rule states, cached/direct recipe fallbacks, mangrove resource, hardness, real Silk Touch mining, Warden loot gates, piston negative/positive paths, and clean shutdown'
} else {
    'dirt rule states, cached/direct recipe fallbacks, piston negative/positive paths, and clean shutdown'
}
Write-Host "Minecraft $TargetVersion server smoke passed: $coverageSummary." -ForegroundColor Green
Write-Host "Evidence: $EvidencePath" -ForegroundColor Green
