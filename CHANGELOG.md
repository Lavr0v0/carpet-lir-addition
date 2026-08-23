# Changelog

## [Unreleased]

### Added
- Added unit tests for recipe-to-rule coverage and translation integrity.
- Added server-side Fabric GameTests for calcite, bone meal, recipes, reinforced deepslate hardness, Warden drops, game-rule handling, and piston harvesting.
- Added automatic Java 25 toolchain resolution for portable development builds.
- Added a validated support matrix for 35 stable Fabric Carpet coordinates, 42 Minecraft releases, six capability tiers, and version-specific recipe sets.
- Added independent audited build profiles for Minecraft 26.1, 26.1.1, 26.1.2, and 26.2.
- Added batch artifact verification that rejects incorrect Minecraft metadata, unexpected names, ambiguous release JARs, and packaged GameTest code.

### Changed
- Restricted calcite generation to the custom matching branch and left all non-matching lava behavior to vanilla.
- Matched grass-block survival checks and native feedback when bone meal converts dirt.
- Centralized all 15 recipe-to-rule mappings and bounded Fabric API and Carpet dependency metadata to tested minimum versions.
- Scoped budding-amethyst loot replacement directly to the piston destruction call site.
- Read the extension version from Fabric metadata instead of returning an unexpanded placeholder.
- Pinned each stable support target to an official Carpet Maven coordinate and added optional live verification against Maven metadata.
- Defined low-version support as capability-driven: unavailable rules and resources must be omitted instead of exposed as nonfunctional settings.

### Fixed
- Made Warden bonus drops respect `mob_drops` instead of the unrelated `block_drops` game rule.
- Cleared disabled cached recipe hints before vanilla fallback, preventing a stale cache from suppressing another valid recipe.
- Prevented custom calcite handling from duplicating and intercepting vanilla water, cobblestone, stone, and basalt branches while its rule is disabled.
- Prevented bone meal from creating grass under full water or opaque blocks where it immediately decays.
- Bridged the renamed 26.1/26.2 grass light-occlusion API without repeating reflection on every interaction.

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
