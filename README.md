# Carpet LIR Addition

Carpet LIR Addition is a server-authoritative Fabric Carpet extension focused on renewable-item survival mechanics. It adds no custom screens or client rendering, and every behavior is guarded by a Carpet rule that defaults to `false`.

Six exact Minecraft targets now have current build paths. Minecraft 1.14.4 is a runtime-verified Java 8 classic build containing only its two available rules. Minecraft 1.21.11 has an audited build and unit/server-startup coverage but remains `build-only` until gameplay GameTests are ported. Minecraft 26.1, 26.1.1, 26.1.2, and 26.2 pass the full current unit and server GameTest suite. Every target receives its own JAR with exact dependency metadata; there is no fake all-version JAR.

The broader support catalog covers all 35 stable Fabric Carpet coordinates from Minecraft 1.14.4 through 26.2, representing 43 Minecraft releases. Older lines are being ported by capability tier: unavailable rules, classes, mixins, recipes, and translations are removed rather than registered as no-op features. See [the multi-version support model](docs/MULTIVERSION.md) for the verified/legacy/planned distinction.

## Installation

Put the Carpet LIR Addition JAR matching the server's exact Minecraft version in the `mods` folder together with compatible versions of Fabric Loader, Fabric API, and Fabric Carpet. The same JAR may be installed on a client joining the server, but all gameplay behavior is decided by the server.

## Rules

On current Carpet generations, rules are managed through Carpet's normal `/carpet` command. For example:

```text
/carpet renewableCalcite true
```

Minecraft 1.14.4 uses the older Carpet extension API and therefore exposes its two rules through `/carpetlir <rule> true|false`; see the [classic target guide](classic/1.14.4/README.md).

| Rule | First target | Effect |
| --- | --- | --- |
| `renewableCalcite` | 1.17 | Lava above a bone block generates calcite when an amethyst block is beside or above it. Non-matching lava interactions remain vanilla. |
| `renewableTuff` | 1.17 | Enables smelting one gravel into one tuff. |
| `renewableLapisOre` | 1.17 | Enables crafting eight calcite around one amethyst shard into one lapis ore. |
| `renewableLeavesCrafting` | 1.14.4 | Enables recipes for four sticks plus a matching log to produce four leaves. The six original trees are always included; mangrove, cherry, and pale oak join only after vanilla adds them. |
| `renewableRawOresCrafting` | 1.17 | Enables eight cobblestone plus an ingot to produce the matching raw iron, copper, or gold. |
| `renewableHoneycombCrafting` | 1.15 | Enables converting one honeycomb block back into four honeycombs. |
| `boneMealGrassifyDirt` | 1.14.4 | Bone meal converts dirt into grass only where grass can actually survive, with vanilla feedback and item consumption. |
| `obsidianHardnessReinforcedDeepslate` | 1.19 | Gives reinforced deepslate obsidian's actual hardness and mining progress. |
| `silkTouchableReinforcedDeepslate` | 1.19 | Makes reinforced deepslate drop itself when mined with Silk Touch. |
| `wardensDropReinforcedDeepslate` | 1.19 | Wardens drop 1–4 reinforced deepslate on death when `mob_drops` is enabled. |
| `pistonHarvestableAmethysts` | 1.17 | Adds a budding-amethyst item drop when a piston destroys budding amethyst. |

All rules use the `LIR`, `FEATURE`, and `RENEWABLE` categories and default to `false`. A rule introduced after the selected Minecraft version is absent from that JAR rather than shown as a setting that cannot work.

## Development and verification

The builds pin the Java generation required by each Minecraft line: Java 8 for 1.14.4, Java 21 for 1.21.11, and Java 25 for 26.x. Gradle resolves compile toolchains automatically when necessary. The first build therefore needs network access, and a real 1.14.4 server smoke test must itself run on Java 8 because that generation's Mixin runtime cannot parse modern host classes.

Root-profile development servers and GameTests use `run/<target>` rather than one shared world directory. This keeps worlds, logs, and generated server state from incompatible Minecraft data formats isolated.

```powershell
# Fast logic and resource checks
.\gradlew.bat test

# Start a real Fabric test server and exercise gameplay behavior
.\gradlew.bat runGameTest

# Compile, test, remap, and package the release jars
.\gradlew.bat build

# Select one audited 26.x target
.\gradlew.bat clean build '-PtargetVersion=26.1.2'

# Build the current 1.21.11 adapter
.\gradlew.bat clean build '-PtargetVersion=1.21.11'

# Build the isolated Java 8 classic adapter
.\gradlew.bat -p classic\1.14.4 clean build

# Build, test, inspect, and collect all six current artifacts
powershell -ExecutionPolicy Bypass -File .\scripts\build-audited-targets.ps1

# Compatibility wrapper for only the four audited 26.x artifacts
powershell -ExecutionPolicy Bypass -File .\scripts\build-26-targets.ps1

# Validate the full support/capability catalog against official Carpet Maven
powershell -ExecutionPolicy Bypass -File .\scripts\validate-version-matrix.ps1 -VerifyMaven
```

The automated suite checks rule visibility and conservative defaults, recipe-to-rule coverage, translation parity, live recipe toggling, calcite generation, dirt conversion (including spectator denial), reinforced-deepslate hardness, Warden drops and `mob_drops`, and real piston activation. See [docs/VALIDATION.md](docs/VALIDATION.md) for manual happy, negative, and edge-case checks for every rule.

## Known limitations

- Rule changes affect server recipe matching immediately. A connected client's recipe-book display may remain stale until its recipes are resynchronized, commonly by reconnecting; crafting and furnace validation still use the current server rule.
- Recipe JSONs are always present in the data pack and are gated during server recipe lookup. Data-pack inspection alone does not indicate whether a recipe is currently enabled.
- The support catalog is complete for today's 35 stable Fabric Carpet coordinates, but it is not yet the same as 35 release-ready builds. Six exact Minecraft targets have current adapters; the remaining matrix rows stay `released-legacy` or `planned` until their own versioned sources pass build and behavior checks.
- Minecraft 1.21.11 is deliberately marked `build-only`: its current adapter passes unit, packaging, and server-startup checks, but it does not yet have the 26.x gameplay GameTest coverage.
