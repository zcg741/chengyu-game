# 页面截图工具使用说明

## 功能说明
自动对鸿蒙成语游戏应用的各个页面进行截图，方便后续UI对比和文档制作。

## 使用方法

### 前置条件
1. 手机通过USB连接电脑
2. 手机已开启开发者模式和USB调试
3. 应用已安装并运行在手机上
4. 已安装HarmonyOS SDK（hdc命令可用）

### 运行脚本
```bash
cd /Users/zhangchengang/WorkBuddy/2026-05-06-task-1/chengyu-game
./screenshot_pages.sh
```

### 操作步骤
1. 运行脚本后，按提示准备好手机
2. 脚本会提示你导航到每个页面
3. 在手机上打开对应页面后，按回车键截图
4. 脚本会自动保存截图到 `screenshots/` 目录
5. 重复步骤3-4，直到所有页面截图完成

## 截图保存位置
```
chengyu-game/screenshots/
├── HomePage_20260511_102930.png
├── GamePage_20260511_102945.png
├── ResultPage_20260511_103005.png
├── GameOverPage_20260511_103020.png
└── CollectionPage_20260511_103035.png
```

## 手动截图方法（备选）

如果脚本无法使用，可以手动截图：

### 方法1：使用hdc命令
```bash
# 截图保存到设备
hdc shell snapshot -f /data/local/tmp/screenshot.png

# 拉取到电脑
hdc file recv /data/local/tmp/screenshot.png ./screenshots/page_name.png
```

### 方法2：使用DevEco Studio
1. 打开DevEco Studio
2. 连接设备
3. 点击右上角 "Device Manager"
4. 选择设备，点击 "Screenshot" 按钮

### 方法3：手机自带截图
直接使用手机音量键+电源键截图，然后传到电脑。

## 页面列表
| 页面 | 说明 | 导航方式 |
|------|------|----------|
| HomePage | 首页 | 应用启动页 |
| GamePage | 游戏页 | 首页点击"开始游戏" |
| ResultPage | 结果页 | 游戏页提交答案后 |
| GameOverPage | 游戏结束页 | 结果页点击"再来一局"并完成后 |
| CollectionPage | 收藏页 | 首页点击"我的收藏" |

## 注意事项
- 截图前确保页面完全加载
- 如果有动画，等待动画完成后再截图
- 建议在浅色和深色主题下分别截图
- 截图文件会按时间戳命名，不会覆盖旧截图

## 批量对比
可以使用图片对比工具（如Kaleidoscope、Beyond Compare）对比不同版本的截图，查看UI变化。
