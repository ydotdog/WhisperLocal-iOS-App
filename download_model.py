#!/usr/bin/env python3
import requests
import os
import sys
from pathlib import Path

def download_model():
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin"
    output_dir = Path("Sources/Models")
    output_path = output_dir / "ggml-large-v3.bin"
    
    # 创建目录
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("正在下载 Whisper Large V3 模型...")
    print(f"下载地址: {url}")
    print(f"保存位置: {output_path}")
    print("文件大小: ~1.5GB")
    print("-" * 50)
    
    try:
        # 开始下载
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        # 获取文件大小
        total_size = int(response.headers.get('content-length', 0))
        
        # 下载文件
        downloaded = 0
        with open(output_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
                    
                    # 显示进度
                    if total_size > 0:
                        percent = (downloaded / total_size) * 100
                        print(f"\r下载进度: {percent:.1f}% ({downloaded}/{total_size} bytes)", end='', flush=True)
        
        print(f"\n✅ 下载完成: {output_path}")
        
        # 验证文件大小
        file_size = output_path.stat().st_size
        print(f"文件大小: {file_size:,} bytes ({file_size / (1024*1024):.1f} MB)")
        
        if file_size > 1000000000:  # 大于 1GB
            print("✅ 文件大小正常")
        else:
            print("⚠️  文件可能不完整，请检查网络连接")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ 下载失败: {e}")
        return False
    except Exception as e:
        print(f"❌ 发生错误: {e}")
        return False
    
    return True

if __name__ == "__main__":
    success = download_model()
    if success:
        print("\n🎉 模型下载成功！现在可以编译和运行 iOS 应用了。")
    else:
        print("\n💡 如果下载失败，请尝试：")
        print("1. 检查网络连接")
        print("2. 使用 VPN")
        print("3. 手动下载: https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin")
        sys.exit(1)
