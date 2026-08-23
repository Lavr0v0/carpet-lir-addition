# 1.20-1.20.1 Profile

Status: build-ready range profile

This profile packages the `1.20.1` source line as a shared release for Minecraft `1.20` through `1.20.1`.
It uses the `1.20.1` compile target and emits the legacy recipe path and result format required by that version line.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_20_to_1_20_1
```

## Notes

- Compile target: Minecraft `1.20.1`
- Declared support range: Minecraft `>=1.20 <1.20.2`
- Version-specific sources live under `src/versioned/1.20.1/`
