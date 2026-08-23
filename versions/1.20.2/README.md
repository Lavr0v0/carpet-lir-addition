# 1.20.2 Profile

Status: build-ready intermediate profile

This profile targets the standalone Minecraft `1.20.2` line, which Fabric and Carpet both treated as a separate port from `1.20.1`.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_20_2
```

## Notes

- Compile target: Minecraft `1.20.2`
- Declared support range: Minecraft `1.20.2`
- Version-specific sources currently reuse `src/versioned/1.20.1/`
