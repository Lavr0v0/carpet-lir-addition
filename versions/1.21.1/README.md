# 1.21.1 Profile

Status: build-ready backport

This profile tracks the 1.21.1 line as a near-modern backport target and now builds in the current branch.
It shares the main source tree with the maintained line and uses `src/versioned/1.21.1/` overrides for the API differences that changed between 1.21.1 and 1.21.11.

## Build command

```bash
./gradlew build -PtargetKey=mc_1_21_1
```

## Notes

- Java `21`
- Yarn mappings
- Version-specific sources live under `src/versioned/1.21.1/`
- The maintained `1.21.11` line still remains the default root build target
