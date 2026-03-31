# Carpet LIR Addition — Codex 执行文档

## 目标
为 Minecraft Fabric Carpet 生态开发一个 Java 扩展模组 **Carpet LIR Addition**，主方向为“物品可再生化（renewable items）”与相关生存向规则。该文档面向 Codex，要求其按本文档执行实现、测试、文档和交付。

---

## 1. 技术规范

### 1.1 项目定位
- 本项目不是单纯 Scarpet 脚本，而是 **Fabric Carpet extension mod（Java 扩展模组）**。
- 实现应优先遵循 Carpet 扩展的常见结构：
  - 独立 mod id
  - 独立规则集
  - 必要时使用 mixin
  - 对外暴露清晰的 Carpet rules
- 项目名称：**Carpet LIR Addition**
- 仓库建议：`carpet-lir-addition`
- 包名建议：`org.lavro.carpetlir` 或等价反向域名格式

### 1.2 总体原则
1. **规则驱动**：每项功能必须能通过 Carpet rule 开关控制。
2. **最小侵入**：能通过已有 Fabric/Carpet 扩展点实现时，不直接做大面积覆盖式改动。
3. **可验证**：每个功能都必须带有最小测试或最小复现步骤。
4. **可维护**：规则、mixin、行为注入点、文档要一一对应。
5. **默认保守**：新增规则默认值应优先考虑 `false`，避免默认改变原版平衡。

### 1.3 代码结构要求
Codex 应按以下目录与职责组织项目：

```text
.
├─ src/main/java/
│  └─ <base package>/
│     ├─ CarpetLIRAddition.java          # 模组入口
│     ├─ LIRSettings.java                # 所有 Carpet 规则定义
│     ├─ helpers/                        # 通用工具、判定、掉落/配方辅助
│     ├─ mixins/                         # 行为注入
│     ├─ features/
│     │  ├─ renewable/                   # 可再生化相关功能
│     │  ├─ dispenser/                   # 发射器/投掷器行为扩展（若有）
│     │  └─ loot/                        # 掉落、转化、概率逻辑（若有）
│     └─ api/                            # 仅当项目内部需要稳定接口时使用
├─ src/main/resources/
│  ├─ fabric.mod.json
│  ├─ carpet-lir-addition.mixins.json
│  └─ assets/<modid>/...
├─ README.md
├─ CHANGELOG.md
├─ AGENTS.md
└─ .codex/
   └─ config.toml                        # 可选，供 Codex 项目级配置
```

### 1.4 规则设计要求
每个功能必须满足：
- 有清晰、可读的 rule 名称。
- 有一句话说明“做什么”。
- 有默认值。
- 有分类（如 `SURVIVAL`、`FEATURE`、`RENEWABLE`、`EXPERIMENTAL`；若项目自定义分类，需保持一致）。
- 规则名要遵循统一前缀策略，避免命名混乱。

建议命名方式：
- `renewable<Thing>`，例如 `renewableElytra`
- `dispenser<Behavior>`，例如 `dispenserConcreteWash`
- `mobDrop<Thing>` / `blockCycle<Thing>` 等，仅在语义更清晰时使用

### 1.5 功能实现边界
Codex 必须优先实现“原版本身不易再生、但机制上可设计为可再生”的资源，不要一开始覆盖过大范围。

第一批功能候选必须遵循以下筛选标准：
- 能明确说明触发条件
- 能明确说明产出物
- 能明确说明为什么要做成可开关规则
- 不要求大型 UI
- 不依赖客户端专属逻辑
- 不要求跨模组复杂兼容

第一批功能上限：**3 个**。不要一次性铺开十几个规则。

### 1.6 推荐的第一批实现范围
Codex 首轮只能在以下范围中择优挑选 1–3 个：
- **dispenser 行为型**：通过发射器与方块/流体/实体交互实现资源再生
- **实体掉落型**：某类实体在特定条件下增加有限、合理的再生掉落
- **方块转化型**：某方块在特定环境或事件下转化出目标资源

禁止首轮实现：
- 大型配置 UI
- 网络同步优化工程
- 客户端渲染功能
- 与多个外部模组的深度兼容
- “全物品可再生化”这种无边界改造

### 1.7 Mixin 规范
- 只有在 Fabric/Carpet 常规钩子不足时才使用 mixin。
- 每个 mixin 必须在注释或同目录文档中解释：
  - 注入目标类
  - 注入方法
  - 注入目的
  - 为什么不能更高层实现
