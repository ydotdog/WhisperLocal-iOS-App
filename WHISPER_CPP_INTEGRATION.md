# Whisper.cpp 集成指南

## 当前状态

✅ **已完成**：
- Whisper Large V3 Turbo 模型已下载 (1.6GB)
- iOS 应用代码已完成
- 项目结构已搭建
- 应用可以编译运行（带占位函数）

❌ **待完成**：
- whisper.cpp 静态库集成

## 手动集成步骤

### 1. 下载 whisper.cpp 源码

由于网络问题，请手动下载：

**方式 1: 浏览器下载**
1. 访问：https://github.com/ggerganov/whisper.cpp
2. 点击 "Code" → "Download ZIP"
3. 解压到项目根目录，重命名为 `whisper.cpp`

**方式 2: 命令行下载（如果网络正常）**
```bash
cd /Users/kyleqi/Downloads/GPT_export/whisper
curl -L -o whisper.cpp.zip https://github.com/ggerganov/whisper.cpp/archive/refs/heads/master.zip
unzip whisper.cpp.zip
mv whisper.cpp-master whisper.cpp
rm whisper.cpp.zip
```

### 2. 编译静态库

```bash
cd whisper.cpp
make libwhisper.a
```

### 3. 复制必要文件

```bash
# 复制静态库
cp libwhisper.a ../ios_app/Sources/WhisperCpp/

# 复制头文件
cp whisper.h ../ios_app/Sources/WhisperCpp/
```

### 4. 更新桥接文件

编辑 `ios_app/Sources/WhisperCpp/WhisperCppBridge.mm`：

```objc
#import "WhisperCppBridge.h"
#include "whisper.h"  // 取消注释这行
#include <string>

whisper_context_t* whisper_init_from_file(const char* path_model) {
    return whisper_init_from_file(path_model);
}

void whisper_free(whisper_context_t* ctx) {
    whisper_free(ctx);
}

int whisper_full(
    whisper_context_t* ctx,
    const float* samples,
    int n_samples,
    const char* language,
    int n_threads
) {
    struct whisper_full_params params = whisper_full_params_default();
    params.print_progress = false;
    params.print_special = false;
    params.language = language;
    params.n_threads = n_threads;
    
    return whisper_full(ctx, params, samples, n_samples);
}

const char* whisper_get_text(whisper_context_t* ctx, int segment_index) {
    return whisper_full_get_segment_text(ctx, segment_index);
}

int whisper_full_n_segments(whisper_context_t* ctx) {
    return whisper_full_n_segments(ctx);
}

int64_t whisper_full_get_segment_t0(whisper_context_t* ctx, int segment_index) {
    return whisper_full_get_segment_t0(ctx, segment_index);
}

int64_t whisper_full_get_segment_t1(whisper_context_t* ctx, int segment_index) {
    return whisper_full_get_segment_t1(ctx, segment_index);
}
```

### 5. 在 Xcode 中配置

1. 打开 `WhisperLocal.xcodeproj`
2. 选择项目 → WhisperLocal target
3. 在 "Build Phases" → "Link Binary With Libraries" 中添加：
   - `libwhisper.a`
4. 在 "Build Settings" → "Header Search Paths" 中添加：
   - `$(SRCROOT)/Sources/WhisperCpp`
5. 在 "Build Settings" → "Library Search Paths" 中添加：
   - `$(SRCROOT)/Sources/WhisperCpp`

### 6. 重新生成工程

```bash
cd ios_app
./xcodegen/bin/xcodegen generate
```

## 验证集成

1. 在 Xcode 中构建项目
2. 如果编译成功，说明集成完成
3. 运行应用，应该能看到：
   - 模型加载成功
   - 录音功能正常
   - 转写功能工作

## 故障排除

### 编译错误
- 检查头文件路径是否正确
- 确认静态库文件存在
- 验证 C++ 标准库设置

### 链接错误
- 确认 `libwhisper.a` 已添加到链接库
- 检查库搜索路径设置

### 运行时错误
- 确认模型文件路径正确
- 检查模型文件是否完整

## 性能优化

集成完成后，可以考虑：

1. **模型量化**：使用 GGML 量化模型减少内存使用
2. **线程优化**：根据设备调整线程数
3. **批处理**：优化音频处理流程

## 下一步

集成完成后，应用将具备：
- 🎤 实时录音
- 🧠 离线语音转文字
- 🇨🇳 中文优化
- 📱 原生 iOS 体验
