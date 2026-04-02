# Carpet LIR Addition / Carpet LIR Addition 模组说明

## English

### Overview

Carpet LIR Addition is a Fabric Carpet extension mod focused on renewable-resource survival mechanics.
The design goal is to stay close to vanilla Minecraft logic: simple block interactions, recipe-based automation, and rule-gated behavior with narrow code changes.

### Target stack

- Release version `1.0.0`
- Default Minecraft target `1.21.11`
- Build-ready secondary targets `1.21.1` and `1.20.1`
- Fabric Loader / Fabric API / Fabric Carpet versions are selected from the active version profile
- Java version is also selected from the active version profile

### Build

```bash
./gradlew build
```

Build output:
- `build/libs/carpet-lir-addition-mc1.21.11-1.0.0.jar`

### Version profiles

This repository now uses a version-profile layout instead of hardcoding all dependency data in the root Gradle files.

- `versions/1.21.11`
  Maintained and build-ready in the current branch.
- `versions/1.21-1.21.1`
  Build-ready grouped range profile in the current branch.
- `versions/1.21.1`
  Build-ready backport target in the current branch. Recipes are converted to the `1.21.1` format during the build.
- `versions/1.20-1.20.1`
  Build-ready grouped range profile in the current branch.
- `versions/1.20.1`
  Build-ready legacy backport target in the current branch. Recipes are converted to the legacy `data/.../recipes/` path and `1.20.1` result format during the build.
- `versions/26.1`
  Staged future migration metadata.

Useful commands:

```bash
./gradlew listVersionProfiles
./gradlew printActiveVersionProfile
./gradlew build -PtargetKey=mc_1_21_11
./gradlew build -PtargetKey=mc_1_21_to_1_21_1
./gradlew build -PtargetKey=mc_1_21_1
./gradlew build -PtargetKey=mc_1_20_to_1_20_1
./gradlew build -PtargetKey=mc_1_20_1
```

### Features

| Rule | Default | Behavior |
| --- | --- | --- |
| `renewableCalcite` | `false` | Adds a calcite branch parallel to vanilla basalt generation: bone block below plus nearby amethyst block turns lava into calcite. |
| `renewableTuff` | `false` | Enables the furnace recipe that smelts gravel into tuff. |
| `renewableLapisOre` | `false` | Enables the shaped recipe `8 calcite + 1 amethyst_shard -> 1 lapis_ore`. |
| `renewableLeavesCrafting` | `false` | Enables shaped recipes that craft `4` matching leaves from sticks plus the matching log. |
| `renewableRawOresCrafting` | `false` | Enables shaped recipes for `raw_iron`, `raw_copper`, and `raw_gold` from cobblestone plus the corresponding ingot. |
| `renewableHoneycombCrafting` | `false` | Enables the reverse recipe `1 honeycomb_block -> 4 honeycomb`. |
| `boneMealGrassifyDirt` | `false` | Lets bone meal convert dirt into grass blocks when grass can survive there. |
| `obsidianHardnessReinforcedDeepslate` | `false` | Makes reinforced deepslate break at an obsidian-like mining speed. |
| `silkTouchableReinforcedDeepslate` | `false` | Lets reinforced deepslate drop itself when mined with Silk Touch. |
| `wardensDropReinforcedDeepslate` | `false` | Makes wardens drop `1-4` reinforced deepslate on death. |
| `pistonHarvestableAmethysts` | `false` | Makes budding amethyst break and drop itself when a piston tries to push it. |

### Recipe summary

| Input | Type | Output |
| --- | --- | --- |
| `gravel` | Furnace smelting | `tuff` |
| `CCC / CAC / CCC` | Shaped crafting | `lapis_ore` |
| ` ESE / SWS / ESE ` | Shaped crafting | matching leaves x4 |
| `CCC / CMC / CCC` with `iron_ingot` | Shaped crafting | `raw_iron` |
| `CCC / CMC / CCC` with `copper_ingot` | Shaped crafting | `raw_copper` |
| `CCC / CMC / CCC` with `gold_ingot` | Shaped crafting | `raw_gold` |
| `honeycomb_block` | Shapeless crafting | `honeycomb x4` |

