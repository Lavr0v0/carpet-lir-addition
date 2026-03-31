# Carpet LIR Addition

Carpet LIR Addition is a Fabric Carpet extension mod focused on renewable-item style survival features.

## Current status

This repository is initialized as a Carpet extension skeleton and currently includes one sample rule proving rule-driven behavior wiring works.

## Installation (dev)

1. Clone this repository.
2. Ensure JDK 17 is available.
3. Run:
   ```bash
   gradle build
   ```
4. Put the produced jar into a Fabric server/client `mods` folder with Fabric Carpet.

## Rule list

| Rule | Default | Category | Description |
| --- | --- | --- | --- |
| `renewableDebugSample` | `false` | `LIR`, `FEATURE` | When enabled, players receive a short chat confirmation when they join. |

## Validation steps

### Happy path
1. Start a world/server with this mod and Carpet.
2. Enable the rule: `/carpet renewableDebugSample true`.
3. Rejoin the world.
4. You should see `[LIR] renewableDebugSample is enabled.` in chat.

### Negative path
1. Set `/carpet renewableDebugSample false`.
2. Rejoin the world.
3. No LIR debug join message should appear.

### Edge note
- The message only appears on join events after the rule is enabled; existing players already online are not retroactively notified.

## Known limitations

- No real renewable-item mechanics are implemented yet.
- Mixin list is intentionally empty in this stage.
