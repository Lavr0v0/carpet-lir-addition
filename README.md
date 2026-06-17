# Carpet LIR Addition

Carpet LIR Addition is a Fabric Carpet extension mod focused on renewable-item style survival features.

The development target is Minecraft Java Edition 26.2 on Fabric, with Java 25 and Carpet 26.2.

## Installation

Put the matching release jar into a Fabric server/client `mods` folder together with Fabric API and Fabric Carpet.

For local development:

```powershell
.\gradlew.bat build
```

## Rules

All rules are registered through Carpet's normal `/carpet` command. Defaults are conservative and remain `false`.

| Rule | Default | Categories | Effect |
| --- | --- | --- | --- |
| `renewableCalcite` | `false` | `LIR`, `FEATURE`, `RENEWABLE` | Lava flowing over bone blocks can generate calcite when an adjacent amethyst block is detected in the same positions used by vanilla basalt generation. |
| `renewableTuff` | `false` | `LIR`, `FEATURE`, `RENEWABLE` | Enables the furnace recipe that smelts gravel into tuff. |
| `renewableLapisOre` | `false` | `LIR`, `FEATURE`, `RENEWABLE` | Enables the calcite and amethyst shard crafting recipe for lapis ore. |
| `renewableLeavesCrafting` | `false` | `LIR`, `FEATURE`, `RENEWABLE` | Enables shaped recipes that turn sticks plus matching logs into corresponding leaves. |
| `renewableRawOresCrafting` | `false` | `LIR`, `FEATURE`, `RENEWABLE` | Enables cobblestone plus ingot recipes for raw iron, raw copper, and raw gold. |
| `renewableHoneycombCrafting` | `false` | `LIR`, `FEATURE`, `RENEWABLE` | Enables converting one honeycomb block back into four honeycombs. |
| `boneMealGrassifyDirt` | `false` | `LIR`, `FEATURE`, `RENEWABLE` | Allows bone meal used on dirt to convert it into a grass block when grass can survive there. |
| `obsidianHardnessReinforcedDeepslate` | `false` | `LIR`, `FEATURE`, `RENEWABLE` | Makes reinforced deepslate break at an obsidian-like mining speed. |
| `silkTouchableReinforcedDeepslate` | `false` | `LIR`, `FEATURE`, `RENEWABLE` | Allows reinforced deepslate to drop itself when mined with Silk Touch. |
| `wardensDropReinforcedDeepslate` | `false` | `LIR`, `FEATURE`, `RENEWABLE` | Makes wardens drop 1 to 4 reinforced deepslate when they die. |
| `pistonHarvestableAmethysts` | `false` | `LIR`, `FEATURE`, `RENEWABLE` | Budding amethyst breaks and drops itself when a piston tries to push it. |

## Validation

Happy path: enable the matching rule with `/carpet <rule> true`, then perform the documented action such as crafting, lava generation, bone-mealing dirt, mining reinforced deepslate, killing a warden, or piston-pushing budding amethyst.

Negative path: leave the rule at `false` and verify vanilla behavior is unchanged.

Edge note: recipe rules are filtered during recipe lookup; clients may need a recipe book refresh or rejoin for visible recipe-book state to catch up.