### Commands

Enable rules with `/carpet <rule> true`, for example:

```mcfunction
/carpet renewableCalcite true
/carpet renewableTuff true
/carpet renewableLapisOre true
/carpet renewableLeavesCrafting true
/carpet renewableRawOresCrafting true
/carpet renewableHoneycombCrafting true
/carpet boneMealGrassifyDirt true
/carpet obsidianHardnessReinforcedDeepslate true
/carpet silkTouchableReinforcedDeepslate true
/carpet wardensDropReinforcedDeepslate true
/carpet pistonHarvestableAmethysts true
```

### Validation notes

- `renewableCalcite`
  Happy path: build a basalt-style lava converter with `bone_block` below and `amethyst_block` in the catalyst position.
  Negative path: disable the rule and confirm the same setup no longer makes calcite.
  Edge note: vanilla `soul_soil + blue_ice -> basalt` remains unchanged.
- `renewableTuff`
  Happy path: gravel smelts into tuff in a furnace.
  Negative path: disable the rule and confirm the recipe stops matching.
  Edge note: blast furnace support is intentionally not added.
- `renewableLapisOre`
  Happy path: `CCC / CAC / CCC` crafts into lapis ore.
  Negative path: disable the rule and confirm the crafting output disappears.
  Edge note: this does not affect other lapis behavior.
- `renewableLeavesCrafting`
  Happy path: sticks plus a matching log craft into four matching leaves.
  Negative path: disable the rule and confirm the recipes stop matching.
  Edge note: the current recipe set targets common overworld tree families.
- `renewableRawOresCrafting`
  Happy path: cobblestone plus iron/copper/gold ingots crafts into raw ores.
  Negative path: disable the rule and confirm all three recipes stop matching.
  Edge note: if you want the anvil-smash conversion mechanic instead, see MiniTweaks and `/carpet renewableRawOres`.
- `renewableHoneycombCrafting`
  Happy path: one honeycomb block crafts back into four honeycombs.
  Negative path: disable the rule and confirm the reverse recipe stops matching.
  Edge note: the vanilla storage recipe remains unchanged.
- `boneMealGrassifyDirt`
  Happy path: bone meal on dirt converts it to grass.
  Negative path: disable the rule and confirm bone meal no longer converts dirt.
  Edge note: grass survival checks are still respected.
- `obsidianHardnessReinforcedDeepslate`
  Happy path: compare reinforced deepslate mining against obsidian with the same tool.
  Negative path: disable the rule and confirm vanilla mining speed returns.
  Edge note: only mining speed is changed, not blast resistance.
- `silkTouchableReinforcedDeepslate`
  Happy path: reinforced deepslate drops itself with Silk Touch.
  Negative path: disable the rule and confirm the added self-drop path is gone.
  Edge note: non-silk mining behavior is intentionally left alone.
- `wardensDropReinforcedDeepslate`
  Happy path: wardens drop `1-4` reinforced deepslate.
  Negative path: disable the rule and confirm the extra drop disappears.
  Edge note: the drop range is flat and does not scale with looting.
- `pistonHarvestableAmethysts`
  Happy path: a piston push breaks budding amethyst and drops the block.
  Negative path: disable the rule and confirm the piston can no longer harvest it.
  Edge note: sticky piston retract does not create a second drop.

### Translation support

Bundled locales:

- `en_us`
- `es_ar`
- `fr_fr`
- `pt_br`
- `zh_cn`
- `zh_tw`

### Compatibility notes

- Recipe viewers such as JEI can now see the added recipes even when the rules are off; the actual match is still rule-gated at runtime.
- Tool-switching or loot-prediction mods may still miss runtime-only drop changes such as reinforced deepslate Silk Touch drops, because those are implemented by runtime logic rather than static vanilla loot tables.

## 中文

### 概述

