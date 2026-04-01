# 1.20.1 Profile

Status: staged legacy backport

This profile records the known dependency line for the original 1.20.1 generation of the mod.
It is intentionally not build-ready in the current branch because the active source tree has already been updated for newer Minecraft internals.

## Known requirements

- Java 17 target bytecode
- Yarn mappings
- Backport newer recipe, translation, and interaction code to 1.20.1-compatible APIs

## Suggested workflow

1. Promote this profile into a dedicated backport branch when needed.
2. Keep `versions/1.20.1/profile.properties` as the single source of truth for the dependency line.
3. Backport only the rules that are worth maintaining on the legacy line.
