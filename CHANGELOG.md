# Changelog

## [Unreleased]

### Added
- Added the Minecraft 26.2-only `renewableCinnabar` Carpet rule. Lava touching water now forms cinnabar when potent sulfur is directly below it and netherrack is horizontally adjacent; both catalyst blocks remain in place.
- Added GameTests for the complete cinnabar structure, disabled-rule vanilla fallback, incomplete structures, and catalyst preservation.
- Extended the disposable server smoke to run reinforced-deepslate hardness, real Silk Touch mining, and Warden loot gates on every target that exposes those rules, including Minecraft 1.21.11.
- Added a calcite edge-case assertion proving that lava remains lava when the rule is enabled but the required amethyst catalyst is absent.

### Changed
- Added a `tier-26.2` capability and a Mojang-mapped version source overlay so Minecraft 26.1–26.1.2 continue to omit the rule, feature class, and unavailable vanilla block references.

### Fixed
- Adapted smoke commands to the component-era item-count format and the Minecraft 1.21.9+ `mob_drops` game-rule name, preventing newer targets from silently skipping or misreporting reinforced-deepslate coverage.

## [1.1.0-beta.2] - 2026-08-26

### Added
- Added release-manifest and SHA-256 checksum generation plus an independent bundle revalidator to the audited 43-target build, with a clean-Git and full-test requirement for release acceptance.
- Added exact Minecraft 1.15, 1.15.1, and 1.15.2 Java 8 profiles with official Carpet, Yarn, and exact mapping-bound Fabric API coordinates, producing one independently constrained JAR per release.
- Added the 1.15 bone-meal interaction overlay and Java 8 RecipeManager Mixin resource while reusing the capability-pruned tier-1.15 settings, feature bootstrap, legacy entrypoint, and direct recipe filter.
- Added a focused legacy translation-key test and disposable real-server coverage for all three 1.15 releases, including `/carpetlir`, bone-meal consumption and interaction gates, same-furnace/direct recipe fallback, clean shutdown, and automatic world cleanup.
- Added six exact Minecraft 1.16–1.16.5 Java 8 profiles with version-specific Carpet, Yarn, Fabric API, dependency metadata, and one JAR per exact Minecraft release.
- Added the first root-project `tier-1.15` source layer, exposing only `boneMealGrassifyDirt`, `renewableLeavesCrafting`, `renewableHoneycombCrafting`, and their seven valid recipes while physically omitting every 1.17+ rule, feature, Mixin, resource, and translation.
- Added an extension-owned legacy `SettingsManager`, `carpet.settings.Rule` adapter, `/carpetlir` command root, 1.16 interaction implementation, and order-preserving recipe-stream filter for the Java 8 line.
- Extended disposable Java 8 server coverage through all six exact Minecraft 1.16 releases, including command registration, bone-meal consumption and interaction states, enabled/direct and disabled same-furnace/direct recipe fallback, clean shutdown, and automatic test-world cleanup.
- Added exact Minecraft 1.17 and 1.17.1 profiles with Java 16, version-correct Carpet/Yarn/Fabric API coordinates, the legacy `fabric` dependency id, pack format 7, and one audited JAR per release.
- Added a resource-overlay axis so the 1.17 targets can reuse compatible tier-1.17 Java mechanics while packaging their own Java 16 Mixin configuration without duplicate source implementations.
- Extended full disposable real-server coverage through both exact Minecraft 1.17 releases, including declared-Java verification, dirt and calcite gates, same-furnace/direct recipe fallback, piston no-drop/drop behavior, clean shutdown, and automatic world cleanup.
- Added exact Minecraft 1.18, 1.18.1, and 1.18.2 profiles with Java 17 bytecode, exact Carpet/Yarn/Fabric API dependencies, version-correct `fabric` versus `fabric-api` ids, and one audited JAR per release.
- Added narrow 1.18 adapters for the old Carpet Rule annotation, legacy `Identifier` and fluid tags, `GameEvent.BLOCK_CHANGE`, and the direct three-parameter `RecipeManager` API, plus a capability-selected feature bootstrap that omits 1.19-only classes.
- Extended full disposable real-server coverage through all three exact Minecraft 1.18 releases, including dirt and snowy-state interaction gates, disabled/enabled calcite generation, same-furnace/direct recipe fallback, piston no-drop/drop behavior, clean shutdown, and automatic world cleanup.
- Added exact Minecraft 1.19, 1.19.1, and 1.19.2 profiles with Java 17 bytecode, exact Carpet/Yarn/Fabric API dependencies, version-correct `fabric` versus `fabric-api` ids, and one audited JAR per release.
- Added an old `carpet.settings.Rule` adapter with required descriptions for Minecraft 1.19, plus a server-only Warden death Mixin for Fabric API 0.58.x and a shared event adapter for 1.19.2–1.19.4.
- Extended full tier-1.19 real-server coverage through all five exact Minecraft 1.19 releases, including cached/direct recipe fallback, real Silk Touch mining, `/kill` Warden loot gates and count, piston no-drop/drop behavior, and automatic world cleanup.
- Added exact Minecraft 1.19.3 and 1.19.4 profiles with Java 17 bytecode, one JAR per release, the 11-rule/13-recipe `tier-1.19` capability set, and version-correct legacy loot-context, pre-`RecipeEntry`, and registry-fluid-tag adapters.
- Added a server GameTest proving that reinforced deepslate drops exactly one block with Silk Touch only while its Carpet rule is enabled.
- Added independent Minecraft 1.20 and 1.20.1 profiles using the shared stable Carpet coordinate but exact Yarn, Fabric API, Minecraft dependency metadata, Java 17 bytecode, and one JAR per release.
- Added a pre-`RecipeEntry` source layer so old `Recipe` and cached `Pair<Identifier, Recipe>` lookups can coexist with later entry-based adapters without duplicate or unavailable classes.
- Added exact Minecraft 1.20.2, 1.20.3, and 1.20.4 build profiles with Java 17 bytecode, exact dependency metadata, version-correct recipe resources, and one JAR per release.
- Added shared 1.19–1.20 source layers for mechanics that remain API-compatible while keeping rule annotations, death hooks, loot context, recipe lookup, fluid tags, and Mixin configuration in narrow version adapters.
- Added exact Minecraft 1.20.5 and 1.20.6 build profiles with their own Carpet, Fabric API, Yarn, metadata, and release JARs.
- Added target-selected singular/plural recipe-directory packaging and audit coverage for the 1.20.5/1.20.6 data-pack layout.
- Added exact, audited build profiles for Minecraft 1.21, 1.21.1, 1.21.2, and 1.21.3 using two API-accurate source families and one exact JAR per release.
- Added target-selected recipe schema normalization and JAR-level schema validation so pre-1.21.2 releases receive ingredient objects instead of unsupported string shorthand.
- Added snowy-grass state coverage to both the 26.x GameTest suite and disposable Yarn server smoke harness.
- Added exact, audited build profiles and a dedicated API adapter for Minecraft 1.21.9 and 1.21.10.
- Added exact, audited build profiles and a shared API adapter for Minecraft 1.21.6, 1.21.7, and 1.21.8 while keeping one exact JAR per release.
- Added exact, audited Minecraft 1.21.4 and 1.21.5 profiles, reusing the compatible audited adapter without duplicating source code.
- Added a uniquely isolated real-server smoke harness covering enabled dirt conversion, disabled behavior, spectator denial, live furnace-cache invalidation, clean shutdown, and optional test-world cleanup.
- Extended basic real-server smoke coverage through Minecraft 1.19–1.20.6 and 1.21–1.21.11. The enhanced disposable-data-pack checks use an enabled direct-query baseline before asserting cached and direct recipe fallbacks on exact pre-entry 1.19–1.20.1 and representative 1.20.2, 1.20.6, and 1.21.10 API boundaries; acceptance runs use `-CleanRunDirectory` to remove their GUID worlds and temporary data packs.

