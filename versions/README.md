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
- `1.21.1`
  Staged backport target. Metadata is ready, but source compatibility work is still pending.
- `1.20.1`
  Staged legacy backport target. Metadata is ready, but source compatibility work is still pending.
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

Attempt a specific target:

```bash
./gradlew build -PtargetKey=mc_1_21_11
```

If a target is staged but not build-ready, the build will stop early with a message pointing to that target's notes.
