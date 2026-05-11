#!/bin/bash

# 鸿蒙成语游戏 - 页面截图脚本
# 使用方法：运行脚本后，手动切换到目标页面，按回车截图

SCREENSHOT_DIR="./screenshots"
mkdir -p "$SCREENSHOT_DIR"

echo "================================"
echo "鸿蒙成语游戏 - 页面截图工具"
echo "================================"
echo ""

# 截图函数
take_screenshot() {
    local page_name=$1
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local filename="${SCREENSHOT_DIR}/${page_name}_${timestamp}.png"
    
    echo "📸 正在截图: $page_name"
    
    # 使用hdc命令截图（保存到设备临时目录）
    hdc shell snapshot -f /data/local/tmp/screenshot.png
    
    # 拉取到本地
    hdc file recv /data/local/tmp/screenshot.png "$filename"
    
    if [ -f "$filename" ]; then
        echo "✅ 截图已保存: $filename"
    else
        echo "❌ 截图失败，请检查设备连接"
    fi
    echo ""
}

# 页面列表
pages=(
    "HomePage:首页"
    "GamePage:游戏页"
    "ResultPage:结果页"
    "GameOverPage:游戏结束页"
    "CollectionPage:收藏页"
)

echo "请确保："
echo "1. 手机已通过USB连接电脑"
echo "2. 已开启开发者模式和USB调试"
echo "3. 应用已安装并运行"
echo ""
echo "按回车键开始..."
read

for page in "${pages[@]}"; do
    page_key=$(echo "$page" | cut -d':' -f1)
    page_desc=$(echo "$page" | cut -d':' -f2)
    
    echo "================================"
    echo "准备截图: $page_desc ($page_key)"
    echo "================================"
    echo "请在手机上导航到【$page_desc】"
    echo "准备好后，按回车键截图..."
    read
    
    take_screenshot "$page_key"
    
    echo "--------------------------------"
    echo "是否继续截图下一个页面？(Y/n)"
    read -r continue_choice
    
    if [ "$continue_choice" = "n" ] || [ "$continue_choice" = "N" ]; then
        echo "截图任务已取消"
        break
    fi
done

echo ""
echo "================================"
echo "✅ 截图任务完成！"
echo "截图保存在: $SCREENSHOT_DIR"
echo "================================"

# 生成截图清单
echo ""
echo "生成截图清单..."
ls -lh "$SCREENSHOT_DIR" > "$SCREENSHOT_DIR/README.txt"
cat "$SCREENSHOT_DIR/README.txt"

