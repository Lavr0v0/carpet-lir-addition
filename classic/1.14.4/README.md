# Minecraft 1.14.4 classic target

This directory is an isolated Java 8/Yarn build for Fabric Carpet
`1.14.4-1.3.7+v200127`. It intentionally compiles only the minimum capability
tier:

- `boneMealGrassifyDirt`
- `renewableLeavesCrafting`, with oak, spruce, birch, jungle, acacia, and dark
  oak recipes

No source or resource directory from the Minecraft 26 build is included. Build
it from the repository root with:

```powershell
.\gradlew.bat -p classic\1.14.4 clean build
```

The build produces Java 8 bytecode. It pins Yarn `1.14.4+build.16`, Fabric
Loader `0.10.5+build.213`, Fabric API `0.28.5+1.14`, and Fabric Carpet
Maven artifact `1.14.4-1.3.7+v200127`. That Carpet artifact reports runtime
mod version `1.3.7`, so the packaged metadata pins `carpet` to `=1.3.7`.

## Behavior and validation

`boneMealGrassifyDirt` uses Fabric's block-use callback. With the rule on, a
non-spectator using bone meal on dirt converts it only when the 1.14 grass
spread predicate succeeds; the server consumes one bone meal outside creative
mode and plays vanilla event 2005. With the rule off, a non-bone-meal item, an
opaque block or water above the dirt, or a spectator, the callback returns
`PASS` and vanilla behavior remains untouched. A one-layer snow cover is the
survival edge case retained from vanilla.

`renewableLeavesCrafting` gates recipe matching for exactly six owned shaped
recipe identifiers. The rule off path returns no match; the rule on path makes
four sticks plus the matching log produce four leaves. An unrelated shaped
recipe is never intercepted, which is the overlap edge case.

The `build` task runs focused tests and inspects the packaged JAR for forbidden
higher-tier rule names/classes/resources and for an exact six-recipe set. A
manual server check should exercise `/carpetlir <rule> true|false`, because this
Carpet generation exposes extension rules through its custom settings command.
