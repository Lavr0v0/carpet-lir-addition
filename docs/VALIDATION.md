# Rule validation guide

Run these checks in a disposable world matching the exact target JAR. Begin each check with the named rule set to `false`, and reset it after the check so rule state cannot leak into later results. Only test rules present in that target's capability tier; 1.14.4 intentionally exposes just `boneMealGrassifyDirt` and `renewableLeavesCrafting`.

## Renewable blocks and recipes

### `renewableCalcite`

- **Trigger:** Place lava above a bone block, with an amethyst block horizontally adjacent to or directly above the lava.
- **Happy path:** Enable the rule and update or place the lava. The lava position becomes calcite and plays the block-form event.
- **Negative path:** Disable the rule and repeat the structure. The custom conversion does not run; vanilla lava behavior continues.
- **Edge case:** With the rule enabled but without bone below or amethyst in a valid position, calcite must not form. Vanilla water and basalt generators must still work.

### `renewableTuff`

- **Trigger:** Put gravel in a furnace.
- **Happy path:** Enable the rule; the furnace accepts gravel and smelts one tuff in 200 ticks for 0.1 experience.
- **Negative path:** Disable the rule; Carpet LIR contributes no gravel-to-tuff furnace match.
- **Edge case:** Toggle the rule off after a furnace cached the recipe, then change its input. The disabled cached hint must be discarded so unrelated valid recipes still resolve.

### `renewableLapisOre`

- **Trigger:** Fill a crafting grid with eight calcite around one amethyst shard.
- **Happy path:** Enable the rule; the output is one lapis ore.
- **Negative path:** Disable the rule; the pattern has no Carpet LIR output.
- **Edge case:** Moving either ingredient out of its specified slot must not match the shaped recipe.

### `renewableLeavesCrafting`

- **Trigger:** Put one matching log in the center and sticks above, below, left, and right.
- **Happy path:** Enable the rule; the output is four matching leaves. Validate at least one normal tree and one special case such as pale oak or mangrove.
- **Negative path:** Disable the rule; none of the nine Carpet LIR leaves recipes match.
- **Edge case:** Mixing a log and leaves species must not produce a different species. Supported types are oak, spruce, birch, jungle, acacia, dark oak, mangrove, cherry, and pale oak.

### `renewableRawOresCrafting`

- **Trigger:** Fill eight outer crafting slots with cobblestone and put an iron, copper, or gold ingot in the center.
- **Happy path:** Enable the rule; the output is one matching raw ore.
- **Negative path:** Disable the rule; none of the three Carpet LIR raw-ore recipes match.
- **Edge case:** Stone, deepslate, or a mismatched material must not substitute for cobblestone or the center ingot.

### `renewableHoneycombCrafting`

- **Trigger:** Put one honeycomb block anywhere in a crafting grid.
- **Happy path:** Enable the rule; the output is four honeycombs.
- **Negative path:** Disable the rule; Carpet LIR contributes no reverse recipe.
- **Edge case:** Waxed copper and honey blocks are unrelated and must not match.

## World interactions

### `boneMealGrassifyDirt`

- **Trigger:** Use bone meal on a dirt block where a grass block can survive.
- **Happy path:** Enable the rule; dirt becomes grass, one bone meal is consumed in survival, and the vanilla success particles and game event fire.
- **Negative path:** Disable the rule; the callback passes through without converting dirt or consuming bone meal.
- **Edge case:** Full water or an opaque block above prevents conversion. A single snow layer above is valid, creative players do not consume bone meal, and spectators cannot convert the block even when the rule is enabled.

### `obsidianHardnessReinforcedDeepslate`

- **Trigger:** Mine reinforced deepslate.
- **Happy path:** Enable the rule; its destroy speed and actual mining progress match obsidian.
- **Negative path:** Disable the rule; the block retains its vanilla reinforced-deepslate mining behavior.
- **Edge case:** This rule changes speed only. It does not itself add a drop; use `silkTouchableReinforcedDeepslate` independently for loot.

### `silkTouchableReinforcedDeepslate`

- **Trigger:** Break reinforced deepslate with a tool carrying Silk Touch.
- **Happy path:** Enable the rule; exactly one reinforced deepslate item is returned.
- **Negative path:** Disable the rule or use a non-Silk-Touch tool; the custom loot path does not run.
- **Edge case:** Missing or empty tool context must not create a drop. The hardness rule may be enabled separately to make a survival test practical.

### `wardensDropReinforcedDeepslate`

- **Trigger:** Kill a Warden.
- **Happy path:** Enable the rule with `mob_drops` enabled; the Warden drops 1–4 reinforced deepslate in addition to vanilla loot.
- **Negative path:** Disable the rule; no reinforced deepslate is added.
- **Edge case:** Set `mob_drops` to `false`; the additional drop must also be suppressed. `block_drops` is intentionally irrelevant.

### `pistonHarvestableAmethysts`

- **Trigger:** Power a piston facing budding amethyst.
- **Happy path:** Enable the rule; vanilla destroys the budding amethyst and Carpet LIR drops one budding-amethyst item.
- **Negative path:** Disable the rule; Minecraft 26.2 still destroys the budding amethyst but produces no item.
- **Edge case:** The replacement is scoped to the piston destruction call only. Normal mining and unrelated piston-destroyed blocks keep vanilla loot behavior.

## Automated coverage

Use `./gradlew test` for fast rule/resource integrity tests and `./gradlew runGameTest` for actual 26.x server behavior. The 26.x GameTest suite covers the highest-risk positive, disabled, permission, environmental, and Silk Touch loot-context paths. Minecraft 1.14.4 must be smoke-tested on a Java 8 server. The `scripts/smoke-test-modern-server.ps1` harness uses a unique disposable run directory to exercise rule-on, rule-off, spectator, live furnace-cache invalidation, and shutdown behavior for current Yarn targets, then can remove only that generated directory with `-CleanRunDirectory`. Minecraft 1.21.9–1.21.11 stay `build-only` until equivalent full gameplay automation is ported. The remaining manual checks above are release acceptance checks, particularly recipe shapes and in-world interaction feel.