### Fixed
- Declared and matrix-validated the classic 1.14.4 plural recipe directory and legacy result schema so the unified release audit checks its actual data-pack format.
- Converted modern `carpet.rule.*` and `carpet.category.*` asset keys to the legacy `rule.*` and `category.*` names consumed by the Minecraft 1.15.2–1.16 Carpet translation hook.
- Removed translation-hook `@Override` annotations that do not exist in the Minecraft 1.15/1.15.1 CarpetExtension interface while retaining the method for 1.15.2 and later legacy releases.
- Pinned Minecraft 1.16 to Fabric API `0.14.1+build.372-1.16`; the next nominal 1.16 aggregate includes a tag module that links a class introduced only in Minecraft 1.16.2.
- Parsed extension-owned settings before Carpet registers legacy commands, detached that manager on server close, and corrected the Java 8 smoke harness for Carpet's swapped numeric look arguments and the controlled recipe fixture's namespace.
- Filtered disabled 1.16 recipes before vanilla's first-match selection, preserving data-pack iteration priority and avoiding a second sorted recipe scan on each furnace lookup.
- Bound root build and server run tasks to each target's declared Java toolchain, so Java 16/17/21/25 compatibility is exercised rather than only inferred from generated bytecode.
- Split disposable-server startup and gameplay deadlines so the expanded tier-1.19 regression suite cannot exhaust a startup-inclusive 240-second global timeout after otherwise passing checks.
- Loaded legacy Carpet translations directly from this mod's classpath because the 1.18-era Carpet helper ignores an extension-supplied translation path, and pruned higher-tier translation keys together with unavailable rules and resources.
- Kept legacy Yarn unit tests independent of a full Fabric registry bootstrap, avoiding the 1.18.2 named-Yarn cross-package access failure while real Fabric/Mixin behavior remains covered by disposable server smokes.
- Made JAR validation require capability-critical fluid, reinforced-deepslate, recipe, and piston adapters to be registered in a server-active Mixin configuration, not merely present as unused classes.
- Reworked the Yarn server smoke runner to drain output while pacing commands, preventing pipe backpressure from collapsing delayed interactions into one tick; added JAR guards and real piston no-drop/drop assertions for `pistonHarvestableAmethysts`.
- Replaced the legacy 1.20–1.20.1 direct-only recipe filter with direct and cached fallbacks that return the valid fallback recipe identifier instead of preserving a disabled cache hint.
- Added the Minecraft 1.20.2–1.20.4 `RecipeManager` Pair-cache adapter so disabling a Carpet LIR recipe rejects a stale cached tuff match and returns the identifier and entry of the valid fallback recipe.
- Added legacy recipe-result normalization and JAR validation for the 1.20.2–1.20.4 split between crafting `result.item` objects and string cooking results.
- Replaced the flawed legacy 1.20.5–1.20.6 range implementation with an API-accurate adapter that rejects spectators, preserves snowy grass, respects `mob_drops`, and filters both direct and cached recipe lookups.
- Made old-schema ingredient normalization preserve `#tag` ingredients as tag objects instead of misclassifying them as item ids.
- Added Minecraft 1.16.1 to the support catalog because Carpet's stable 1.16 artifact declares compatibility with the full 1.16.x line.
- Fixed all Carpet LIR recipes failing to parse on Minecraft 1.21 and 1.21.1, while keeping pale oak absent from those JARs and their runtime recipe control maps.
- Preserved the grass block's `snowy` state when bone meal converts dirt beneath a snow layer.
- Removed redundant budding-amethyst piston-behavior overrides; vanilla already marks the block destroyable, while the thin piston hook remains responsible only for the rule-gated item drop.
- Stabilized disposable server tests against fake-player water, spectator fall-through, and asynchronous login state without relaxing gameplay assertions.
- Replaced the legacy 1.21.6–1.21.8 grass survival and recipe-cache paths so opaque/full-water blocks, spectators, and disabled cached furnace recipes are handled correctly.
- Made the real-server smoke harness wait for its fake player to finish logging in before interaction commands, removing a load-dependent cross-version race.
- Made the JAR audit reject undeclared extra mixin configurations so a stale version overlay cannot be packaged silently.

