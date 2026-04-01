# Carpet LIR Addition 技术摘要

## 1. 方解石生成器

- 输入：熔岩、骨块、紫水晶块，以及用于触发熔岩转化的水流结构
- 条件：`renewableCalcite = true`，且熔岩方块下方是 `bone_block`，相邻检查位存在 `amethyst_block`
- 输出：目标熔岩方块转化为 `calcite`
- 玩家可见行为：搭法与原版玄武岩机平行，只是把 `soul_soil` 换成骨块、把 `blue_ice` 换成紫水晶块
- 失败条件：规则关闭，或骨块/紫水晶块任一条件不满足
- 验证：
  - Happy path：开启规则后，按玄武岩机思路搭建，熔岩应产出方解石
  - Negative path：关闭规则后，同结构不应产出方解石
  - Edge note：原版 `soul_soil + blue_ice -> basalt` 保持不变

## 2. 沙砾烧制凝灰岩

- 输入：`gravel`
- 条件：`renewableTuff = true`，并放入普通熔炉
- 输出：`tuff`
- 玩家可见行为：只能通过普通熔炉烧制，不支持高炉

## 3. 青金石矿配方

- 输入：`8 calcite + 1 amethyst_shard`
- 条件：`renewableLapisOre = true`，且固定工作台形状 `CCC / CAC / CCC`
- 输出：`lapis_ore x1`
- 玩家可见行为：按固定摆法合成，不改动其他青金石逻辑

## 4. 树叶配方

- 输入：`4 stick + 1 对应树种的 log`
- 条件：`renewableLeavesCrafting = true`，且固定工作台形状 ` ESE / SWS / ESE `
- 输出：对应树种的 `leaves x4`
- 玩家可见行为：开启规则后可用木棍和对应原木合成对应树叶

## 5. 生铁配方

- 输入：`8 cobblestone + 1 iron_ingot`
- 条件：`renewableRawOresCrafting = true`，且固定工作台形状 `CCC / CMC / CCC`
- 输出：`raw_iron x1`
- 玩家可见行为：直接产出生铁，不是铁矿石

## 6. 生铜配方

- 输入：`8 cobblestone + 1 copper_ingot`
- 条件：`renewableRawOresCrafting = true`，且固定工作台形状 `CCC / CMC / CCC`
- 输出：`raw_copper x1`
- 玩家可见行为：直接产出生铜，不是铜矿石

## 7. 生金配方

- 输入：`8 cobblestone + 1 gold_ingot`
- 条件：`renewableRawOresCrafting = true`，且固定工作台形状 `CCC / CMC / CCC`
- 输出：`raw_gold x1`
- 玩家可见行为：直接产出生金，不是金矿石

## 8. 蜜脾块拆回蜜脾

- 输入：`1 honeycomb_block`
- 条件：`renewableHoneycombCrafting = true`
- 输出：`honeycomb x4`
- 玩家可见行为：开启规则后可把蜜脾块拆回 4 个蜜脾

## 9. 骨粉点泥土变草方块

- 输入：`dirt` 与 `bone_meal`
- 条件：`boneMealGrassifyDirt = true`，且当前位置允许草方块正常存活
- 输出：目标 `dirt` 转化为 `grass_block`
- 玩家可见行为：开启规则后可直接用骨粉右键泥土把它变成草方块，并播放 `happy_villager` 粒子与骨粉使用音效

## 10. 紫水晶母岩活塞采集

- 输入：`budding_amethyst` 与朝向它推动的活塞或黏性活塞
- 条件：`pistonHarvestableAmethysts = true`，且活塞发生“尝试推动”事件
- 输出：原方块消失，并掉落 `budding_amethyst x1`
- 玩家可见行为：母岩不会被完整推走，而是被机械破坏并掉落自身
- 失败条件：规则关闭时仍保持原版不可推动表现
- 验证：
  - Happy path：开启规则后，活塞正推母岩应掉落 1 个母岩物品
  - Negative path：关闭规则后，同样装置不应采集成功
  - Edge note：黏性活塞回拉不会重复掉落

## 11. 强化深板岩硬度调整

- 输入：`reinforced_deepslate`
- 条件：`obsidianHardnessReinforcedDeepslate = true`
- 输出：强化深板岩的挖掘速度改为按黑曜石处理
- 玩家可见行为：开启规则后，强化深板岩的挖掘手感会接近黑曜石

## 12. 强化深板岩精准采集掉落

- 输入：`reinforced_deepslate` 与带有 `Silk Touch` 的工具
- 条件：`silkTouchableReinforcedDeepslate = true`
- 输出：掉落 `reinforced_deepslate x1`
- 玩家可见行为：开启规则后，可用精准采集直接取得强化深板岩

## 13. 坚守者掉落强化深板岩

- 输入：`warden`
- 条件：`wardensDropReinforcedDeepslate = true`
- 输出：`reinforced_deepslate x1-4`
- 玩家可见行为：开启规则后，击杀坚守者会额外掉落 1 到 4 个强化深板岩
