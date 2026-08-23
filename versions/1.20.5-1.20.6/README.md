# 1.20.5-1.20.6 Profile

Status: build-ready intermediate range profile

This profile packages the `1.20.6` compile target as a shared release for Minecraft `1.20.5` through `1.20.6`, matching the official Fabric grouping for that port batch.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_20_5_to_1_20_6
```

## Notes

- Compile target: Minecraft `1.20.6`
- Declared support range: Minecraft `>=1.20.5 <1.20.7`
- Uses Java 21
- Version-specific sources currently reuse `src/versioned/1.20.1/`
