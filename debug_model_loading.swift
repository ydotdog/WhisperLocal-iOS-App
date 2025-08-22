import Foundation

// 模拟 WhisperEngine 的模型加载过程
class ModelLoadingDebugger {
    
    static func debugModelLoading() {
        print("🔍 开始诊断模型加载问题...")
        print("==================================")
        
        // 1. 检查 Bundle 路径
        let bundlePath = Bundle.main.bundlePath
        print("📁 Bundle 路径: \(bundlePath)")
        
        // 2. 尝试找到模型文件
        let modelName = "ggml-large-v3-turbo"
        let modelType = "bin"
        
        print("\n🔍 查找模型文件...")
        print("   模型名称: \(modelName)")
        print("   文件类型: \(modelType)")
        
        // 方法1: 直接查找
        if let modelPath = Bundle.main.path(forResource: modelName, ofType: modelType) {
            print("✅ 找到模型文件: \(modelPath)")
            checkModelFile(path: modelPath)
        } else {
            print("❌ 未找到模型文件")
        }
        
        // 方法2: 列出所有 .bin 文件
        print("\n📋 列出应用包中的所有 .bin 文件:")
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(atPath: bundlePath)
            let binFiles = files.filter { $0.hasSuffix(".bin") }
            
            if binFiles.isEmpty {
                print("   ❌ 没有找到任何 .bin 文件")
            } else {
                for file in binFiles {
                    let filePath = "\(bundlePath)/\(file)"
                    print("   📄 \(file)")
                    checkModelFile(path: filePath)
                }
            }
        } catch {
            print("   ❌ 读取应用包失败: \(error)")
        }
        
        // 3. 检查内存使用情况
        print("\n💾 内存使用情况:")
        let memoryInfo = ProcessInfo.processInfo
        print("   物理内存: \(memoryInfo.physicalMemory / 1024 / 1024) MB")
        print("   系统内存压力: \(memoryInfo.systemUptime)")
        
        // 4. 模拟模型加载过程
        print("\n⏱️  模拟模型加载过程...")
        simulateModelLoading()
    }
    
    private static func checkModelFile(path: String) {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: path) else {
            print("      ❌ 文件不存在")
            return
        }
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            let fileSizeMB = Double(fileSize) / (1024 * 1024)
            
            print("      ✅ 文件存在")
            print("      📏 文件大小: \(fileSizeMB) MB (\(fileSize) 字节)")
            
            // 检查文件是否可读
            let fileHandle = try FileHandle(forReadingFrom: URL(fileURLWithPath: path))
            let firstBytes = try fileHandle.read(upToCount: 16)
            fileHandle.closeFile()
            
            if let firstBytes = firstBytes {
                let hexString = firstBytes.map { String(format: "%02x", $0) }.joined()
                print("      🔍 文件头: \(hexString)")
                
                // 检查是否是有效的 GGML 文件
                if firstBytes.count >= 4 {
                    let magic = firstBytes.prefix(4)
                    if magic == Data([0x67, 0x67, 0x6d, 0x6c]) { // "ggml"
                        print("      ✅ 有效的 GGML 文件")
                    } else {
                        print("      ⚠️  可能不是有效的 GGML 文件")
                    }
                }
            }
            
        } catch {
            print("      ❌ 读取文件失败: \(error)")
        }
    }
    
    private static func simulateModelLoading() {
        print("   🚀 开始模拟加载...")
        
        // 模拟文件读取时间
        let startTime = Date()
        
        // 模拟加载过程
        for i in 1...10 {
            Thread.sleep(forTimeInterval: 0.1) // 模拟工作
            let elapsed = Date().timeIntervalSince(startTime)
            print("   📊 进度 \(i * 10)% - 耗时: \(elapsed) 秒")
        }
        
        let totalTime = Date().timeIntervalSince(startTime)
        print("   ✅ 模拟加载完成 - 总耗时: \(totalTime) 秒")
        
        // 预估真实加载时间
        let estimatedRealTime = totalTime * 50 // 真实模型比模拟复杂得多
        print("   📈 预估真实加载时间: \(estimatedRealTime) 秒")
    }
}

// 如果直接运行此脚本
if CommandLine.arguments.contains("--debug") {
    ModelLoadingDebugger.debugModelLoading()
}
