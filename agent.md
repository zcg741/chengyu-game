# 妙语成语项目维护说明

## 项目概览

`chengyu-game` 是一款基于 HarmonyOS Stage 模型开发的离线成语猜题游戏，主要技术栈为 ArkTS + ArkUI + Hvigor。应用定位是无需联网的轻量益智游戏，核心玩法围绕成语释义、拼音、填空和接龙题型展开。

当前应用名为「妙语成语」，主模块为 `entry`，入口 Ability 是 `entry/src/main/ets/entryability/EntryAbility.ts`，首页入口为 `pages/Index`。

## 当前功能

- 经典计时模式：60 秒倒计时内连续答题。
- 闯关模式：3 条生命值，连续答对达到配置数量后进入下一关。
- 多题型出题：释义猜词、拼音猜词、填空挑战、成语接龙。
- 难度与分类筛选：难度 1-3，分类包含数字、动物、自然、人物、寓言、历史、道德、情感、形容描写、神话传说等。
- 每日挑战：每天 10 题，题型按日期轮换。
- 学习中心：浏览、搜索、筛选成语。
- 错题本、复习页、收藏/图鉴页、统计页、成就页、主题页、帮助页、关于页。
- 本地持久化：使用 Preferences 保存分数、场次、收藏、每日挑战状态、成就进度等。
- 纯离线运行：核心业务不依赖网络请求。

## 数据与资源

- 主成语数据：`entry/src/main/resources/rawfile/chengyu_data.json`
- 当前主数据量：510 条
- 当前主数据难度：1、2、3
- 当前主数据分类：10 类
- 备用/历史数据：`entry/src/main/ets/resources/chengyu-data.json`，结构为 `{ "chengyuList": [...] }`，当前 500 条。此文件与 rawfile 主数据结构不同，后续维护时不要混用。
- 拼音首字母映射：`entry/src/main/ets/utils/PinyinUtil.ets`

## 目录结构

```text
entry/src/main/ets/
├── components/      # 可复用 ArkUI 组件
├── entryability/    # 应用入口 Ability
├── model/           # 数据模型和枚举
├── pages/           # 页面
├── resources/       # ArkTS 侧历史资源
├── service/         # 数据、存储、出题、主题、成就、收藏、错题、分享、音效服务
├── utils/           # 上下文、导航、常量、拼音、安全区工具
└── viewmodel/       # 游戏和计时器状态逻辑
```

## 关键文件

- `entry/src/main/ets/pages/HomePage.ets`：首页、模式入口、难度/分类选择。
- `entry/src/main/ets/pages/GamePage.ets`：核心游戏页面，负责输入、提示、结果反馈、计时展示和路由跳转。
- `entry/src/main/ets/viewmodel/GameViewModel.ets`：核心游戏状态、出题、判题、计分、成就更新。
- `entry/src/main/ets/viewmodel/TimerViewModel.ets`：倒计时逻辑。
- `entry/src/main/ets/service/ChengyuService.ets`：从 rawfile 加载成语、过滤、随机取题。
- `entry/src/main/ets/service/QuestionService.ets`：统一出题提示、填空生成、答案标准化、动态题型权重。
- `entry/src/main/ets/service/StorageService.ets`：Preferences 封装。
- `entry/src/main/ets/service/AchievementService.ets`：成就定义和进度更新。
- `entry/src/main/ets/service/CollectionService.ets`：答对后自动收集成语。
- `entry/src/main/ets/service/WrongBookService.ets`：结构化错题记录、复习结果和掌握状态。
- `entry/src/main/ets/service/DailyChallengeService.ets`：每日挑战记录、日期与连续打卡统计。
- `entry/src/main/ets/utils/NavUtil.ets`：路由封装，目前仍使用 `router.pushUrl` / `router.replaceUrl`。
- `entry/src/main/ets/utils/Constants.ets`：游戏配置、存储键、模式和题型常量。

## 运行与构建

推荐使用 DevEco Studio 打开项目根目录：

```text
/Users/zhangchengang/WorkBuddy/2026-05-06-task-1/chengyu-game
```

建议环境：

- DevEco Studio 6.x
- HarmonyOS SDK 6.1.0 / API 23 或项目配置对应版本
- 使用 DevEco Studio 执行 Sync、Build、Run

注意事项：

- 本仓库没有标准 npm 脚本。
- 根目录和 entry 目录都有 `oh-package.json5`。
- `build-profile.json5` 中存在本机绝对路径签名配置和敏感签名材料引用。提交公开仓库前应改成模板或本地私有配置，不要把真实签名信息继续放在版本库里。

## 核心业务流

1. `EntryAbility` 保存应用上下文并加载 `pages/Index`。
2. `Index` 延迟跳转到 `HomePage`。
3. `HomePage` 选择模式、难度、分类后跳转到 `GamePage`。
4. `GamePage.aboutToAppear()` 读取路由参数，初始化 `GameViewModel`。
5. `GameViewModel.initGame()` 加载成语数据、初始化成就、读取已玩记录并创建游戏会话。
6. `loadNextQuestion()` 根据 `QuestionService` 的动态题型权重和接龙状态取题。
7. `submitAnswer()` 通过 `QuestionService` 标准化用户输入并判题。
8. 答对后更新分数、连胜、收藏、成就；答错后扣分、增加提示等级、闯关模式扣生命。
9. 游戏结束时 `endGame()` 写入总场次、总答对、最高分、总积分、已玩成语记录。
10. `GamePage` 跳转到 `GameOverPage` 展示结算和答题记录。

