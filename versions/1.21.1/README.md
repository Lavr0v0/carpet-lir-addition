# 1.21.1 Profile

Status: staged backport

This profile tracks the 1.21.1 line as a near-modern backport target.
It is close enough to the maintained 1.21.11 branch to share most design notes, but it still needs API-level source verification before it should be marked build-ready.

## Known requirements

- Java 21 target bytecode
- Yarn mappings
- Verify Carpet extension APIs and recipe/runtime hooks against 1.21.1 internals

## Suggested workflow

1. Start from the maintained branch.
2. Switch the target profile reference for the backport branch.
3. Resolve compile/runtime mismatches and only then mark `build_ready=true`.
