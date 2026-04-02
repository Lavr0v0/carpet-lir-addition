# 1.21-1.21.1 Profile

Status: build-ready range profile

This profile packages the `1.21.1` source line as a shared release for Minecraft `1.21` through `1.21.1`.
It uses the `1.21.1` compile target and emits the `1.21.1` recipe schema expected by that version line.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_21_to_1_21_1
```

## Notes

- Compile target: Minecraft `1.21.1`
- Declared support range: Minecraft `>=1.21 <1.21.2`
- Version-specific sources live under `src/versioned/1.21.1/`
