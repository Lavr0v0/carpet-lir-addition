# 1.20.1 Profile

Status: build-ready legacy backport

This profile records the 1.20.1 backport line and now builds in the current branch.
The codebase uses the shared main source tree plus `src/versioned/1.20.1/` overrides for the API differences that need legacy handling.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_20_1
```

## Notes

- Java `17`
- Yarn mappings
- Version-specific sources live under `src/versioned/1.20.1/`
- The maintained `1.21.11` line still remains the default root build target
