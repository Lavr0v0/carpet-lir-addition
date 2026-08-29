# Carpet LIR Addition

Carpet LIR Addition is a server-authoritative Fabric Carpet extension focused on renewable-item survival mechanics. It adds no custom screens or client rendering, and every behavior is guarded by a Carpet rule that defaults to `false`.

All 43 exact Minecraft releases in the stable Fabric Carpet catalog now have current build paths: 42 root Gradle profiles plus the isolated classic target. Minecraft 1.14.4 is a runtime-verified Java 8 classic build containing only its two available rules. Minecraft 1.15 through 1.16.5 are exact Java 8 `tier-1.15` builds containing only three rules and seven recipes. Minecraft 1.17 through 1.18.2 retain only the eight rules and twelve recipes available in their `tier-1.17` capability set. Minecraft 1.15 through 1.21.11 have audited builds and focused server coverage but remain `build-only` until gameplay GameTests are ported. Minecraft 26.1, 26.1.1, and 26.1.2 retain the 11-rule tier, while Minecraft 26.2 exposes the 12-rule `tier-26.2`; both lines pass their current unit and server GameTest suites. Every target receives its own JAR with exact dependency metadata; there is no fake all-version JAR.

The support catalog covers all 35 stable Fabric Carpet coordinates from Minecraft 1.14.4 through 26.2, representing 43 Minecraft releases. Every current adapter is selected by capability tier: unavailable rules, classes, mixins, recipes, and translations are removed rather than registered as no-op features. See [the multi-version support model](docs/MULTIVERSION.md) for the verified and build-only distinctions.

## Installation

Put the Carpet LIR Addition JAR matching the server's exact Minecraft version in the `mods` folder together with compatible versions of Fabric Loader, Fabric API, and Fabric Carpet. The same JAR may be installed on a client joining the server, but all gameplay behavior is decided by the server.

## Rules

On current Carpet generations, rules are managed through Carpet's normal `/carpet` command. Querying a rule shows its current value and description:

```text
/carpet renewableCalcite
```

A direct assignment changes only the current server session:

```text
/carpet renewableCalcite true
```

Persist a value across restarts with `setDefault`; this also applies the value immediately. Remove the saved override to return the rule to its code default (`false`):

```text
/carpet setDefault renewableCalcite true
/carpet removeDefault renewableCalcite
```

The Java 8 adapters for Minecraft 1.14.4 and 1.15–1.16.5 use the older extension-owned settings API. Replace `/carpet` with `/carpetlir` for queries, temporary assignments, `setDefault`, and `removeDefault`; see the [classic target guide](classic/1.14.4/README.md) for the separately built 1.14.4 target. Other current root-profile adapters use `/carpet`.

| Rule | First target | Effect |
| --- | --- | --- |
| `renewableCalcite` | 1.17 | After the rule is enabled, placing or updating lava converts it to calcite when a bone block is directly below and a regular amethyst block is horizontally adjacent or directly above. Water is not required. |
| `renewableCinnabar` | 26.2 | Lava touching water generates cinnabar when potent sulfur is directly below it and netherrack is horizontally adjacent. The two catalyst blocks are not consumed. |
| `renewableTuff` | 1.17 | Enables smelting one gravel into one tuff. |
| `renewableLapisOre` | 1.17 | Enables crafting eight calcite around one amethyst shard into one lapis ore. |
| `renewableLeavesCrafting` | 1.14.4 | Enables recipes for four sticks plus a matching log to produce four leaves. The six original trees are always included; mangrove, cherry, and pale oak join only after vanilla adds them. |
| `renewableRawOresCrafting` | 1.17 | Enables eight cobblestone plus an ingot to produce the matching raw iron, copper, or gold. |
| `renewableHoneycombCrafting` | 1.15 | Enables converting one honeycomb block back into four honeycombs. |
| `boneMealGrassifyDirt` | 1.14.4 | Bone meal converts dirt into grass only where grass can actually survive, with vanilla feedback and item consumption. |
| `obsidianHardnessReinforcedDeepslate` | 1.19 | Changes only reinforced deepslate's mining speed and progress to match obsidian; it does not add a drop or renewable source. |
| `silkTouchableReinforcedDeepslate` | 1.19 | Recovers an existing reinforced deepslate block when it is mined with Silk Touch; it does not create a new block. |
| `wardensDropReinforcedDeepslate` | 1.19 | Provides the renewable source: Wardens drop 1–4 reinforced deepslate on death when mob loot is enabled. |
| `pistonHarvestableAmethysts` | 1.17 | Lets a piston harvest an existing budding amethyst; it does not make budding amethyst renewable. |

