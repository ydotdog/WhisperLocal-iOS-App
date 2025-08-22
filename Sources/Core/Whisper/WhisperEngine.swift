import Foundation
import AVFoundation

// 导入 C 函数
@_silgen_name("whisper_init_from_file_bridge")
func whisper_init_from_file_bridge(_ path: UnsafePointer<Int8>) -> OpaquePointer?

@_silgen_name("whisper_free_bridge")
func whisper_free_bridge(_ ctx: OpaquePointer?)

@_silgen_name("whisper_full_bridge")
func whisper_full_bridge(_ ctx: OpaquePointer?, _ samples: UnsafePointer<Float>, _ n_samples: Int32, _ language: UnsafePointer<Int8>, _ n_threads: Int32) -> Int32

@_silgen_name("whisper_get_text_bridge")
func whisper_get_text_bridge(_ ctx: OpaquePointer?, _ segment_index: Int32) -> UnsafePointer<Int8>?

@_silgen_name("whisper_full_n_segments_bridge")
func whisper_full_n_segments_bridge(_ ctx: OpaquePointer?) -> Int32

@_silgen_name("whisper_full_get_segment_t0_bridge")
func whisper_full_get_segment_t0_bridge(_ ctx: OpaquePointer?, _ segment_index: Int32) -> Int64

@_silgen_name("whisper_full_get_segment_t1_bridge")
func whisper_full_get_segment_t1_bridge(_ ctx: OpaquePointer?, _ segment_index: Int32) -> Int64

public class WhisperEngine {
    private var whisperContext: OpaquePointer?
    private let modelPath: String
    private let language: String
    private let threadCount: Int
    
    public struct TranscriptionResult {
        public let text: String
        public let startTime: TimeInterval
        public let endTime: TimeInterval
        public let confidence: Float
        
        public init(text: String, startTime: TimeInterval, endTime: TimeInterval, confidence: Float) {
            self.text = text
            self.startTime = startTime
            self.endTime = endTime
            self.confidence = confidence
        }
    }
    
    public init(modelPath: String, language: String = "zh", threadCount: Int = 4) {
        self.modelPath = modelPath
        self.language = language
        self.threadCount = threadCount
    }
    
    public func loadModel() -> Bool {
        print("🔍 Attempting to load Whisper model from: \(modelPath)")
        
        // 检查文件是否存在
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: modelPath) else {
            print("❌ Model file does not exist at path: \(modelPath)")
            return false
        }
        
        // 检查文件大小和完整性
        do {
            let attributes = try fileManager.attributesOfItem(atPath: modelPath)
            let fileSize = attributes[.size] as? Int64 ?? 0
            print("📁 Model file size: \(fileSize) bytes (\(fileSize / 1024 / 1024) MB)")
            
            if fileSize < 1000000 { // 小于 1MB 肯定不对
                print("❌ Model file is too small, probably corrupted")
                return false
            }
            
            // 检查文件头是否为有效的 GGML 文件
            let fileHandle = try FileHandle(forReadingFrom: URL(fileURLWithPath: modelPath))
            let headerData = try fileHandle.read(upToCount: 16)
            fileHandle.closeFile()
            
            if let headerData = headerData, headerData.count >= 4 {
                let magic = headerData.prefix(4)
                let magicString = String(data: magic, encoding: .ascii) ?? ""
                print("📄 File header magic: \(magicString)")
                
                if !magicString.hasPrefix("ggml") && !magicString.hasPrefix("GGML") {
                    print("⚠️  Warning: File may not be a valid GGML model")
                    // 继续尝试，但要小心
                }
            }
        } catch {
            print("❌ Cannot read file attributes or header: \(error)")
            return false
        }
        
        // 添加内存压力检查
        let memoryInfo = ProcessInfo.processInfo
        let availableMemory = memoryInfo.physicalMemory / 1024 / 1024 // MB
        print("💾 Available memory: \(availableMemory) MB")
        
        if availableMemory < 2048 { // 小于 2GB 可用内存
            print("⚠️  Warning: Low memory available (\(availableMemory) MB)")
        }
        
        // 尝试释放一些内存
        print("🧹 Attempting to free memory...")
        autoreleasepool {
            // 强制垃圾回收
            print("   - Running garbage collection...")
        }
        