## [1.1.0-beta.1] - 2026-08-22

### Added
- Added unit tests for recipe-to-rule coverage and translation integrity.
- Added server-side Fabric GameTests for calcite, bone meal, recipes, reinforced deepslate hardness, Warden drops, game-rule handling, and piston harvesting.
- Added automatic Java 25 toolchain resolution for portable development builds.
- Added a validated support matrix for 35 stable Fabric Carpet coordinates, 42 Minecraft releases, six capability tiers, and version-specific recipe sets.
- Added independent audited build profiles for Minecraft 26.1, 26.1.1, 26.1.2, and 26.2.
- Added batch artifact verification that rejects incorrect Minecraft metadata, unexpected names, ambiguous release JARs, and packaged GameTest code.
- Added an isolated Java 8 Minecraft 1.14.4 target with only the two rules and six leaf recipes available in that generation.
- Added an audited, build-only Minecraft 1.21.11 source profile with focused regression tests.
- Added one audited batch command that builds, inspects, and collects all six current exact-version artifacts.
- Added rule-contract tests requiring every boolean setting to be public, static, annotated, and disabled by default.

### Changed
- Restricted calcite generation to the custom matching branch and left all non-matching lava behavior to vanilla.
- Matched grass-block survival checks and native feedback when bone meal converts dirt.
- Centralized all 15 recipe-to-rule mappings and bounded Fabric API and Carpet dependency metadata to tested minimum versions.
- Scoped budding-amethyst loot replacement directly to the piston destruction call site.
- Read the extension version from Fabric metadata instead of returning an unexpanded placeholder.
- Pinned each stable support target to an official Carpet Maven coordinate and added optional live verification against Maven metadata.
- Defined low-version support as capability-driven: unavailable rules and resources must be omitted instead of exposed as nonfunctional settings.
- Selected Loom, mappings, Java, source overlays, Fabric API mod id, and exact runtime dependency predicates from each target profile.
- Separated target-specific Maven artifact ids and published the audited multi-version work as the `1.1.0-beta.1` prerelease so it cannot overwrite the released 1.0.3 coordinates.
- Made online matrix verification detect newly published stable Carpet targets as well as stale local pins.