- 禁止“一眼看不出作用”的匿名逻辑块。
- 对概率、掉落、条件判断逻辑，尽量抽到 `helpers/` 或 `features/` 中，mixin 保持薄。

### 1.8 测试与验证要求
至少满足以下之一：
1. 自动化测试（优先）
2. 可复现的手动验证脚本
3. 在 README 中给出精确的验证步骤

每个功能至少要有：
- 1 个 happy path
- 1 个 negative path（规则关闭或条件不满足时不生效）
- 1 个边界条件说明

### 1.9 文档要求
Codex 交付时必须同步更新：
- `README.md`
- `CHANGELOG.md`
- 每项规则的说明表
- 功能验证步骤

README 至少包含：
- 项目简介
- 安装说明
- 规则列表
- 每条规则的行为说明
- 验证方法
- 已知限制

### 1.10 Codex 运行约束
Codex 在仓库中必须读取并遵守：
- `AGENTS.md`
- `.codex/config.toml`（若存在）

Codex 执行规则：
- 每次任务前先阅读项目级约束文件。
- 每完成一个阶段，先跑检查再提交 diff。
- 优先提交小步、可回滚的改动。
- 修改代码时不得顺手重构无关模块。

---

## 2. 步调

### 阶段 0：仓库初始化
Codex 要完成：
1. 基于官方 Carpet extension 示例模组初始化仓库。
2. 替换模板中的 `modid`、名称、包名、描述。
3. 确认项目能成功构建。
4. 添加 `AGENTS.md`，明确项目规范。
5. 如有需要，添加 `.codex/config.toml`，约束审批策略、常用命令、项目根识别。

**阶段产物**
- 可构建的空扩展模组
- 基础 README
- AGENTS.md

### 阶段 1：规则骨架
Codex 要完成：
1. 建立 `LIRSettings` 之类的规则集中枢。
2. 添加 1 条演示规则，例如 `renewableDebugSample`。
3. 用最小逻辑证明规则确实能控制行为。
4. 为规则建立统一注释与命名风格。

**通过标准**
- 构建通过
- 游戏启动正常
- 规则可见、可切换、可影响行为

### 阶段 2：第一批真实功能（1–3 个）
Codex 要完成：
1. 先提交“候选功能分析”，从可行性、侵入性、平衡性、实现复杂度四维打分。
2. 只选择分数最高的 1–3 个功能。
3. 对每个功能生成：
   - 规则名
   - 触发条件
   - 生效范围
   - 失败条件
   - 产出逻辑
   - 验证步骤
4. 实现功能并补充文档。

**通过标准**
- 每个功能都能单独开关
- 没有因规则关闭而残留副作用
- README 中能独立验证每个功能

### 阶段 3：整理与稳固
Codex 要完成：
1. 清理重复逻辑。
2. 将条件判断与掉落逻辑从 mixin 中抽离。
3. 增补负路径验证。
4. 补齐 CHANGELOG。
5. 审查命名一致性与注释质量。

**通过标准**
- 目录职责清晰
- mixin 足够薄
- 文档与实现一致

### 阶段 4：发布前检查
Codex 要完成：
1. 运行构建、测试、静态检查（若仓库已配置）。
2. 输出“已完成 / 未完成 / 风险项 / 后续建议”四段总结。
3. 生成首版发布说明草稿。

**发布前必须回答的 6 个问题**
1. 哪些功能已经稳定？
2. 哪些功能仍属实验性？
3. 哪些地方依赖 mixin？
4. 哪些行为可能随 Minecraft/Fabric/Carpet 版本变化而失效？
5. 哪些规则默认关闭？
6. 玩家如何验证每个规则是否真的生效？

---

## 3. 参考依据

### 3.1 Carpet 侧依据
1. **Fabric Carpet 主仓库**  
   用途：确认 Carpet 本体定位、扩展生态入口、总体约定。
2. **Carpet extension 示例模组**  
   用途：作为仓库初始化模板；确认 `build.gradle`、`mod.json` 替换方式。
3. **Carpet Extra**  
   用途：参考“扩展模组 + 规则系统 + dispenser 行为 + renewable resources”的成熟做法。
4. **Scarpet 文档**  
   用途：只作对照参考，帮助判断哪些功能应该做成脚本，哪些更适合做成 Java 扩展。

