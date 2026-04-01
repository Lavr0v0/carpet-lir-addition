# 26.1 Profile

Status: staged future port

This target is intentionally stored as metadata only in the current branch.

## Why it is not build-ready here

Minecraft 26.1 changes the build model significantly:

- Fabric recommends migrating from Yarn to Mojang mappings for 26.1+
- Java 25 is required
- The Loom/plugin setup changes for unobfuscated Minecraft versions
- Existing 1.21.11-era Carpet/Fabric extension code will need a real migration pass

## Suggested workflow

1. Keep this profile as the source of truth for the target line.
2. Perform a mappings migration from the maintained 1.21.11 line first.
3. Move the 26.1 work into a dedicated migration branch once active porting begins.

## Expected next steps

- switch to Mojang mappings
- update Loom/plugin wiring for 26.1
- verify Fabric API renames and Carpet extension compatibility
- raise the toolchain to Java 25

## References

- Fabric 26.1 announcement:
  https://fabricmc.net/2026/03/14/261.html
- Fabric porting guide for 26.1 snapshots:
  https://docs.fabricmc.net/develop/porting/next