### Avoiding common rule misunderstandings

- `renewableCalcite` does not use water. Build the minimum test with bone directly below the target lava position and a regular `minecraft:amethyst_block` on a horizontal side or directly above. Enable the rule first, then place or update the lava; toggling the rule does not retroactively scan and replace existing lava, obsidian, cobblestone, or basalt.
- There is no single "renewable deepslate" rule. The three reinforced-deepslate rules are independent: the hardness rule changes mining only, the Silk Touch rule recovers a finite existing block, and only the Warden-drop rule creates a repeatable source of new reinforced deepslate.

All rules use the `LIR` and `FEATURE` categories and default to `false`. Rules that create a repeatable resource source also use `RENEWABLE`; the reinforced-deepslate hardness, Silk Touch recovery, and budding-amethyst piston recovery rules deliberately do not. A rule introduced after the selected Minecraft version is absent from that JAR rather than shown as a setting that cannot work.

## Development and verification

The builds pin both compilation and runtime to the Java generation required by each Minecraft line: Java 8 for 1.14.4 and 1.15–1.16.5, Java 16 for 1.17–1.17.1, Java 17 for 1.18–1.20.4, Java 21 for 1.20.5–1.21.11, and Java 25 for 26.x. Gradle resolves toolchains automatically when necessary, and the disposable server harness rejects a run whose Fabric log reports the wrong Java major version. The first build therefore needs network access, and real Java 8 server smokes must themselves run on Java 8 because those generations' Mixin runtimes cannot parse modern host classes.

Root-profile development servers and GameTests use `run/<target>` rather than one shared world directory. This keeps worlds, logs, and generated server state from incompatible Minecraft data formats isolated.
The disposable smoke harness requires an EULA file that the user has already accepted. Pass it with `-EulaSourcePath` when the repository does not yet contain one under `run/`.

```powershell
# Fast logic and resource checks
.\gradlew.bat test

# Start a real Fabric test server and exercise gameplay behavior
.\gradlew.bat runGameTest

# Compile, test, remap, and package the release jars
.\gradlew.bat build

# Select one audited 26.x target
.\gradlew.bat clean build '-PtargetVersion=26.1.2'

# Build exact current Yarn targets
.\gradlew.bat clean build '-PtargetVersion=1.15'
.\gradlew.bat clean build '-PtargetVersion=1.15.1'
.\gradlew.bat clean build '-PtargetVersion=1.15.2'
.\gradlew.bat clean build '-PtargetVersion=1.16'
.\gradlew.bat clean build '-PtargetVersion=1.16.1'
.\gradlew.bat clean build '-PtargetVersion=1.16.2'
.\gradlew.bat clean build '-PtargetVersion=1.16.3'
.\gradlew.bat clean build '-PtargetVersion=1.16.4'
.\gradlew.bat clean build '-PtargetVersion=1.16.5'
.\gradlew.bat clean build '-PtargetVersion=1.17'
.\gradlew.bat clean build '-PtargetVersion=1.17.1'
.\gradlew.bat clean build '-PtargetVersion=1.18'
.\gradlew.bat clean build '-PtargetVersion=1.18.1'
.\gradlew.bat clean build '-PtargetVersion=1.18.2'
.\gradlew.bat clean build '-PtargetVersion=1.19'
.\gradlew.bat clean build '-PtargetVersion=1.19.1'
.\gradlew.bat clean build '-PtargetVersion=1.19.2'
.\gradlew.bat clean build '-PtargetVersion=1.19.3'
.\gradlew.bat clean build '-PtargetVersion=1.19.4'
.\gradlew.bat clean build '-PtargetVersion=1.20'
.\gradlew.bat clean build '-PtargetVersion=1.20.1'
.\gradlew.bat clean build '-PtargetVersion=1.20.2'
.\gradlew.bat clean build '-PtargetVersion=1.20.3'
.\gradlew.bat clean build '-PtargetVersion=1.20.4'
.\gradlew.bat clean build '-PtargetVersion=1.20.5'
.\gradlew.bat clean build '-PtargetVersion=1.20.6'
.\gradlew.bat clean build '-PtargetVersion=1.21'
.\gradlew.bat clean build '-PtargetVersion=1.21.2'
.\gradlew.bat clean build '-PtargetVersion=1.21.4'
.\gradlew.bat clean build '-PtargetVersion=1.21.6'
.\gradlew.bat clean build '-PtargetVersion=1.21.9'
.\gradlew.bat clean build '-PtargetVersion=1.21.11'

# Exercise a modern Yarn target on a real disposable server, then remove its generated world
powershell -ExecutionPolicy Bypass -File .\scripts\smoke-test-modern-server.ps1 -TargetVersion 1.21.9 -EulaSourcePath .\run\1.21.11\eula.txt -CleanRunDirectory

# Build the isolated Java 8 classic adapter
.\gradlew.bat -p classic\1.14.4 clean build

# Build, test, inspect, and collect all forty-three current artifacts locally
powershell -ExecutionPolicy Bypass -File .\scripts\build-audited-targets.ps1

# Release acceptance requires an unchanged, committed source tree
powershell -ExecutionPolicy Bypass -File .\scripts\build-audited-targets.ps1 -RequireCleanGit

# Revalidate a collected complete release before upload
powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-bundle.ps1 -RequireCompleteCatalog

# Compatibility wrapper for only the four audited 26.x artifacts
powershell -ExecutionPolicy Bypass -File .\scripts\build-26-targets.ps1

# Validate the full support/capability catalog against official Carpet Maven
powershell -ExecutionPolicy Bypass -File .\scripts\validate-version-matrix.ps1 -VerifyMaven
```

