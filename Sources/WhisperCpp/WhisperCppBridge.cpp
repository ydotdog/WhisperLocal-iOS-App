#import "WhisperCppBridge.h"
#include "whisper.h"
#include <string>

extern "C" {

whisper_context_t* whisper_init_from_file_bridge(const char* path_model) {
    if (!path_model) {
        return nullptr;
    }
    
    try {
        // 添加额外的安全检查
        if (strlen(path_model) == 0) {
            return nullptr;
        }
        
        printf("🚀 Using new API with CPU-only parameters...\n");
        
        // 使用新的 API，但设置严格的 CPU-only 参数
        struct whisper_context_params params = whisper_context_default_params();
        params.use_gpu = false;  // 强制 CPU
        
        // 设置更保守的参数，避免设备初始化问题
        whisper_context_t* ctx = whisper_init_from_file_with_params(path_model, params);
        
        // 验证返回的上下文
        if (ctx == nullptr) {
            printf("❌ Failed to initialize with new API, trying fallback...\n");
            // 如果新 API 失败，尝试旧 API
            ctx = whisper_init_from_file(path_model);
        }
        
        if (ctx != nullptr) {
            printf("✅ Whisper context initialized successfully!\n");
        }
        
        return ctx;
    } catch (...) {
        printf("❌ Exception during Whisper initialization\n");
        return nullptr;
    }
}

void whisper_free_bridge(whisper_context_t* ctx) {
    whisper_free(ctx);
}

int whisper_full_bridge(
    whisper_context_t* ctx,
    const float* samples,
    int n_samples,
    const char* language,
    int n_threads
) {
    struct whisper_full_params params = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);
    params.print_progress = false;
    params.print_special = false;
    params.language = language;
    params.n_threads = n_threads;
    
    return whisper_full(ctx, params, samples, n_samples);
}

const char* whisper_get_text_bridge(whisper_context_t* ctx, int segment_index) {
    return whisper_full_get_segment_text(ctx, segment_index);
}

int whisper_full_n_segments_bridge(whisper_context_t* ctx) {
    return whisper_full_n_segments(ctx);
}

int64_t whisper_full_get_segment_t0_bridge(whisper_context_t* ctx, int segment_index) {
    return whisper_full_get_segment_t0(ctx, segment_index);
}

int64_t whisper_full_get_segment_t1_bridge(whisper_context_t* ctx, int segment_index) {
    return whisper_full_get_segment_t1(ctx, segment_index);
}

}
