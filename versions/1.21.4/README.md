# 1.21.4 Profile

Status: build-ready intermediate profile

This profile targets the standalone Minecraft `1.21.4` line, which Fabric and Carpet both treated as its own port from the surrounding `1.21.x` releases.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_21_4
```

## Notes

- Compile target: Minecraft `1.21.4`
- Declared support range: Minecraft `1.21.4`
- Version-specific sources currently reuse `src/versioned/1.21.1/`
