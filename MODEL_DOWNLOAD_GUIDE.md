# Whisper Large V3 模型下载指南

## 模型信息

- **模型名称**: Whisper Large V3
- **文件大小**: ~1.5GB
- **格式**: GGML (优化用于移动设备)
- **语言支持**: 多语言，中文优化
- **精度**: 极高 (比 base 模型更准确)

## 下载方式

### 方式 1: 直接下载 (推荐)

在浏览器中访问以下链接，然后手动下载：

```
https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin
```

下载完成后，将文件重命名为 `ggml-large-v3.bin` 并放置到：
```
ios_app/Sources/Models/ggml-large-v3.bin
```

### 方式 2: 使用 curl (如果网络正常)

```bash
cd ios_app
curl -L -o Sources/Models/ggml-large-v3.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin
```

### 方式 3: 使用 wget (如果已安装)

```bash
cd ios_app
wget -O Sources/Models/ggml-large-v3.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin
```

### 方式 4: 使用 Python (如果网络有问题)

```python
import requests

url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin"
output_path = "ios_app/Sources/Models/ggml-large-v3.bin"

print("开始下载 Whisper Large V3 模型...")
response = requests.get(url, stream=True)
response.raise_for_status()

with open(output_path, 'wb') as f:
    for chunk in response.iter_content(chunk_size=8192):
        f.write(chunk)

print(f"下载完成: {output_path}")
```

## 验证下载

下载完成后，验证文件：

```bash
cd ios_app
ls -lh Sources/Models/ggml-large-v3.bin
```

应该显示文件大小约为 1.5GB。

## 替代方案

如果无法下载 Large V3 模型，可以使用较小的模型：

### Base 模型 (~139MB)
```
https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin
```

### Small 模型 (~244MB)
```
https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin
```

### Medium 模型 (~769MB)
```
https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin
```

## 性能对比

| 模型 | 大小 | 精度 | 速度 | 内存使用 |
|------|------|------|------|----------|
| Base | 139MB | 中等 | 快 | ~200MB |
| Small | 244MB | 良好 | 中等 | ~300MB |
| Medium | 769MB | 很好 | 较慢 | ~500MB |
| Large V3 | 1.5GB | 极高 | 慢 | ~800MB |

## 注意事项

1. **存储空间**: 确保设备有足够空间存储模型文件
2. **网络稳定性**: 大文件下载可能需要较长时间
3. **首次加载**: Large V3 模型首次加载时间较长，请耐心等待
4. **内存使用**: 运行时需要更多内存，建议在较新的设备上使用

## 故障排除

### 下载失败
- 检查网络连接
- 尝试使用 VPN
- 使用不同的下载工具

### 文件损坏
- 重新下载文件
- 检查文件大小是否正确
- 验证文件完整性

### 加载失败
- 确认文件路径正确
- 检查文件权限
- 重启应用
