# Carpet LIR Addition

Carpet LIR Addition is a server-authoritative Fabric Carpet extension focused on renewable-item survival mechanics. It adds no custom screens or client rendering, and every behavior is guarded by a Carpet rule that defaults to `false`.

The current target is Minecraft Java Edition 26.2 with Java 25, Fabric Loader 0.19.3, Fabric API 0.152.1+26.2, and Carpet 26.2.

## Installation

Put the Carpet LIR Addition jar in the `mods` folder together with compatible versions of Fabric Loader, Fabric API, and Fabric Carpet. The same jar may be installed on a client joining the server, but all gameplay behavior is decided by the server.

## Rules

Rules are managed through Carpet's normal `/carpet` command. For example:

```text
/carpet renewableCalcite true
```

| Rule | Effect |
| --- | --- |
| `renewableCalcite` | Lava above a bone block generates calcite when an amethyst block is beside or above it. Non-matching lava interactions remain vanilla. |
| `renewableTuff` | Enables smelting one gravel into one tuff. |
| `renewableLapisOre` | Enables crafting eight calcite around one amethyst shard into one lapis ore. |
| `renewableLeavesCrafting` | Enables recipes for four sticks plus a matching log to produce four leaves for all nine supported tree types. |
| `renewableRawOresCrafting` | Enables eight cobblestone plus an ingot to produce the matching raw iron, copper, or gold. |
| `renewableHoneycombCrafting` | Enables converting one honeycomb block back into four honeycombs. |
| `boneMealGrassifyDirt` | Bone meal converts dirt into grass only where grass can actually survive, with vanilla feedback and item consumption. |
| `obsidianHardnessReinforcedDeepslate` | Gives reinforced deepslate obsidian's actual hardness and mining progress. |
| `silkTouchableReinforcedDeepslate` | Makes reinforced deepslate drop itself when mined with Silk Touch. |
| `wardensDropReinforcedDeepslate` | Wardens drop 1–4 reinforced deepslate on death when `mob_drops` is enabled. |
| `pistonHarvestableAmethysts` | Adds a budding-amethyst item drop when a piston destroys budding amethyst. |

All rules use the `LIR`, `FEATURE`, and `RENEWABLE` categories and default to `false`.

## Development and verification

The Gradle wrapper resolves a Java 25 toolchain automatically. The first build therefore needs network access, but it does not depend on a repository-local or machine-specific JDK path.

```powershell
# Fast logic and resource checks
.\gradlew.bat test

# Start a real Fabric test server and exercise gameplay behavior
.\gradlew.bat runGameTest

# Compile, test, remap, and package the release jars
.\gradlew.bat build
```

The automated suite checks recipe-to-rule coverage, translation parity, live recipe toggling, calcite generation, dirt conversion, reinforced-deepslate hardness, Warden drops and `mob_drops`, and real piston activation. See [docs/VALIDATION.md](docs/VALIDATION.md) for manual happy, negative, and edge-case checks for every rule.

## Known limitations

- Rule changes affect server recipe matching immediately. A connected client's recipe-book display may remain stale until its recipes are resynchronized, commonly by reconnecting; crafting and furnace validation still use the current server rule.
- Recipe JSONs are always present in the data pack and are gated during server recipe lookup. Data-pack inspection alone does not indicate whether a recipe is currently enabled.
- Mixin targets are validated against Minecraft 26.2. A different Minecraft minor version requires a fresh build and GameTest pass rather than only relaxing dependency metadata.
