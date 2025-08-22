#!/bin/bash

echo "🔨 测试 Xcode 项目编译..."
echo "=================================="

# 检查 Xcode 是否可用
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode 命令行工具不可用"
    echo "请安装 Xcode 命令行工具："
    echo "xcode-select --install"
    exit 1
fi

# 尝试编译项目
echo "正在编译项目..."
xcodebuild -project WhisperLocal.xcodeproj -scheme WhisperLocal -destination 'platform=iOS Simulator,name=iPhone 15' build

if [ $? -eq 0 ]; then
    echo "✅ 编译成功！"
    echo ""
    echo "🎉 项目已准备就绪！"
    echo ""
    echo "📱 下一步："
    echo "1. 打开 WhisperLocal.xcodeproj"
    echo "2. 设置开发者签名"
    echo "3. 在真机上运行测试"
else
    echo "❌ 编译失败"
    echo ""
    echo "💡 可能的解决方案："
    echo "1. 检查 Xcode 版本是否支持 iOS 15.0+"
    echo "2. 确保所有依赖文件都存在"
    echo "3. 检查 C++ 标准库设置"
fi
