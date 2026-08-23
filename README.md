# Carpet LIR Addition

Carpet LIR Addition is a server-authoritative Fabric Carpet extension focused on renewable-item survival mechanics. It adds no custom screens or client rendering, and every behavior is guarded by a Carpet rule that defaults to `false`.

The currently audited build family covers Minecraft Java Edition 26.1, 26.1.1, 26.1.2, and 26.2. Every release receives its own JAR with an exact Minecraft dependency and pinned build inputs; there is no fake all-version JAR.

The broader support catalog covers all 35 stable Fabric Carpet coordinates from Minecraft 1.14.4 through 26.2, representing 42 Minecraft releases. Older lines are being ported by capability tier: unavailable rules, classes, mixins, recipes, and translations are removed rather than registered as no-op features. See [the multi-version support model](docs/MULTIVERSION.md) for the verified/legacy/planned distinction.

## Installation

Put the Carpet LIR Addition JAR matching the server's exact Minecraft version in the `mods` folder together with compatible versions of Fabric Loader, Fabric API, and Fabric Carpet. The same JAR may be installed on a client joining the server, but all gameplay behavior is decided by the server.

## Rules

Rules are managed through Carpet's normal `/carpet` command. For example:

```text
/carpet renewableCalcite true
```

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

The Gradle wrapper resolves a Java 25 toolchain automatically. The first build therefore needs network access, but it does not depend on a repository-local or machine-specific JDK path.

```powershell
# Fast logic and resource checks
.\gradlew.bat test

# Start a real Fabric test server and exercise gameplay behavior
.\gradlew.bat runGameTest

# Compile, test, remap, and package the release jars
.\gradlew.bat build

# Select one audited 26.x target
.\gradlew.bat clean build -PtargetVersion=26.1.2

# Build, test, inspect, and collect all four audited 26.x artifacts
powershell -ExecutionPolicy Bypass -File .\scripts\build-26-targets.ps1

# Validate the full support/capability catalog against official Carpet Maven
powershell -ExecutionPolicy Bypass -File .\scripts\validate-version-matrix.ps1 -VerifyMaven
```

The automated suite checks recipe-to-rule coverage, translation parity, live recipe toggling, calcite generation, dirt conversion, reinforced-deepslate hardness, Warden drops and `mob_drops`, and real piston activation. See [docs/VALIDATION.md](docs/VALIDATION.md) for manual happy, negative, and edge-case checks for every rule.

## Known limitations

- Rule changes affect server recipe matching immediately. A connected client's recipe-book display may remain stale until its recipes are resynchronized, commonly by reconnecting; crafting and furnace validation still use the current server rule.
- Recipe JSONs are always present in the data pack and are gated during server recipe lookup. Data-pack inspection alone does not indicate whether a recipe is currently enabled.
- The current audited source family is limited to Minecraft 26.1 through 26.2. Older matrix entries remain explicitly unverified until their versioned sources pass their own build and behavior checks.
