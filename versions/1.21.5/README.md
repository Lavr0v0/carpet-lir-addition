# 1.21.5 Profile

Status: build-ready intermediate profile

This profile targets the standalone Minecraft `1.21.5` line, which Fabric and Carpet both treated as its own port from the surrounding `1.21.x` releases.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_21_5
```

## Notes

- Compile target: Minecraft `1.21.5`
- Declared support range: Minecraft `1.21.5`
- Version-specific sources currently reuse `src/versioned/1.21.1/`