Carpet LIR Addition 是一个基于 Fabric Carpet 的扩展模组，目标是给部分难以工业化量产的资源补充更符合原版逻辑的再生方式。
整体实现优先使用原版方块行为、流体逻辑、工作台配方与熔炉配方，并把功能放在 Carpet 规则后面按需开启。

### 目标环境

- 发布版本 `1.0.0`
- 默认目标版本 `1.21.11`
- 现已可构建的次级目标 `1.21.1` 与 `1.20.1`
- Fabric Loader / Fabric API / Fabric Carpet 版本由当前激活的版本档案决定
- Java 版本也由当前激活的版本档案决定

### 构建

```bash
./gradlew build
```

产物位置：
- `build/libs/carpet-lir-addition-mc1.21.11-1.0.0.jar`

### 多版本档案

仓库现在采用版本档案目录，而不是把所有版本信息直接写死在根级 Gradle 文件里。

- `versions/1.21.11`
  当前维护中的正式构建目标。
- `versions/1.21-1.21.1`
  当前分支内已可构建的范围档案。
- `versions/1.21.1`
  当前分支内已可构建的回移植目标，配方会在构建时自动转换为 `1.21.1` 兼容格式。
- `versions/1.20-1.20.1`
  当前分支内已可构建的范围档案。
- `versions/1.20.1`
  当前分支内已可构建的旧版本回移植目标，配方会在构建时自动转换为旧版 `data/.../recipes/` 路径和 `1.20.1` 兼容结果格式。
- `versions/26.1`
  已整理元数据的未来迁移目标。

常用命令：

```bash
./gradlew listVersionProfiles
./gradlew printActiveVersionProfile
./gradlew build -PtargetKey=mc_1_21_11
./gradlew build -PtargetKey=mc_1_21_to_1_21_1
./gradlew build -PtargetKey=mc_1_21_1
./gradlew build -PtargetKey=mc_1_20_to_1_20_1
./gradlew build -PtargetKey=mc_1_20_1
```

### 功能列表

| 规则 | 默认值 | 行为 |
| --- | --- | --- |
| `renewableCalcite` | `false` | 给原版玄武岩生成逻辑补一条并行分支：下方骨块、侧边紫水晶块、熔岩转化为方解石。 |
| `renewableTuff` | `false` | 启用 `gravel -> tuff` 的普通熔炉配方。 |
| `renewableLapisOre` | `false` | 启用 `8 calcite + 1 amethyst_shard -> 1 lapis_ore` 的固定工作台配方。 |
| `renewableLeavesCrafting` | `false` | 启用“木棍 + 对应原木 -> 4 个对应树叶”的工作台配方。 |
| `renewableRawOresCrafting` | `false` | 启用粗铁、粗铜、粗金三条“圆石 + 锭 -> 原矿”的工作台配方。 |
| `renewableHoneycombCrafting` | `false` | 启用 `1 honeycomb_block -> 4 honeycomb` 的逆配方。 |
| `boneMealGrassifyDirt` | `false` | 允许骨粉把泥土转成草方块。 |
| `obsidianHardnessReinforcedDeepslate` | `false` | 让强化深板岩的挖掘速度接近黑曜石。 |
| `silkTouchableReinforcedDeepslate` | `false` | 允许强化深板岩被精准采集后掉落自身。 |
| `wardensDropReinforcedDeepslate` | `false` | 允许监守者死亡时掉落 `1-4` 个强化深板岩。 |
| `pistonHarvestableAmethysts` | `false` | 允许活塞推动紫水晶母岩时将其破坏并掉落自身。 |

### 配方汇总

| 输入 | 类型 | 输出 |
| --- | --- | --- |
| `gravel` | 熔炉烧制 | `tuff` |
| `CCC / CAC / CCC` | 有序合成 | `lapis_ore` |
| ` ESE / SWS / ESE ` | 有序合成 | 对应树叶 x4 |
| `CCC / CMC / CCC` + `iron_ingot` | 有序合成 | `raw_iron` |
| `CCC / CMC / CCC` + `copper_ingot` | 有序合成 | `raw_copper` |
| `CCC / CMC / CCC` + `gold_ingot` | 有序合成 | `raw_gold` |
| `honeycomb_block` | 无序合成 | `honeycomb x4` |

