# 1.21.6-1.21.8 Profile

Status: build-ready intermediate range profile

This profile packages the `1.21.8` compile target as a shared release for Minecraft `1.21.6` through `1.21.8`, matching the official Fabric grouping and the grouped Carpet release for `1.21.7/1.21.8`.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_21_6_to_1_21_8
```

## Notes

- Compile target: Minecraft `1.21.8`
- Declared support range: Minecraft `>=1.21.6 <1.21.9`
- Version-specific sources currently reuse `src/versioned/1.21.11/`