The automated suite checks rule visibility and conservative defaults, recipe-to-rule coverage, translation parity, legacy translation-key conversion, live recipe toggling, calcite enabled/disabled/missing-catalyst paths and 26.2 cinnabar generation, dirt conversion (including snowy state and spectator denial), reinforced-deepslate hardness, Warden drops and `mob_drops`, and real piston activation. Disposable-server smokes cover Minecraft 1.15–1.19.4, 1.20–1.20.6, and 1.21–1.21.11. Combined unit and JAR audits prove the exact three-rule/seven-recipe Minecraft 1.15–1.16.5 capability boundary. The nine Java 8 server runs prove `/carpetlir` registration, survival bone-meal consumption, enabled/snowy/disabled/spectator dirt behavior, and enabled/direct plus disabled same-furnace/direct honeycomb recipe fallback. Calcite and piston assertions begin at Minecraft 1.17; cinnabar assertions run only where Minecraft 26.2 supplies cinnabar and potent sulfur. Combined audits prove the eight-rule/twelve-recipe tier-1.17 boundary; the five 1.17–1.18.2 server runs exercise representative interactions from that tier, their direct three-parameter recipe lookup adapter, and the declared Java 16 or Java 17 toolchain. The five 1.19 runs and the focused 1.21.11 regression run prove the mangrove recipe is visible to the server, the 55-to-50 hardness change, three real fake-player Silk Touch mining paths, and the Warden rule-off, mob-drops-disabled, and 1–4-drop paths. Minecraft 1.19/1.19.1 prove the fallback death Mixin on Fabric API 0.58.x, while 1.19.2–1.19.4 prove the later Fabric server death event. Enhanced runs on direct-only recipe APIs verify same-furnace and direct fallbacks, while cache-bearing recipe APIs also verify cached and direct furnace fallbacks, using a temporary data pack. Release acceptance invokes `-CleanRunDirectory`, removing each GUID-isolated world and temporary data pack; its small evidence log may remain under `build/server-smoke` until the next clean build. The audited collector also writes `release-manifest.json` and `SHA256SUMS.txt` beside the JARs, binding every artifact to its exact profile and source commit. See [docs/VALIDATION.md](docs/VALIDATION.md) for manual happy, negative, and edge-case checks for every rule.

## Known limitations

- Rule changes affect server recipe matching immediately. A connected client's recipe-book display may remain stale until its recipes are resynchronized, commonly by reconnecting; crafting and furnace validation still use the current server rule.
- Recipe JSONs available in the selected capability tier are present in the data pack and gated during server recipe lookup. The build selects the version-correct resource directory and one of four schema combinations: 1.15–1.20.4 use plural `recipes/`, ingredient objects, crafting `result.item`, and a string cooking result; 1.20.5–1.20.6 use plural `recipes/`, ingredient objects, and `result.id`; 1.21–1.21.1 use singular `recipe/`, ingredient objects, and `result.id`; 1.21.2 and later audited targets use singular `recipe/`, ingredient shorthand, and `result.id`. Later-version variants are removed from older JARs. Data-pack inspection alone does not indicate whether a bundled recipe is currently enabled.
- The support catalog and independent build profiles are complete for today's 35 stable Fabric Carpet coordinates and 43 exact Minecraft releases. This does not make every adapter `verified`: the status remains tied to its actual automated coverage.
- Minecraft 1.15–1.19.4, 1.20–1.20.6, and 1.21–1.21.11 are deliberately marked `build-only`: these 38 current adapters pass unit, packaging, JAR, and focused server checks, but they do not yet have the 26.x gameplay GameTest coverage.
