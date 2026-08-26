# Multi-version support model

`versions/support-matrix.json` is the support-policy source of truth. It catalogs stable Fabric Carpet coordinates from Minecraft 1.14.4 through 26.2, their exact latest stable Maven artifact, the Carpet mod version declared inside that artifact, their Minecraft-version coverage, and the feature tier available in each line. Maven coordinates and Fabric Loader runtime versions are deliberately separate fields because legacy Carpet artifacts prefix the former with the Minecraft version.

## Scope

The target list follows stable `carpet:fabric-carpet` Maven coordinates. Snapshot, experimental, pre-release, release-candidate, and beta builds are excluded. Minecraft 1.12 and 1.13 are also excluded because they predate the Fabric Carpet line covered by this project.

Some stable Carpet coordinates cover adjacent Minecraft patch releases. In those rows, `target` remains the real Carpet coordinate while `minecraftVersions` enumerates every Minecraft release that coordinate covers. This keeps 1.16.1, 1.20.1, 1.20.4, 1.21.1, 1.21.3, 1.21.8, 26.1.1, and 26.1.2 visible without inventing Carpet coordinates that do not exist.

## Status meanings

- `verified`: built and exercised with the current audited implementation and a behavior regression suite. Minecraft 1.14.4 and the 26.1 line (including 26.1.1 and 26.1.2) plus 26.2 have this status today. The classic target uses real Java 8 server/fake-player checks because its generation has no modern Fabric GameTest framework.
- `build-only`: current sources compile and pass focused unit, packaging, and real-server checks, but behavior automation is not yet sufficient for a release claim. Twenty-four exact targets—Minecraft 1.19 through 1.19.4, 1.20 through 1.20.6, and 1.21 through 1.21.11—have this status today.
- `released-legacy`: an artifact was published in v1.0.1, but it predates the current audit fixes and automated tests. It must be ported and revalidated before another release.
- `planned`: a stable Fabric Carpet target with no currently accepted audited build. Local drafts do not count as releases or verification.

`released-legacy` therefore does not mean that the old source should be copied into the active tree unchanged.

## Capability tiers

| Tier | First target | Rules added | Total rules | Leaf recipe variants | Total recipes |
| --- | --- | --- | ---: | --- | ---: |
| `tier-1.14` | 1.14.4 | Leaves crafting and bone-meal grass conversion | 2 | Six original overworld tree families | 6 |
| `tier-1.15` | 1.15 | Honeycomb reverse crafting | 3 | No change | 7 |
| `tier-1.17` | 1.17 | Calcite, tuff, lapis ore, raw ores, and piston-harvestable amethyst | 8 | No change | 12 |
| `tier-1.19` | 1.19 | Three reinforced-deepslate/Warden rules | 11 | Adds mangrove | 13 |
| `tier-1.20` | 1.20 | No new rule | 11 | Adds cherry | 14 |
| `tier-1.21.4` | 1.21.4 | No new rule | 11 | Adds pale oak | 15 |

Unsupported rules are meant to be absent from that version's settings class, feature sources, mixin configuration, recipes, and tests. They must not be registered as nonfunctional rules.

## Source families

`sourceFamily` identifies the API/mapping adapter expected to supply a target. It is not a claim that the adapter already exists. Early targets remain separated by Yarn API generation, while 26.x uses Mojang mappings. A family may be split later if compilation or runtime testing proves that two targets are not safely compatible.

