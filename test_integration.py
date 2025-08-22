#!/usr/bin/env python3
"""
测试 whisper.cpp 集成
"""
import os
import sys

def test_files():
    """测试必要文件是否存在"""
    files = [
        "Sources/WhisperCpp/whisper.h",
        "Sources/WhisperCpp/whisper.cpp", 
        "Sources/WhisperCpp/ggml.h",
        "Sources/WhisperCpp/WhisperCppBridge.h",
        "Sources/WhisperCpp/WhisperCppBridge.mm",
        "Sources/Models/ggml-large-v3-turbo.bin"
    ]
    
    print("🔍 检查必要文件...")
    all_exist = True
    
    for file_path in files:
        if os.path.exists(file_path):
            size = os.path.getsize(file_path)
            print(f"✅ {file_path} ({size:,} bytes)")
        else:
            print(f"❌ {file_path} - 缺失")
            all_exist = False
    
    return all_exist

def test_model():
    """测试模型文件"""
    model_path = "Sources/Models/ggml-large-v3-turbo.bin"
    if os.path.exists(model_path):
        size = os.path.getsize(model_path)
        size_mb = size / (1024 * 1024)
        print(f"\n📦 模型文件: {size_mb:.1f} MB")
        
        if size_mb > 1000:  # 大于 1GB
            print("✅ 模型文件大小正常")
            return True
        else:
            print("⚠️  模型文件可能不完整")
            return False
    else:
        print("❌ 模型文件不存在")
        return False

def main():
    print("🧪 Whisper.cpp 集成测试")
    print("=" * 50)
    
    # 测试文件
    files_ok = test_files()
    
    # 测试模型
    model_ok = test_model()
    
    print("\n" + "=" * 50)
    if files_ok and model_ok:
        print("🎉 所有测试通过！")
        print("\n📱 下一步：")
        print("1. 打开 WhisperLocal.xcodeproj")
        print("2. 设置开发者签名")
        print("3. 在真机上运行测试")
        return True
    else:
        print("❌ 测试失败，请检查缺失的文件")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