## 当前维护状态

- 工作区已有未提交源码改动，涉及出题、图鉴、错题、每日挑战、成就、分享和文档。
- 后续修改源码前应先确认这些改动的来源与意图，避免覆盖用户已有工作。
- `PROJECT_STATUS.md`、`COMPLETE_STATUS.md` 包含历史通信故障和修复记录，不应作为最新产品文档直接对外发布。
- `TestReport.md` 中仍有过期信息，例如 50 条数据、旧版提示逻辑等，需要重新验证后更新。

## 已知风险与优化点

### P0：优先处理

1. 签名配置安全
   - `build-profile.json5` 包含本机签名文件路径和敏感签名配置。应改为本地配置模板、环境变量或不入库的 signing profile。

2. 成就 ID 不一致
   - 已优化：`AchievementPage.ets` 改为复用 `AchievementService.ets` 的成就定义，避免页面展示 ID 与服务写入 ID 分叉。

3. 拼音映射可靠性
   - 已优化核心路径：经典模式和每日挑战的提示优先使用题库 `pinyin` 字段提取首字母。
   - 剩余风险：`PinyinUtil.ets` 的内置汉字映射表仍作为兜底存在，后续应重新生成或精简。

4. 每日挑战非固定题目
   - 已优化：每日挑战使用日期种子抽题，同一天题目固定，换日期自动变化。

### P1：建议尽快处理

1. 随机抽题算法
   - 已优化：`ChengyuService.ets` 改为 Fisher-Yates 洗牌，并提供可选 seed 的抽题 API，供每日挑战复用。

2. 已玩记录可能导致题库耗尽
   - `played_idioms` 会跨局累积并作为排除条件。
   - 当玩家玩过所有题后，普通模式会无题可出并结束游戏。
   - 建议按模式/难度/分类维护题池，或题库用尽后进入复习池/自动重置。

3. 导航 API 老化
   - `NavUtil.ets` 注释已说明 `pushUrl` / `replaceUrl` / `getParams` 已弃用。
   - 后续应统一迁移到 Navigation 或当前 SDK 推荐的 named route 方案。

4. 统计键分散
   - 有 `STORAGE_KEYS`，但很多地方仍直接写字符串 key。
   - 建议统一收敛到常量，降低 typo 和迁移成本。

5. 业务逻辑重复
   - 已优化：`QuestionService.ets` 已收敛经典模式和每日挑战的判题标准化、填空生成、提示生成和新手题型保护。
   - 剩余建议：让复习模式继续接入同一套出题服务。

### P2：体验与工程质量

1. 文档统一
   - README、功能文档、测试报告对数据量、分类数、难度范围、提示逻辑描述不完全一致。
   - 建议以 rawfile 主数据和当前代码为准统一刷新。

2. 分享与广告能力
   - `ShareService.ets` 已实现成绩文案生成和剪贴板复制，仍未接系统分享面板或图片卡片。
   - `AdView.ets` 仍是占位实现；若要上线广告，需要按目标 HarmonyOS API 重新集成。

3. 音效资源
   - 音效服务存在，但需要确认 rawfile 中是否有真实音频资源，并在设备上验证生命周期释放。

4. 自动化验证
   - 当前缺少可重复的单元测试或基础脚本。
   - 优先给 `PinyinUtil`、`GameViewModel` 判题逻辑、随机出题、成就进度、每日挑战种子逻辑补测试。

5. UI 适配
   - 页面使用较多 emoji 和固定圆角/字号，建议在真机上验证小屏、大字体、深色主题、折叠屏横竖屏。

## 后续开发建议

1. 先修复 P0 风险，尤其是签名配置、成就 ID、拼音映射和每日挑战固定题。
2. 继续把复习模式接入统一出题与提示逻辑，让经典模式、每日挑战、复习模式完全复用同一套规则。
3. 继续完善成语图鉴：补分类进度、搜索、详情分享卡片。
4. 继续完善错题复习闭环：专门错题练习入口、复习统计和掌握状态反馈。
5. 刷新 README 和测试报告，去掉历史通信故障文档或移动到内部归档。

## 给后续 Agent 的工作约定

- 修改前先运行 `git status --short`，确认用户已有改动。
- 不要覆盖上述已存在的源码改动，除非用户明确要求。
- 优先使用 `rg` / `rg --files` 了解代码。
- 手动编辑文件优先使用 `apply_patch`。
- 涉及 ArkTS API 升级时，以当前 DevEco Studio 和 HarmonyOS SDK 文档为准。
- 不要把真实签名证书、profile、密码或本机绝对签名路径写入公开文档或提交。
- 如果调整题库结构，同时更新 `ChengyuService.ets`、学习页、收藏页、每日挑战和相关文档。