### Fixed
- Made Warden bonus drops respect `mob_drops` instead of the unrelated `block_drops` game rule.
- Cleared disabled cached recipe hints before vanilla fallback, preventing a stale cache from suppressing another valid recipe.
- Prevented custom calcite handling from duplicating and intercepting vanilla water, cobblestone, stone, and basalt branches while its rule is disabled.
- Prevented bone meal from creating grass under full water or opaque blocks where it immediately decays.
- Bridged the renamed 26.1/26.2 grass light-occlusion API without repeating reflection on every interaction.
- Prevented spectators from converting dirt with bone meal before vanilla's spectator interaction gate.
- Made the 1.21.11 extension report its packaged Fabric metadata version instead of the literal `${version}` placeholder.
- Parameterized the legacy `fabric` versus modern `fabric-api` dependency id so old loaders receive valid metadata.
- Isolated each root build profile under `run/<target>` so a newer test world cannot break an older server smoke test.

## [1.0.3] - 2026-06-17

### Changed
- Updated the development target to Minecraft Java Edition 26.2, Fabric Loader 0.19.3, Fabric API 0.152.1+26.2, and Carpet 26.2.
- Ported the original full Carpet LIR Addition rule set to the Minecraft 26 Mojang-mapped API.
- Rebuilt release jars for Minecraft 26.1, 26.1.1, 26.1.2, and 26.2.
- Kept MODID as `carpetlir` and kept rules registered under Carpet's normal `/carpet` command.

### Fixed
- Replaced the temporary `renewableDebugSample` test build with the original renewable and utility rule behavior.
- Updated mixin targets for Minecraft 26.2 server startup compatibility.

## [1.0.2] - 2026-05-26

### Changed
- Updated the development target to Minecraft Java Edition 26.1.2, Fabric Loader 0.19.2, Fabric API 0.149.1+26.1.2, and Carpet 26.1.
- Migrated the build to Fabric's 26.1+ Loom plugin and Mojang official mappings.
- Added a Gradle wrapper and configured the project to use the local JDK 25 for builds.

