# Changelog

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
