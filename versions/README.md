# Version Profiles

This repository now stores version-specific build metadata under `versions/<profile>/`.

## Purpose

The goal is to keep one primary codebase while moving target-specific dependency and migration data out of the root Gradle files.
That makes it easier to:

- keep the active version clean
- document staged backports and future ports
- promote a staged target into the maintained build without rewriting the repository layout

## Layout

- `versions/<profile>/profile.properties`
  Stores machine-readable metadata such as Minecraft version, Java version, mappings mode, and build readiness.
- `versions/<profile>/README.md`
  Stores human-readable notes about the version line, migration state, and known work needed.

## Current policy

- `1.21.11`
  Maintained and build-ready in this branch.
- `1.21.9-1.21.10`
  Build-ready grouped range profile in this branch.
- `1.21.6-1.21.8`
  Build-ready grouped range profile in this branch.
- `1.21.5`
  Build-ready standalone intermediate profile in this branch.
- `1.21.4`
  Build-ready standalone intermediate profile in this branch.
- `1.21.2-1.21.3`
  Build-ready grouped range profile in this branch.
- `1.21-1.21.1`
  Build-ready grouped range profile in this branch.
- `1.21.1`
  Build-ready backport target in this branch.
- `1.20.5-1.20.6`
  Build-ready grouped range profile in this branch.
- `1.20.3-1.20.4`
  Build-ready grouped range profile in this branch.
- `1.20.2`
  Build-ready standalone intermediate profile in this branch.
- `1.20-1.20.1`
  Build-ready grouped range profile in this branch.
- `1.20.1`
  Build-ready legacy backport target in this branch.
- `26.1`
  Staged future migration target. This needs a Mojang-mappings migration and Java 25 before it can build in a dedicated branch or next-phase layout.

## Commands

List known profiles:

```bash
./gradlew listVersionProfiles
```

Show the active profile:

```bash
./gradlew printActiveVersionProfile
```

Build the maintained target:

```bash
./gradlew build
```

Build a specific ready target:

```bash
./gradlew build -PtargetKey=mc_1_21_11
./gradlew build -PtargetKey=mc_1_21_9_to_1_21_10
./gradlew build -PtargetKey=mc_1_21_6_to_1_21_8
./gradlew build -PtargetKey=mc_1_21_5
./gradlew build -PtargetKey=mc_1_21_4
./gradlew build -PtargetKey=mc_1_21_2_to_1_21_3
./gradlew build -PtargetKey=mc_1_21_to_1_21_1
./gradlew build -PtargetKey=mc_1_21_1
./gradlew build -PtargetKey=mc_1_20_5_to_1_20_6
./gradlew build -PtargetKey=mc_1_20_3_to_1_20_4
./gradlew build -PtargetKey=mc_1_20_2
./gradlew build -PtargetKey=mc_1_20_to_1_20_1
./gradlew build -PtargetKey=mc_1_20_1
```

If a target is staged but not build-ready, the build will stop early with a message pointing to that target's notes.
