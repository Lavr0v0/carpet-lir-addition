# Rule validation guide

Run these checks in a disposable world matching the exact target JAR. Begin each check with the named rule set to `false`, and reset it after the check so rule state cannot leak into later results. Only test rules present in that target's capability tier. Minecraft 1.14.4 intentionally exposes just `boneMealGrassifyDirt` and `renewableLeavesCrafting`; Minecraft 1.15–1.16.5 expose those two rules plus `renewableHoneycombCrafting` and exactly seven recipes; Minecraft 1.17–1.18.2 expose the eight `tier-1.17` rules and twelve recipes but none of the 1.19 reinforced-deepslate, Warden, or mangrove capabilities. Use `/carpetlir` for the Java 8 1.14.4 and 1.15–1.16.5 adapters, and `/carpet` for the other current root-profile targets.

## Renewable blocks and recipes

### `renewableCalcite`

- **Trigger:** Place lava above a bone block, with an amethyst block horizontally adjacent to or directly above the lava.
- **Happy path:** Enable the rule and update or place the lava. The lava position becomes calcite and plays the block-form event.
- **Negative path:** Disable the rule and repeat the structure. The custom conversion does not run; vanilla lava behavior continues.
- **Edge case:** With the rule enabled but without bone below or amethyst in a valid position, calcite must not form. Vanilla water and basalt generators must still work.

### `renewableCinnabar` (Minecraft 26.2+)

- **Trigger:** Let lava touch water while potent sulfur is directly below the lava and netherrack is horizontally adjacent to it. Water and netherrack may be on different horizontal sides.
- **Happy path:** Enable the rule and place or update the lava. The lava position becomes cinnabar, the block-form effect plays, and both catalyst blocks remain in place.
- **Negative path:** Disable the rule and repeat the complete structure. Carpet LIR does not intervene, so the lava-water contact produces the normal vanilla obsidian or cobblestone result.
- **Edge case:** With the rule enabled, omitting water leaves the lava unchanged; omitting netherrack lets the vanilla lava-water result form instead. Potent sulfur must be directly below, not beside the lava.

### `renewableTuff`

- **Trigger:** Put gravel in a furnace.
- **Happy path:** Enable the rule; the furnace accepts gravel and smelts one tuff in 200 ticks for 0.1 experience.
- **Negative path:** Disable the rule; Carpet LIR contributes no gravel-to-tuff furnace match.
- **Edge case:** Toggle the rule off after one successful furnace result, then change its input. Direct-only targets must find an unrelated valid fallback in the same furnace; cache-bearing targets must also discard the disabled stale match before resolving that fallback.

### `renewableLapisOre`

- **Trigger:** Fill a crafting grid with eight calcite around one amethyst shard.
- **Happy path:** Enable the rule; the output is one lapis ore.
- **Negative path:** Disable the rule; the pattern has no Carpet LIR output.
- **Edge case:** Moving either ingredient out of its specified slot must not match the shaped recipe.

### `renewableLeavesCrafting`

- **Trigger:** Put one matching log in the center and sticks above, below, left, and right.
- **Happy path:** Enable the rule; the output is four matching leaves. Validate at least one normal tree and one special case available in that tier, such as mangrove, cherry, or pale oak.
- **Negative path:** Disable the rule; none of that target's Carpet LIR leaves recipes match (six, seven, eight, or nine variants depending on the capability tier).
- **Edge case:** Mixing a log and leaves species must not produce a different species. Oak, spruce, birch, jungle, acacia, and dark oak are always available; mangrove starts in 1.19, cherry in 1.20, and pale oak in 1.21.4.

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
- **Happy path:** Enable the rule; dirt becomes grass, one bone meal is consumed in survival, and vanilla success particles fire. Targets whose API exposes the matching game event emit it as well.
- **Negative path:** Disable the rule; the callback passes through without converting dirt or consuming bone meal.
- **Edge case:** Full water or an opaque block above prevents conversion. A single snow layer above is valid and the resulting grass must have `snowy=true`; creative players do not consume bone meal, and spectators cannot convert the block even when the rule is enabled.

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
- **Negative path:** Disable the rule; vanilla piston behavior still destroys the budding amethyst but produces no item.
- **Edge case:** The replacement is scoped to the piston destruction call only. Normal mining and unrelated piston-destroyed blocks keep vanilla loot behavior.

## Automated coverage

