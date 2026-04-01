# Changelog

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