The active 1.19–1.20.6 adapters use layered source layouts: stable mechanics live in shared `1.19-common` and `1.19-1.20` layers, while divergent rule annotations, death callbacks, recipe lookup, fluid tags, and Mixin configurations stay narrow. Minecraft 1.19 uses the old `carpet.settings.Rule` API with required descriptions and singular `category`; 1.19.1+ use `carpet.api.settings.Rule` and plural `categories`. Minecraft 1.19/1.19.1 use the old `fabric` dependency id and a server-only death Mixin because Fabric API 0.58.x lacks `ServerLivingEntityEvents`; 1.19.2+ use `fabric-api` and the event. Minecraft 1.19–1.20.1 use the pre-`RecipeEntry` cache API, while 1.20.2–1.20.4 use `RecipeEntry`. The 1.19 line retains `LootContext.Builder`; 1.19–1.19.2 use legacy `FluidTags`, while 1.19.3/1.19.4 use registry `FluidTags`.

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

The slower full provenance check downloads each pinned Carpet JAR and compares its internal Fabric mod version too:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-version-matrix.ps1 -VerifyMaven -VerifyArtifactMetadata
```

Online Maven verification is bidirectional: it checks every pinned artifact and also fails when official Maven contains a new stable target missing from the local catalog. Beta, pre-release, release-candidate, experimental, and snapshot coordinates remain outside the stable set.

The validator checks:

- JSON parsing and required fields
- the complete stable target catalog and chronological ordering
- unique target and profile identifiers
- known statuses, source families, rules, and leaf variants
- Java version transitions
- allowed recipe JSON schemas and resource directories across all four audited combinations: 1.19–1.20.4 plural/object/legacy-result, 1.20.5–1.20.6 plural/object/`result.id`, 1.21–1.21.1 singular/object/`result.id`, and 1.21.2+ singular/shorthand/`result.id`
- version prerequisites for every feature and leaf recipe
- monotonic capabilities, so later targets cannot silently lose an earlier feature
- exact Minecraft-version coverage, including patch releases that share one Carpet coordinate
- a unique, well-formed stable Carpet Maven coordinate for every target

## Current build-ready targets

The root Gradle build supports `1.19`, `1.19.1`, `1.19.2`, `1.19.3`, `1.19.4`, `1.20`, `1.20.1`, `1.20.2`, `1.20.3`, `1.20.4`, `1.20.5`, `1.20.6`, `1.21`, `1.21.1`, `1.21.2`, `1.21.3`, `1.21.4`, `1.21.5`, `1.21.6`, `1.21.7`, `1.21.8`, `1.21.9`, `1.21.10`, `1.21.11`, `26.1`, `26.1.1`, `26.1.2`, and `26.2` as 28 independent targets. The Java 8 `1.14.4` target is isolated under `classic/1.14.4` so its old Loom, Carpet rule API, Fabric API mod id, and source set cannot leak into modern artifacts. Together these are 29 exact build-ready releases. Each build pins Minecraft, Fabric Loader, Fabric API, Carpet's Maven artifact, Carpet's runtime mod version, mappings, Java bytecode, recipe schema, recipe resource directory, and exact packaged dependency metadata. Minecraft 1.19–1.20.4 compile for Java 17, 1.20.5–1.21.11 compile for Java 21, and 26.x compile for Java 25.

Every root target also receives a separate `run/<target>` directory. Never reuse a generated world across source families: newer Minecraft data can make an otherwise valid older server fail before mod initialization.
The disposable smoke harness only copies an EULA file whose `eula=true` acceptance already exists; provide that file with `-EulaSourcePath` on a fresh checkout.

```powershell
.\gradlew.bat -p classic\1.14.4 clean build
.\gradlew.bat build '-PtargetVersion=1.19'
.\gradlew.bat build '-PtargetVersion=1.19.1'
.\gradlew.bat build '-PtargetVersion=1.19.2'
.\gradlew.bat build '-PtargetVersion=1.19.3'
.\gradlew.bat build '-PtargetVersion=1.19.4'
.\gradlew.bat build '-PtargetVersion=1.20'
.\gradlew.bat build '-PtargetVersion=1.20.1'
.\gradlew.bat build '-PtargetVersion=1.20.2'
.\gradlew.bat build '-PtargetVersion=1.20.3'
.\gradlew.bat build '-PtargetVersion=1.20.4'
.\gradlew.bat build '-PtargetVersion=1.20.5'
.\gradlew.bat build '-PtargetVersion=1.20.6'
.\gradlew.bat build '-PtargetVersion=1.21'
.\gradlew.bat build '-PtargetVersion=1.21.1'
.\gradlew.bat build '-PtargetVersion=1.21.2'
.\gradlew.bat build '-PtargetVersion=1.21.3'
.\gradlew.bat build '-PtargetVersion=1.21.4'
.\gradlew.bat build '-PtargetVersion=1.21.5'
.\gradlew.bat build '-PtargetVersion=1.21.6'
.\gradlew.bat build '-PtargetVersion=1.21.7'
.\gradlew.bat build '-PtargetVersion=1.21.8'
.\gradlew.bat build '-PtargetVersion=1.21.9'
.\gradlew.bat build '-PtargetVersion=1.21.10'
.\gradlew.bat build '-PtargetVersion=1.21.11'
.\gradlew.bat build '-PtargetVersion=26.1.2'
powershell -ExecutionPolicy Bypass -File .\scripts\build-audited-targets.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\build-26-targets.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\smoke-test-modern-server.ps1 -TargetVersion 1.21.9 -EulaSourcePath .\run\1.21.11\eula.txt -CleanRunDirectory
```

The audited batch command runs every target's available checks, opens each final remapped JAR, and collects 29 exact artifacts under `build\multiversion`. For 26.x, the configured Gradle `build` lifecycle invokes the full unit and 16-test server GameTest suite, including dedicated Silk Touch loot-context and snowy-grass checks. The 1.14.4 target runs its focused tests and capability-boundary audit; its release acceptance also includes a Java 8 server and fake-player check. Minecraft 1.19–1.19.4, 1.20–1.20.6, and 1.21–1.21.11 additionally pass uniquely isolated real-server smokes covering enabled and snowy dirt conversion, disabled behavior, spectator denial, and clean shutdown.

Enhanced smokes have been run on the exact pre-entry 1.19–1.20.1 targets and the representative 1.20.2, 1.20.6, and 1.21.10 API boundaries. Each run first caches Carpet LIR's controlled gravel-to-tuff recipe, installs and explicitly waits for reload of a deliberately later-ordered fallback data pack, and proves the enabled direct lookup still selects tuff. It then disables the rule and verifies that the cached lookup produces fallback cobblestone. The pre-entry runs exercise `Pair<Identifier, Recipe>`, while the 1.20.2 boundary exercises the `Pair<Identifier, RecipeEntry>` API shared by 1.20.2–1.20.4. A second `loot ... furnace_smelt` assertion proves the same direct lookup now falls through to cobblestone. All five 1.19 runs additionally prove the mangrove recipe is server-visible, hardness switches from 55 to 50, Silk Touch is gated during real fake-player mining, Warden drops respect both the rule and `doMobLoot`, and the enabled Warden drop count is 1–4 without duplicate entities. Every run uses a GUID-isolated server directory, and `-CleanRunDirectory` removes that generated world together with the temporary data pack. The 24 Minecraft 1.19–1.19.4, 1.20–1.20.6, and 1.21–1.21.11 targets remain `build-only` until equivalent full gameplay automation is ported. Other target rows remain explicitly unverified until their audited adapters and tests land.

Every collected artifact is checked against its selected capability tier and build profile. `scripts/validate-built-jar.ps1` rejects wrong rule fields, rule translations, recipe resources, schemas or singular/plural directories, missing or undeclared Mixin configurations, capability-critical adapters not registered in a server-active configuration, Java bytecode levels, test code, unresolved versions, wildcard or mismatched dependencies, wrong Fabric API generation ids, misnamed artifacts, and classes that do not exist in the target's Minecraft generation. Recipe control maps register only resources actually bundled for that tier, so an omitted low-version variant cannot survive as a no-op mapping.
