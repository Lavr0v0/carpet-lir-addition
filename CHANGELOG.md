# Changelog

## [Unreleased]

### Added
- Added a server GameTest proving that reinforced deepslate drops exactly one block with Silk Touch only while its Carpet rule is enabled.

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
