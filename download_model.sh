#!/bin/bash

# 创建模型目录
mkdir -p Sources/Models

# 下载 GGML 格式的 Large V3 Turbo 模型
echo "正在下载 Whisper Large V3 Turbo 模型..."
curl -L -o Sources/Models/ggml-large-v3.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin

# 检查下载是否成功
if [ -f "Sources/Models/ggml-large-v3.bin" ]; then
    echo "✅ 模型下载成功: Sources/Models/ggml-large-v3.bin"
    echo "模型大小: $(du -h Sources/Models/ggml-large-v3.bin | cut -f1)"
else
    echo "❌ 模型下载失败"
    exit 1
fi

echo "模型准备完成！"
