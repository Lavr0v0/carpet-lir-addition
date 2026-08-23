# 1.21.9-1.21.10 Profile

Status: build-ready intermediate range profile

This profile packages the `1.21.10` compile target as a shared release for Minecraft `1.21.9` through `1.21.10`, matching the official Fabric grouping for that patch line.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_21_9_to_1_21_10
```

## Notes

- Compile target: Minecraft `1.21.10`
- Declared support range: Minecraft `>=1.21.9 <1.21.11`
- Version-specific sources currently reuse `src/versioned/1.21.11/`
