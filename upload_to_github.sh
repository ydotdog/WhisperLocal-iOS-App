#!/bin/bash

# 🚀 WhisperLocal iOS App - GitHub 上传脚本

echo "🎤 准备上传 WhisperLocal iOS App 到 GitHub..."

# 检查是否在正确的目录
if [ ! -f "Sources/Features/Transcribe/ContentView.swift" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

# 检查 git 状态
if [ -d ".git" ]; then
    echo "📁 检测到现有 git 仓库"
    git status
else
    echo "📁 初始化新的 git 仓库..."
    git init
fi

# 添加所有文件
echo "📝 添加项目文件..."
git add .

# 提交更改
echo "💾 提交更改..."
git commit -m "🎤 初始提交：WhisperLocal iOS App

- 完整的 iOS 语音转文字应用
- 基于 OpenAI Whisper 模型
- 完全离线运行
- 包含已知的 EXC_BAD_ACCESS 问题记录
- 详细的调试和故障排除文档"

echo "✅ 本地提交完成！"

# 询问是否推送到远程仓库
read -p "🤔 是否要推送到远程 GitHub 仓库？(y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "🌐 请输入远程仓库 URL (例如: https://github.com/username/repo-name.git): " remote_url
    
    if [ ! -z "$remote_url" ]; then
        echo "🚀 添加远程仓库..."
        git remote add origin "$remote_url"
        
        echo "📤 推送到 GitHub..."
        git branch -M main
        git push -u origin main
        
        echo "🎉 成功推送到 GitHub！"
        echo "🔗 仓库地址: $remote_url"
    else
        echo "❌ 未提供远程仓库 URL"
    fi
else
    echo "ℹ️  跳过远程推送。你可以稍后手动推送："
    echo "   git remote add origin <your-repo-url>"
    echo "   git push -u origin main"
fi

echo ""
echo "📚 项目文档："
echo "   - README.md - 项目概述"
echo "   - GITHUB_README.md - 详细的 GitHub 说明"
echo "   - CRASH_TROUBLESHOOTING_GUIDE.md - 崩溃问题排除"
echo "   - MODEL_LOADING_GUIDE.md - 模型加载指南"
echo ""
echo "🚨 重要提醒："
echo "   当前项目存在已知的 EXC_BAD_ACCESS 问题"
echo "   建议在 GitHub 上寻求社区帮助"
echo ""
echo "🎯 下一步："
echo "   1. 在 GitHub 上创建新仓库"
echo "   2. 运行此脚本上传代码"
echo "   3. 在 Issues 中描述问题"
echo "   4. 寻求社区帮助解决技术问题"