### 3.2 Codex 侧依据
1. **Codex Quickstart**  
   用途：确认 Codex 的标准工作流包括连接仓库、启动任务、监控进度、审阅变更。
2. **Codex Cloud Environments**  
   用途：确认云端任务会检出仓库、运行 setup script、应用网络策略，并读取 `AGENTS.md` 来找到项目特定命令。
3. **Codex Config Basics**  
   用途：确认项目级 `.codex/config.toml` 的位置、覆盖顺序、信任模型。
4. **Custom instructions with AGENTS.md**  
   用途：确认 Codex 会在工作前读取 `AGENTS.md`，并按层级合并项目指令。
5. **Codex Prompting Guide**  
   用途：作为给 Codex 下任务时的提示词结构参考，强调清晰目标、约束、验证方式和文件范围。

### 3.3 参考依据如何落地到本项目
- **模板来源**：以 Carpet extension example mod 为起点，而不是从零搭骨架。
- **功能风格来源**：优先参考 Carpet Extra 的“规则可开关 + 生存机制扩展 + renewable resource”风格。
- **代理执行来源**：通过 `AGENTS.md` 和 `.codex/config.toml` 约束 Codex，不靠一次性长 prompt 维持一致性。
- **任务下发方式**：每次只给 Codex 一个阶段目标和明确验收标准，避免“把整个项目一次写完”的低质量输出。

---

## 建议附带到仓库的 AGENTS.md 内容
以下内容建议直接写入仓库根目录的 `AGENTS.md`：

```md
# AGENTS.md

## Project goal
Build a Fabric Carpet extension mod named Carpet LIR Addition.
Main scope: renewable-item style survival features exposed as Carpet rules.

## Non-goals
- Do not add UI-heavy features.
- Do not introduce client-only rendering features.
- Do not perform broad refactors unrelated to the current task.
- Do not add many rules at once; keep the first batch to 1-3 real features.

## Required workflow
1. Read this file before making changes.
2. Inspect the existing project structure and preserve conventions.
3. Make small, reviewable commits.
4. Run build/test checks before concluding.
5. Update README and CHANGELOG when behavior changes.

## Rule design rules
- Every feature must be guarded by a Carpet rule.
- Default to conservative values, usually false.
- Use consistent names such as renewableThing or dispenserBehavior.
- Document trigger, effect, failure conditions, and validation steps.

## Mixin rules
- Use mixins only when simpler hooks are insufficient.
- Keep mixins thin.
- Move logic into helpers or feature classes.
- Explain injection targets and purpose in comments.

## Validation rules
For each feature, provide:
- one happy-path verification
- one negative-path verification
- one edge-case note
```

---

## 给 Codex 的首轮任务模板
将下面这段直接发给 Codex：

```md
Read AGENTS.md first.

Task:
Initialize this repository as a Fabric Carpet extension mod named Carpet LIR Addition, based on the official Carpet extension example mod.

Requirements:
1. Replace template identifiers with project-specific ones.
2. Ensure the project builds successfully.
3. Add a central settings class for Carpet rules.
4. Add one minimal sample rule proving rule-driven behavior works.
5. Keep code changes minimal and reviewable.
6. Update README with setup and current rule list.
7. Add CHANGELOG with an initial unreleased section.

Output expectations:
- working project skeleton
- one sample rule
- updated README
- updated CHANGELOG
- short summary of what was changed and how to verify it
```

---

## 给 Codex 的第二轮任务模板
```md
Read AGENTS.md first.

Task:
Propose the first batch of 1-3 renewable-item features for Carpet LIR Addition.

For each candidate feature, provide:
- rule name
- trigger condition
- output/result
- implementation approach
- likely injection point or extension point
- risk level
- manual verification steps

Selection constraints:
- prefer dispenser behavior, entity-drop logic, or block-conversion logic
- avoid UI work
- avoid client-only logic
- avoid broad compatibility work
- keep implementation scope small enough for one review cycle

Then implement only the best candidate if confidence is high.
Otherwise stop after the proposal.
```

---

## 执行备注
这份文档故意把目标收窄了：先做一个**可构建、可开关、可验证**的 Carpet 扩展，再逐步加功能。原因很简单：Carpet 扩展的难点从来不是“写出一堆机制”，而是**让每个机制都能被规则化、维护化、验证化**。
