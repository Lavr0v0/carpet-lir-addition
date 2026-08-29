# Carpet LIR Addition 技术摘要

## 规则命令

- 查询当前值与说明：`/carpet <规则名>`
- 仅在当前服务器运行中修改：`/carpet <规则名> true|false`
- 立即修改并跨重启保存：`/carpet setDefault <规则名> true|false`
- 删除保存值并恢复代码默认值：`/carpet removeDefault <规则名>`
- Minecraft 1.14.4–1.16.5 使用 `/carpetlir` 前缀，后续子命令相同。

## 1. 方解石生成器

- 输入：熔岩、骨块与普通紫水晶块；不需要水
- 条件：`renewableCalcite = true`，目标熔岩正下方是 `bone_block`，并且水平四邻或正上方存在普通 `amethyst_block`
- 输出：目标熔岩方块转化为 `calcite`
- 玩家可见行为：先开启规则并搭好催化结构，再放置熔岩或更新其邻居，目标熔岩才会转化
- 失败条件：规则关闭、骨块位置错误、使用紫水晶母岩/晶芽/晶簇/碎片，或普通紫水晶块不在有效位置
- 验证：
  - Happy path：使用“骨块正下方、普通紫水晶块在侧面、无水”的最小结构，开启规则后最后放置熔岩，应产出方解石
  - Negative path：关闭规则后，同结构中的熔岩保持原版行为
  - Edge note：仅切换规则不会追溯扫描并替换已有的熔岩、黑曜石、圆石或玄武岩；原版 `soul_soil + blue_ice -> basalt` 保持不变

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
- 资源边界：该规则只回收世界中已有的紫水晶母岩，不会生成新的母岩，因此不属于 `RENEWABLE` 分类
- 失败条件：规则关闭时保持原版结果——母岩仍会被活塞机械破坏，但不会掉落母岩物品
- 验证：
  - Happy path：开启规则后，活塞正推母岩应掉落 1 个母岩物品
  - Negative path：关闭规则后，同样装置不应采集成功
  - Edge note：黏性活塞回拉不会重复掉落

以下三条强化深板岩规则彼此独立；项目中不存在一条统一的“深板岩再生”规则。硬度规则只改变挖掘，精准采集规则只回收已有方块，只有监守者掉落规则会持续产生新的强化深板岩。

## 11. 强化深板岩硬度调整

- 输入：`reinforced_deepslate`
- 条件：`obsidianHardnessReinforcedDeepslate = true`
- 输出：强化深板岩的挖掘速度改为按黑曜石处理
- 玩家可见行为：开启规则后，强化深板岩的挖掘手感会接近黑曜石；不会增加任何掉落
- 分类：只属于 `LIR` 与 `FEATURE`，不属于 `RENEWABLE`

## 12. 强化深板岩精准采集掉落

- 输入：`reinforced_deepslate` 与带有 `Silk Touch` 的工具
- 条件：`silkTouchableReinforcedDeepslate = true`
- 输出：掉落 `reinforced_deepslate x1`
- 玩家可见行为：开启规则后，可用精准采集回收已有的强化深板岩；不会凭空创建新方块
- 分类：只属于 `LIR` 与 `FEATURE`，不属于 `RENEWABLE`

## 13. 监守者掉落强化深板岩

- 输入：`warden`
- 条件：`wardensDropReinforcedDeepslate = true`，且生物掉落游戏规则开启
- 输出：`reinforced_deepslate x1-4`
- 玩家可见行为：开启规则后，击杀监守者会额外掉落 1 到 4 个强化深板岩，这是三条规则中唯一的可再生来源

## 14. 朱砂生成器（Minecraft 26.2+）

- 输入：熔岩、水、强效硫磺与下界岩
- 条件：`renewableCinnabar = true`，熔岩正下方是 `potent_sulfur`，水平相邻位置同时能找到水与 `netherrack`
- 输出：目标熔岩方块转化为 `cinnabar`
- 玩家可见行为：在原版熔岩遇水固化的结构上增加硫磺与下界岩催化条件；强效硫磺和下界岩均不消耗
- 失败条件：规则关闭时完全采用原版熔岩遇水结果；缺水、缺强效硫磺或缺下界岩时均不生成朱砂
- 验证：
  - Happy path：完整结构开启规则后产出朱砂，两个催化方块仍在原位
  - Negative path：关闭规则后，同结构按熔岩状态生成原版黑曜石或圆石
  - Edge note：缺水时熔岩保持不变；有水但缺下界岩时走原版固化分支
