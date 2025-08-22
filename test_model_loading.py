#!/usr/bin/env python3
"""
测试 Whisper 模型加载性能的脚本
"""

import time
import os
import sys

def test_model_loading():
    """测试模型加载性能"""
    
    # 检查模型文件
    model_path = "./DerivedData/Build/Products/Debug-iphonesimulator/WhisperLocal.app/ggml-large-v3-turbo.bin"
    
    if not os.path.exists(model_path):
        print("❌ 模型文件不存在:", model_path)
        return
    
    # 获取文件大小
    file_size = os.path.getsize(model_path)
    file_size_mb = file_size / (1024 * 1024)
    
    print(f"📊 模型文件信息:")
    print(f"   - 路径: {model_path}")
    print(f"   - 大小: {file_size_mb:.1f} MB ({file_size:,} 字节)")
    
    # 模拟文件读取时间（仅读取，不解析）
    print(f"\n⏱️  测试文件读取性能...")
    
    start_time = time.time()
    
    # 读取文件的前 1MB 来测试 I/O 性能
    with open(model_path, 'rb') as f:
        data = f.read(1024 * 1024)  # 读取 1MB
    
    read_time = time.time() - start_time
    
    print(f"   - 读取 1MB 耗时: {read_time:.3f} 秒")
    print(f"   - 预估读取速度: {1.0/read_time:.1f} MB/s")
    
    # 预估完整模型加载时间
    estimated_load_time = (file_size_mb / (1.0/read_time)) * 2  # 乘以2因为还要解析
    
    print(f"\n📈 预估模型加载时间:")
    print(f"   - 仅读取: {file_size_mb / (1.0/read_time):.1f} 秒")
    print(f"   - 完整加载（包含解析）: {estimated_load_time:.1f} 秒")
    
    # 设备性能参考
    print(f"\n📱 不同设备的预期加载时间:")
    print(f"   - iPhone 15 Pro/Pro Max: 10-20 秒")
    print(f"   - iPhone 14/13: 20-30 秒")
    print(f"   - iPhone 12/11: 30-45 秒")
    print(f"   - 模拟器: 5-15 秒")
    
    print(f"\n💡 如果加载时间超过预期，可能的原因:")
    print(f"   1. 设备内存不足")
    print(f"   2. 模型文件损坏")
    print(f"   3. 应用权限问题")
    print(f"   4. 系统资源紧张")

if __name__ == "__main__":
    test_model_loading()
