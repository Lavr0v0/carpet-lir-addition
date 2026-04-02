# 1.21.2-1.21.3 Profile

Status: build-ready intermediate range profile

This profile packages the `1.21.3` compile target as a shared release for Minecraft `1.21.2` through `1.21.3`, matching the official Fabric and Carpet grouping for that patch line.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_21_2_to_1_21_3
```

## Notes

- Compile target: Minecraft `1.21.3`
- Declared support range: Minecraft `>=1.21.2 <1.21.4`
- Version-specific sources currently reuse `src/versioned/1.21.1/`
