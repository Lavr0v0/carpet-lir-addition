# Multi-version support model

`versions/support-matrix.json` is the support-policy source of truth. It catalogs stable Fabric Carpet coordinates from Minecraft 1.14.4 through 26.2, their exact latest stable Carpet artifact, their Minecraft-version coverage, and the feature tier available in each line.

## Scope

The target list follows stable `carpet:fabric-carpet` Maven coordinates. Snapshot, experimental, pre-release, release-candidate, and beta builds are excluded. Minecraft 1.12 and 1.13 are also excluded because they predate the Fabric Carpet line covered by this project.

Some stable Carpet coordinates cover adjacent Minecraft patch releases. In those rows, `target` remains the real Carpet coordinate while `minecraftVersions` enumerates every Minecraft release that coordinate covers. This keeps 1.20.1, 1.20.4, 1.21.1, 1.21.3, 1.21.8, 26.1.1, and 26.1.2 visible without inventing Carpet coordinates that do not exist.

## Status meanings

- `verified`: built and exercised with the current audited implementation and regression suite. The 26.1 line (including 26.1.1 and 26.1.2) and 26.2 have this status today.
- `released-legacy`: an artifact was published in v1.0.1, but it predates the current audit fixes and automated tests. It must be ported and revalidated before another release.
- `planned`: a stable Fabric Carpet target with no currently accepted audited build. Local drafts do not count as releases or verification.

`released-legacy` therefore does not mean that the old source should be copied into the active tree unchanged.

## Capability tiers

| Tier | First target | Rules added | Leaf recipe variants | Total recipes |
| --- | --- | --- | --- | ---: |
| `tier-1.14` | 1.14.4 | Leaves crafting and bone-meal grass conversion | Six original overworld tree families | 6 |
| `tier-1.15` | 1.15 | Honeycomb reverse crafting | No change | 7 |
| `tier-1.17` | 1.17 | Calcite, tuff, lapis ore, raw ores, and piston-harvestable amethyst | No change | 12 |
| `tier-1.19` | 1.19 | Three reinforced-deepslate/Warden rules | Adds mangrove | 13 |
| `tier-1.20` | 1.20 | No new rule | Adds cherry | 14 |
| `tier-1.21.4` | 1.21.4 | No new rule | Adds pale oak | 15 |

Unsupported rules are meant to be absent from that version's settings class, feature sources, mixin configuration, recipes, and tests. They must not be registered as nonfunctional rules.

## Source families

`sourceFamily` identifies the API/mapping adapter expected to supply a target. It is not a claim that the adapter already exists. Early targets remain separated by Yarn API generation, while 26.x uses Mojang mappings. A family may be split later if compilation or runtime testing proves that two targets are not safely compatible.

Exact targets remain independent matrix rows even when they initially share a source family. Range artifacts must not be recreated until every Minecraft version declared by the range has been smoke-tested.

## Validation

Run the matrix validator from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-version-matrix.ps1
```

PowerShell 7 can use:

```powershell
pwsh -File ./scripts/validate-version-matrix.ps1
```

For a release audit, also verify every pinned coordinate against the current official Carpet Maven metadata:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-version-matrix.ps1 -VerifyMaven
```

The validator checks:

- JSON parsing and required fields
- the complete stable target catalog and chronological ordering
- unique target and profile identifiers
- known statuses, source families, rules, and leaf variants
- Java version transitions
- version prerequisites for every feature and leaf recipe
- monotonic capabilities, so later targets cannot silently lose an earlier feature
- exact Minecraft-version coverage, including patch releases that share one Carpet coordinate
- a unique, well-formed stable Carpet Maven coordinate for every target

## Audited 26.x builds

The root Gradle build now supports `26.1`, `26.1.1`, `26.1.2`, and `26.2` as independent targets. Each profile pins its Minecraft, Fabric Loader, Fabric API, and Carpet dependency and writes the exact Minecraft dependency into the JAR metadata.

```powershell
.\gradlew.bat build -PtargetVersion=26.1.2
powershell -ExecutionPolicy Bypass -File .\scripts\build-26-targets.ps1
```

The batch command runs the full unit and GameTest suite for all four targets, then collects only release JARs under `build\multiversion`. Older source families remain explicitly unverified until their audited adapters and tests land.

Every collected artifact is also opened and checked against the selected capability tier. `scripts/validate-built-jar.ps1` rejects wrong rule fields, rule translations, recipe resources, Mixin references, Java bytecode levels, test code, unbounded Carpet dependencies, and classes that do not exist in the target's Minecraft generation.