Use `./gradlew test` for fast rule/resource integrity tests and `./gradlew runGameTest` for actual 26.x server behavior. The 26.x GameTest suite covers the highest-risk positive, disabled, permission, environmental, snowy-state, and Silk Touch loot-context paths; Minecraft 26.2 adds complete, disabled, and incomplete cinnabar-generator paths. Minecraft 1.14.4 must be smoke-tested on a Java 8 server. The `scripts/smoke-test-modern-server.ps1` harness uses a GUID-isolated disposable run directory for Minecraft 1.15–1.19.4, 1.20–1.20.6, and 1.21–1.21.11. Unit and JAR audits verify the exact three-rule/seven-recipe Minecraft 1.15–1.16.5 boundary; an overlay-specific unit test also verifies legacy translation-key conversion. The nine Java 8 server runs verify `/carpetlir`, enabled and snowy dirt conversion, survival bone-meal consumption, disabled and spectator behavior, honeycomb recipe fallback, and shutdown. Calcite and piston checks begin at Minecraft 1.17; every capability tier that exposes all three reinforced-deepslate rules also runs hardness, real Silk Touch, and Warden loot-gate checks. The harness waits for its fake player to finish logging in, rejects a server that reports a Java major other than the target profile's declared toolchain, adapts the `mob_drops` command and item-count syntax across Minecraft generations, then removes only that generated directory with `-CleanRunDirectory`.

Enhanced modern smokes on all nine exact Minecraft 1.15–1.16.5 releases, all five exact Minecraft 1.17–1.18.2 releases, exact Minecraft 1.19–1.20.1, and the representative 1.20.2, 1.20.6, and 1.21.10 boundaries deliberately cover three `RecipeManager` generations. The Java 8 fixture overrides `carpetlir:honeycomb_from_honeycomb_block` with a temporary cooking recipe, proves its enabled furnace and direct-query result, then disables `renewableHoneycombCrafting` and proves same-furnace and direct fallback to cobblestone. Later tiers run the same sequence with the controlled gravel-to-tuff recipe. The 1.15–1.18.2 runs exercise the direct three-parameter API without a match cache, the 1.19–1.20.1 runs exercise the pre-entry Pair API, and the 1.20.2 boundary run exercises the entry Pair API shared by 1.20.2–1.20.4. All five 1.19 runs and the focused Minecraft 1.21.11 regression run exercise the mangrove recipe resource, disabled/enabled reinforced-deepslate hardness, three real fake-player Silk Touch mining paths, and Warden rule-off, mob-drops-disabled, and enabled 1–4-drop paths. The 1.19/1.19.1 `/kill` checks cover the fallback death Mixin; 1.19.2–1.19.4 cover Fabric's server death event. The enabled baseline prevents a native fallback-first iteration order from creating a false positive. Release acceptance uses `-CleanRunDirectory` to remove the GUID world and temporary data pack, preventing cross-version state and large test worlds from accumulating. The 38 Minecraft 1.15–1.19.4, 1.20–1.20.6, and 1.21–1.21.11 targets stay `build-only` until equivalent full gameplay automation is ported. The remaining manual checks above are release acceptance checks, particularly the native crafting-grid shapes and in-world interaction feel.

Artifact validation is version-sensitive as well as capability-sensitive. The four audited recipe formats are:

| Minecraft targets | Resource directory | Ingredients | Crafting result | Cooking result |
| --- | --- | --- | --- | --- |
| 1.15–1.20.4 | plural `data/carpetlir/recipes/` | `{ "item": ... }` or `{ "tag": ... }` objects | `result.item` object | string item id |
| 1.20.5–1.20.6 | plural `data/carpetlir/recipes/` | item/tag objects | `result.id` object | `result.id` object |
| 1.21–1.21.1 | singular `data/carpetlir/recipe/` | item/tag objects | `result.id` object | `result.id` object |
| 1.21.2 and later audited targets | singular `data/carpetlir/recipe/` | string shorthand | `result.id` object | `result.id` object |

The JAR audit rejects a resource that lands in the wrong directory or uses the wrong ingredient/result shape even if another Minecraft generation would accept that JSON. Minecraft 1.15–1.18.2 use a direct three-parameter recipe adapter, Minecraft 1.19–1.20.1 use a pre-entry Pair-cache adapter, and 1.20.2–1.20.4 use the entry-based Pair adapter while compatible mechanics remain in shared source layers. Across the exact 1.15–1.19 lines, the audit also enforces Java bytecode, the selected old/new Carpet Rule annotation, `fabric`/`fabric-api` dependency id, legacy/registry fluid-tag adapter, tier-selected feature bootstrap, rule-translation pruning, and mutually exclusive death-Mixin/event path; the wrong-side class or server-active Mixin registration is rejected. The 1.15–1.16 audits additionally require the legacy entrypoint, custom settings manager, and physical absence of all higher-tier feature classes. The matrix requires the `carpetlir` command root, and the disposable server smoke proves `/carpetlir` is actually registered.