### Added
- Initial Fabric Carpet extension skeleton for Carpet LIR Addition.
- `LIRSettings` as the central Carpet rule class.
- Sample rule `renewableDebugSample` with a join-message behavior proof.

## [1.0.1] - 2026-04-01

### Changed
- Promoted the widened multi-version release matrix from `1.20` through `1.21.11` as the `1.0.1` release line.
- Kept the feature set unchanged while broadening the set of build-ready intermediate Minecraft targets and grouped range artifacts.
- Cleared the remaining source-level deprecated API warning in `FluidBlockMixin`.

## [1.0.0] - 2026-04-01

### Added
- Carpet rule `renewableCalcite` for a basalt-style calcite generator using `bone_block + amethyst_block + lava`.
- Carpet rule `renewableTuff` for the gravel-to-tuff furnace recipe.
- Carpet rule `renewableLapisOre` for the calcite plus amethyst shard lapis ore recipe.
- Carpet rule `renewableLeavesCrafting` for matching-log plus stick recipes that craft leaves.
- Carpet rule `renewableRawOresCrafting` for the raw iron, raw copper, and raw gold crafting recipes.
- Carpet rule `renewableHoneycombCrafting` for turning honeycomb blocks back into honeycombs.
- Carpet rule `boneMealGrassifyDirt` for converting dirt into grass blocks with bone meal.
- Carpet rule `obsidianHardnessReinforcedDeepslate` for reducing reinforced deepslate break speed to obsidian levels.
- Carpet rule `silkTouchableReinforcedDeepslate` for reinforced deepslate self-drops with Silk Touch.
- Carpet rule `wardensDropReinforcedDeepslate` for warden drops of reinforced deepslate.
- Carpet rule `pistonHarvestableAmethysts` for piston-breaking budding amethyst into its own block item.
- Smelting recipe for `gravel -> tuff`.
- Shaped recipes for `lapis_ore`, matching leaves, `raw_iron`, `raw_copper`, and `raw_gold`.
- Shapeless recipe for `honeycomb_block -> honeycomb x4`.
- Technical documentation covering mechanic inputs, conditions, outputs, and validation notes.

### Changed
- Ported the mod to Minecraft `1.21.11`.
- Updated the build toolchain to Java `21`, Fabric Loader `0.18.5`, Fabric API `0.141.3+1.21.11`, and Fabric Carpet `1.21.11-1.4.194+v260107`.
- Added a Gradle wrapper so builds can be reproduced with `./gradlew build`.
- Added bundled Carpet rule translations for `en_us`, `es_ar`, `fr_fr`, `pt_br`, `zh_cn`, and `zh_tw`, and migrated them to Carpet's current translation key format.
- Reworked the README into a complete bilingual English/Chinese reference and refreshed locale coverage for the current rule set.
- Reworked the build metadata into a version-profile layout so the repository can track `1.20.1`, `1.21.1`, `1.21.11`, and `26.1` targets in a maintainable way.
- Promoted the `1.21.1` and `1.20.1` profiles from staged metadata to build-ready backport targets using version-specific source overlays.
- Added build-time recipe compatibility conversion so `1.21.1` and `1.20.1` emit the correct recipe schema from the same source JSONs.
- Aligned several translated rule descriptions with the official Minecraft item and block names for each bundled locale.
- Simplified the `boneMealGrassifyDirt` rule text so it no longer exposes particle and sound implementation details in user-facing descriptions.
- Added grouped range build profiles for `1.20-1.20.1` and `1.21-1.21.1`, reusing the matching backport source overlays and version predicates.
- Added build-ready intermediate version profiles covering `1.20.2`, `1.20.3-1.20.4`, `1.20.5-1.20.6`, `1.21.2-1.21.3`, `1.21.4`, `1.21.5`, `1.21.6-1.21.8`, and `1.21.9-1.21.10`.
- Split the modern source line into small version overlays only where Mojang API changes actually diverged, keeping the overall multi-version layout narrow and maintainable.
- Fixed the remaining `FluidBlockMixin` deprecated API warning by replacing the lava tag check with `matchesType(Fluids.LAVA)`.
