# 🎤 WhisperLocal iOS App

一个完全离线的 iOS 语音转文字应用，基于 OpenAI Whisper 模型。

## 🚀 项目特性

- ✅ **完全离线运行**：无需网络连接
- ✅ **高精度语音识别**：使用 Whisper Large V3 Turbo 模型
- ✅ **原生 iOS 应用**：SwiftUI + Swift
- ✅ **实时音频处理**：AVAudioEngine 集成
- ✅ **多语言支持**：支持中文等多种语言

## 📱 技术架构

### 核心技术栈
- **前端**: SwiftUI + Swift
- **音频处理**: AVAudioEngine
- **机器学习**: whisper.cpp (C++)
- **项目构建**: XcodeGen
- **模型格式**: GGML (量化模型)

### 项目结构
```
Sources/
├── Core/
│   ├── Audio/          # 音频录制和处理
│   └── Whisper/        # Whisper 引擎封装
├── Features/
│   └── Transcribe/     # 语音转文字功能
└── WhisperCpp/         # whisper.cpp 集成
```

## 🔧 安装和运行

### 前置要求
- Xcode 15.0+
- iOS 15.0+
- 至少 2GB 可用内存

### 快速开始
1. **克隆项目**
   ```bash
   git clone <your-repo-url>
   cd WhisperLocal
   ```

2. **安装依赖**
   ```bash
   # 安装 XcodeGen
   brew install xcodegen
   
   # 生成 Xcode 项目
   xcodegen generate
   ```

3. **下载模型**
   ```bash
   python download_model.py
   ```

4. **运行应用**
   ```bash
   open WhisperLocal.xcodeproj
   ```

## 📥 模型下载

### 自动下载
```bash
python download_model.py
```

### 手动下载
1. 访问 [Hugging Face](https://huggingface.co/ggerganov/whisper.cpp)
2. 下载 `ggml-large-v3-turbo.bin` (约 1.5GB)
3. 放入项目根目录

## 🚨 已知问题

### EXC_BAD_ACCESS 错误
**问题描述**: 在模型加载时出现 `ggml_backend_dev_backend_reg` 内存访问错误

**错误详情**:
```
ggml_backend_reg_t ggml_backend_dev_backend_reg(ggml_backend_dev_t device) {
    return device->reg;
}
Thread X: EXC_BAD_ACCESS (code=1, address=0x78)
```

**影响**: 应用无法加载 Whisper 模型，语音转文字功能不可用

**已尝试的解决方案**:
1. ✅ 添加完整的 GGML CPU 后端实现
2. ✅ 使用 CPU-only 参数强制 CPU 模式
3. ✅ 实现双重 API 回退机制
4. ✅ 添加详细的调试日志和错误处理

**当前状态**: 问题持续存在，需要进一步的技术支持

## 🔍 调试信息

### 控制台输出示例
```
🚀 Using new API with CPU-only parameters...
✅ Whisper context initialized successfully!
🔍 Attempting to load Whisper model from: /path/to/model
📁 Model file size: 1549 MB (1624555275 bytes)
📄 File header magic: ggml
💾 Available memory: X MB
❌ EXC_BAD_ACCESS in ggml_backend_dev_backend_reg
```

### 文件验证
- 模型文件完整性检查
- GGML 文件头验证
- 内存可用性检查

## 🛠️ 技术细节

### Whisper 集成
- 使用 `@_silgen_name` 直接调用 C 函数
- 实现 C++/Swift 桥接
- 支持新旧两种 API

### 内存管理
- 自动内存清理
- 重试机制
- 错误恢复

### 编译配置
- C++17 标准
- 完整的 GGML 源码编译
- iOS 模拟器和真机支持

## 📚 相关文档

- [CRASH_TROUBLESHOOTING_GUIDE.md](CRASH_TROUBLESHOOTING_GUIDE.md) - 崩溃问题排除指南
- [MODEL_LOADING_GUIDE.md](MODEL_LOADING_GUIDE.md) - 模型加载指南
- [WHISPER_CPP_INTEGRATION.md](WHISPER_CPP_INTEGRATION.md) - 集成状态

## 🤝 贡献和帮助

### 报告问题
如果你遇到类似问题，请：
1. 提供完整的错误日志
2. 描述设备和 iOS 版本
3. 提供重现步骤

### 寻求帮助
由于 EXC_BAD_ACCESS 问题的复杂性，建议：
- 在 [whisper.cpp Issues](https://github.com/ggerganov/whisper.cpp/issues) 报告
- 在 [Stack Overflow](https://stackoverflow.com) 寻求帮助
- 在 [Apple Developer Forums](https://developer.apple.com/forums/) 讨论

## 📄 许可证

本项目基于 MIT 许可证开源。

## 🙏 致谢

- OpenAI 的 Whisper 模型
- ggerganov 的 whisper.cpp 实现
- GGML 机器学习库
- Apple 的 iOS 开发工具

---

**注意**: 这是一个研究项目，展示了如何在 iOS 上集成离线语音识别功能。当前存在已知的技术问题，需要进一步解决。
