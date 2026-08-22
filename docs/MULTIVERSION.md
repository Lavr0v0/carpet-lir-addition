# Multi-version support model

`versions/support-matrix.json` is the source of truth for the first multi-version milestone. It catalogs stable Fabric Carpet coordinates from Minecraft 1.14.4 through 26.2 without changing the current 26.2 build.

## Scope

The target list follows stable `carpet:fabric-carpet` Maven coordinates. Snapshot, experimental, pre-release, release-candidate, and beta builds are excluded. Minecraft 1.12 and 1.13 are also excluded because they predate the Fabric Carpet line covered by this project.

Some stable Carpet coordinates cover adjacent Minecraft patch releases. The matrix records the exact Carpet compile target instead of inventing a coordinate that does not exist. For example, the historical LIR releases used the 1.20 coordinate for a 1.20-1.20.1 artifact and the 1.21.7 coordinate for a 1.21.6-1.21.8 artifact.

## Status meanings

- `verified`: built and exercised with the current audited implementation and regression suite. Only 26.2 has this status today.
- `released-legacy`: an artifact was published in v1.0.1, but it predates the current audit fixes and automated tests. It must be ported and revalidated before another release.
- `planned`: a stable Fabric Carpet target with no currently accepted audited build. Local drafts do not count as releases or verification.

`released-legacy` therefore does not mean that the old source should be copied into the active tree unchanged.

## Capability tiers

| Tier | First target | Rules added | Leaf recipe variants |
| --- | --- | --- | --- |
| `tier-1.14` | 1.14.4 | Leaves crafting and bone-meal grass conversion | Six original overworld tree families |
| `tier-1.15` | 1.15 | Honeycomb reverse crafting | No change |
| `tier-1.17` | 1.17 | Calcite, tuff, lapis ore, raw ores, and piston-harvestable amethyst | No change |
| `tier-1.19` | 1.19 | Three reinforced-deepslate/Warden rules | Adds mangrove |
| `tier-1.20` | 1.20 | No new rule | Adds cherry |
| `tier-1.21.4` | 1.21.4 | No new rule | Adds pale oak |

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

The validator checks:

- JSON parsing and required fields
- the complete stable target catalog and chronological ordering
- unique target and profile identifiers
- known statuses, source families, rules, and leaf variants
- Java version transitions
- version prerequisites for every feature and leaf recipe
- monotonic capabilities, so later targets cannot silently lose an earlier feature

This milestone intentionally does not wire profiles into Gradle. Build integration should follow only after the metadata and capability policy are accepted.
