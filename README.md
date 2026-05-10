# 🏮 成语猜猜乐 - HarmonyOS 版

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Topics](https://img.shields.io/github/topics/zcg741/chengyu-game?label=topics)](https://github.com/zcg741/chengyu-game)
[![Issues](https://img.shields.io/github/issues/zcg741/chengyu-game)](https://github.com/zcg741/chengyu-game/issues)

一款基于 **ArkTS / ArkUI** 开发的鸿蒙生态成语猜谜游戏，支持手机、平板、折叠屏多端适配。

## ✨ 功能亮点

| 功能 | 说明 |
|------|------|
| 🎮 经典模式 | 随机出题，逐步提升难度 |
| 📅 每日挑战 | 每天 10 道精选题目 |
| 📚 学习模式 | 查看成语释义、出处，边玩边学 |
| 📖 错题本 | 自动收集答错成语，针对性复习 |
| 🏆 成就系统 | 连胜、通关、学习达人等多样成就 |
| 📊 数据统计 | 游戏场次、正确率、用时分析 |

## 📦 项目结构

```
chengyu-game/
├── entry/src/main/ets/        # ArkTS 源码
│   ├── pages/                 # 页面（首页、游戏、结果、学习等）
│   ├── components/            # 可复用组件
│   ├── service/               # 数据服务层
│   ├── model/                 # 数据模型
│   ├── utils/                 # 工具类
│   └── viewmodel/             # MVVM ViewModel
├── entry/src/main/resources/  # 资源文件
│   └── rawfile/
│       └── chengyu_data.json  # 510 条成语数据
├── AppScope/                  # 应用级配置
└── build-profile.json5        # 构建配置
```

## 📊 成语数据

- **总计 510 条**成语，覆盖 9 大分类：
  - 数字成语、自然成语、动物成语、形容描写
  - 情感表达、道德修养、人物成语、历史典故
  - 寓言故事、神话传说

- 每条数据包含：`word`（成语）、`pinyin`（拼音）、`explanation`（释义）、`source`（出处）、`difficulty`（难度 1-5）、`category`（分类）

## 🛠 技术栈

- **开发语言**：ArkTS
- **UI 框架**：ArkUI
- **应用模型**：Stage 模型
- **目标版本**：HarmonyOS 5.0+
- **编译构建**：Hvigor

## 🚀 快速开始

### 环境要求

- DevEco Studio 4.0+
- HarmonyOS SDK API 10+
- Node.js 16+

### 运行步骤

1. 克隆仓库
   ```bash
   git clone https://github.com/zcg741/chengyu-game.git
   cd chengyu-game
   ```

2. 用 DevEco Studio 打开项目

3. 连接真机或启动模拟器

4. 点击 **Run** ▶️ 运行到设备

## 📸 截图

（截图见 `screenshots/` 目录）

## 📄 许可证

MIT License

## 🙋 作者

Made with ❤️ by [zcg741](https://github.com/zcg741)

> 欢迎提 Issue / PR，一起完善这款鸿蒙小游戏！
