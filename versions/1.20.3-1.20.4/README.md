# 1.20.3-1.20.4 Profile

Status: build-ready intermediate range profile

This profile packages the `1.20.4` compile target as a shared release for Minecraft `1.20.3` through `1.20.4`, matching the official Fabric/Carpet grouping for that patch line.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_20_3_to_1_20_4
```

## Notes

- Compile target: Minecraft `1.20.4`
- Declared support range: Minecraft `>=1.20.3 <1.20.5`
- Version-specific sources currently reuse `src/versioned/1.20.1/`
