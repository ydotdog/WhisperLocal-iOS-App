# WhisperLocal iOS App

一个完全离线的 iOS 语音转文字应用，使用 OpenAI Whisper 模型。

## 功能特性

- 🎤 实时录音采集（16kHz 单声道）
- 🧠 离线语音转文字（无需网络连接）
- 🇨🇳 中文优化
- 📱 原生 iOS 界面

## 项目结构

```
ios_app/
├── Sources/
│   ├── App/                    # 应用入口
│   ├── Core/
│   │   ├── Audio/             # 音频采集服务
│   │   └── Whisper/           # Whisper 引擎封装
│   ├── Features/
│   │   └── Transcribe/        # 转写功能
│   ├── WhisperCpp/            # C++ 桥接接口
│   ├── Models/                # Whisper 模型文件
│   └── Assets.xcassets/       # 应用资源
└── WhisperLocal.xcodeproj     # Xcode 工程文件
```

## 设置步骤

### 1. 下载 Whisper 模型

由于网络限制，请手动下载模型文件：

1. 访问 https://huggingface.co/ggerganov/whisper.cpp
2. 下载 `ggml-base.bin` 文件
3. 将文件放置到 `Sources/Models/ggml-base.bin`

或者使用命令行：
```bash
curl -L -o Sources/Models/ggml-base.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin
```

### 2. 集成 whisper.cpp

由于网络限制，需要手动集成 whisper.cpp：

1. 下载 whisper.cpp 源码：
   ```bash
   git clone https://github.com/ggerganov/whisper.cpp.git
   ```

2. 编译静态库：
   ```bash
   cd whisper.cpp
   make libwhisper.a
   ```

3. 将以下文件复制到项目中：
   - `libwhisper.a` → `Sources/WhisperCpp/`
   - `whisper.h` → `Sources/WhisperCpp/`

### 3. 在 Xcode 中配置

1. 打开 `WhisperLocal.xcodeproj`
2. 在项目设置中添加静态库：
   - 将 `libwhisper.a` 添加到 "Link Binary With Libraries"
   - 添加 `Sources/WhisperCpp` 到 "Header Search Paths"
3. 设置开发者签名
4. 构建并运行

## 使用说明

1. 启动应用后，等待模型加载完成（显示绿色勾号）
2. 点击"开始录音"按钮
3. 说话完成后点击"停止录音"
4. 等待转写完成，结果将显示在文本区域

## 技术实现

- **音频采集**: `AVAudioEngine` + 自定义 `AudioRecorder`
- **语音识别**: whisper.cpp (GGML 格式)
- **UI 框架**: SwiftUI
- **语言**: 中文 (zh)
- **采样率**: 16kHz
- **线程数**: 4

## 性能说明

- **模型大小**: ~139MB (base 模型)
- **内存使用**: ~200-300MB (运行时)
- **转写速度**: 接近实时 (取决于设备性能)
- **精度**: 高 (base 模型在中文上表现良好)

## 注意事项

- 首次启动需要加载模型，请耐心等待
- 建议在真机上测试以获得最佳性能
- 模型文件较大，请确保有足够存储空间
- 转写过程中请保持应用在前台

## 故障排除

### 模型加载失败
- 检查模型文件是否存在且完整
- 确认文件路径正确

### 编译错误
- 确保已正确集成 whisper.cpp 静态库
- 检查 C++ 标准库设置

### 录音权限
- 在设置中允许应用访问麦克风
- 重启应用后重试