### 开启方式

通过 `/carpet <规则名> true` 开启，例如：

```mcfunction
/carpet renewableCalcite true
/carpet renewableTuff true
/carpet renewableLapisOre true
/carpet renewableLeavesCrafting true
/carpet renewableRawOresCrafting true
/carpet renewableHoneycombCrafting true
/carpet boneMealGrassifyDirt true
/carpet obsidianHardnessReinforcedDeepslate true
/carpet silkTouchableReinforcedDeepslate true
/carpet wardensDropReinforcedDeepslate true
/carpet pistonHarvestableAmethysts true
```

### 验证说明

- `renewableCalcite`
  正向验证：按玄武岩机思路搭建，把下方换成骨块、催化位换成紫水晶块，应产出方解石。
  反向验证：关闭规则后，同样结构不应产出方解石。
  边界说明：原版 `soul_soil + blue_ice -> basalt` 完全保留。
- `renewableTuff`
  正向验证：沙砾放入普通熔炉，应烧成凝灰岩。
  反向验证：关闭规则后，熔炉不再匹配这条配方。
  边界说明：不支持高炉。
- `renewableLapisOre`
  正向验证：按 `CCC / CAC / CCC` 摆放，应产出青金石矿石。
  反向验证：关闭规则后，配方不匹配。
  边界说明：不改动其他青金石逻辑。
- `renewableLeavesCrafting`
  正向验证：木棍加对应原木，应产出 4 个对应树叶。
  反向验证：关闭规则后，树叶配方不匹配。
  边界说明：当前主要覆盖常见主世界树种。
- `renewableRawOresCrafting`
  正向验证：圆石加铁/铜/金锭，应分别产出粗铁、粗铜、粗金。
  反向验证：关闭规则后，三条配方都不匹配。
  边界说明：如果你要找的是铁砧砸方块变原矿，请看 MiniTweaks 的 `/carpet renewableRawOres`。
- `renewableHoneycombCrafting`
  正向验证：一个蜜脾块可拆回 4 个蜜脾。
  反向验证：关闭规则后，逆配方不匹配。
  边界说明：原版 4 蜜脾合成蜜脾块不受影响。
- `boneMealGrassifyDirt`
  正向验证：对可正常存活草方块的位置使用骨粉点泥土，应转成草方块。
  反向验证：关闭规则后，骨粉不再把泥土变成草方块。
  边界说明：仍然遵守草方块存活条件。
- `obsidianHardnessReinforcedDeepslate`
  正向验证：同工具下比较强化深板岩与黑曜石的挖掘手感，应明显接近。
  反向验证：关闭规则后，恢复原版挖掘速度。
  边界说明：只改挖掘速度，不改爆炸抗性。
- `silkTouchableReinforcedDeepslate`
  正向验证：精准采集挖强化深板岩，应掉落自身。
  反向验证：关闭规则后，不再走这条额外掉落路径。
  边界说明：不改非精准采集行为。
- `wardensDropReinforcedDeepslate`
  正向验证：击杀监守者，应掉落 `1-4` 个强化深板岩。
  反向验证：关闭规则后，额外掉落消失。
  边界说明：掉落数量不受抢夺加成影响。
- `pistonHarvestableAmethysts`
  正向验证：活塞正推紫水晶母岩，应破坏并掉落母岩自身。
  反向验证：关闭规则后，活塞无法采集母岩。
  边界说明：黏性活塞回拉不会重复掉落。

### 多语言支持

内置语言：

- `en_us`
- `es_ar`
- `fr_fr`
- `pt_br`
- `zh_cn`
- `zh_tw`

### 兼容性说明

- JEI 之类的配方查看模组现在可以看到这些新增配方；真正能否合成仍由 Carpet 规则在运行时控制。
- 自动切换工具、掉落预判之类的模组，对“运行时掉落修改”不一定能完全识别，例如强化深板岩的精准采集掉落就是这类情况，因为它不是静态 loot table，而是运行时逻辑。