        print("🚀 Initializing Whisper context...")
        
        // 在主线程上同步初始化，避免多线程问题
        var context: OpaquePointer?
        var attempts = 0
        let maxAttempts = 3
        
        while attempts < maxAttempts && context == nil {
            attempts += 1
            print("   - Attempt \(attempts)/\(maxAttempts)")
            
            // 在每次尝试前等待一下，让系统稳定
            Thread.sleep(forTimeInterval: Double(attempts)) // 递增等待时间
            
            // 强制垃圾回收
            autoreleasepool {
                // 在主线程上同步初始化，避免多线程竞争
                context = whisper_init_from_file_bridge(self.modelPath)
            }
            
            if context != nil {
                print("   - Attempt \(attempts) successful!")
                break
            } else {
                print("   - Attempt \(attempts) failed")
                // 强制释放内存
                if let ctx = context {
                    whisper_free_bridge(ctx)
                    context = nil
                }
                // 等待更长时间再重试
                Thread.sleep(forTimeInterval: 2.0)
            }
        }
        
        guard let context = context else {
            print("❌ All \(maxAttempts) attempts failed to initialize Whisper context")
            return false
        }
        
        whisperContext = context
        print("✅ Whisper model loaded successfully after \(attempts) attempts!")
        return true
    }
    
    public func transcribe(audioBuffer: AVAudioPCMBuffer) -> [TranscriptionResult] {
        guard let context = whisperContext else {
            print("Whisper model not loaded")
            return []
        }
        
        guard let floatChannelData = audioBuffer.floatChannelData?[0] else {
            print("Invalid audio buffer format")
            return []
        }
        
        let sampleCount = Int(audioBuffer.frameLength)
        let samples = Array(UnsafeBufferPointer(start: floatChannelData, count: sampleCount))
        
        let result = whisper_full_bridge(context, samples, Int32(sampleCount), language, Int32(threadCount))
        
        guard result == 0 else {
            print("Whisper transcription failed with error: \(result)")
            return []
        }
        
        var results: [TranscriptionResult] = []
        let segmentCount = whisper_full_n_segments_bridge(context)
        
        for i in 0..<segmentCount {
            let textPtr = whisper_get_text_bridge(context, Int32(i))
            let text = textPtr != nil ? String(cString: textPtr!) : ""
            let startTime = TimeInterval(whisper_full_get_segment_t0_bridge(context, Int32(i))) / 100.0
            let endTime = TimeInterval(whisper_full_get_segment_t1_bridge(context, Int32(i))) / 100.0
            
            let result = TranscriptionResult(
                text: text,
                startTime: startTime,
                endTime: endTime,
                confidence: 1.0 // Whisper doesn't provide confidence scores
            )
            results.append(result)
        }
        
        return results
    }
    
    public func transcribe(audioData: [Float]) -> [TranscriptionResult] {
        guard let context = whisperContext else {
            print("Whisper model not loaded")
            return []
        }
        
        let result = whisper_full_bridge(context, audioData, Int32(audioData.count), language, Int32(threadCount))
        
        guard result == 0 else {
            print("Whisper transcription failed with error: \(result)")
            return []
        }
        
        var results: [TranscriptionResult] = []
        let segmentCount = whisper_full_n_segments_bridge(context)
        
        for i in 0..<segmentCount {
            let textPtr = whisper_get_text_bridge(context, Int32(i))
            let text = textPtr != nil ? String(cString: textPtr!) : ""
            let startTime = TimeInterval(whisper_full_get_segment_t0_bridge(context, Int32(i))) / 100.0
            let endTime = TimeInterval(whisper_full_get_segment_t1_bridge(context, Int32(i))) / 100.0
            
            let result = TranscriptionResult(
                text: text,
                startTime: startTime,
                endTime: endTime,
                confidence: 1.0
            )
            results.append(result)
        }
        
        return results
    }
    
    deinit {
        cleanup()
    }
    
    private func cleanup() {
        if let context = whisperContext {
            whisper_free_bridge(context)
            whisperContext = nil
        }
    }
    
    public func unloadModel() {
        cleanup()
        print("🧹 Whisper model unloaded and memory freed")
    }
}
