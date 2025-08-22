import AVFoundation
import Combine
import Foundation
import SwiftUI

final class TranscribeViewModel: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var transcript: String = ""
    @Published var isProcessing: Bool = false
    @Published var modelLoaded: Bool = false
    
    private let recorder = AudioRecorder()
    private var whisperEngine: WhisperEngine?
    private var audioBuffer: [Float] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAudioRecorder()
        setupWhisperEngine()
    }
    
    private func setupAudioRecorder() {
        recorder.onPCM = { [weak self] buffer, format in
            guard let self = self else { return }
            
            // 将音频数据添加到缓冲区
            if let floatChannelData = buffer.floatChannelData?[0] {
                let samples = Array(UnsafeBufferPointer(start: floatChannelData, count: Int(buffer.frameLength)))
                self.audioBuffer.append(contentsOf: samples)
            }
        }
    }
    
    private func setupWhisperEngine() {
        print("🔍 Setting up Whisper engine...")
        
        // 获取模型路径 - 使用 Large V3 Turbo 模型
        guard let modelPath = Bundle.main.path(forResource: "ggml-large-v3-turbo", ofType: "bin") else {
            print("❌ Whisper Large V3 Turbo model not found in bundle")
            print("📁 Bundle path: \(Bundle.main.bundlePath)")
            
            // 尝试列出应用包中的所有 .bin 文件
            let fileManager = FileManager.default
            do {
                let files = try fileManager.contentsOfDirectory(atPath: Bundle.main.bundlePath)
                let binFiles = files.filter { $0.hasSuffix(".bin") }
                print("📋 .bin files in app bundle: \(binFiles)")
            } catch {
                print("❌ Error reading app bundle: \(error)")
            }
            
            DispatchQueue.main.async {
                self.modelLoaded = false
            }
            return
        }
        
        print("✅ Found model at path: \(modelPath)")
        
        whisperEngine = WhisperEngine(modelPath: modelPath, language: "zh", threadCount: 4)
        
        // 在后台线程加载模型
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            print("🚀 Loading Whisper model...")
            let loaded = self.whisperEngine?.loadModel() ?? false
            
            DispatchQueue.main.async {
                self.modelLoaded = loaded
                if loaded {
                    print("✅ Whisper Large V3 Turbo model loaded successfully")
                } else {
                    print("❌ Failed to load Whisper Large V3 Turbo model")
                }
            }
        }
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        // 清空之前的音频缓冲区
        audioBuffer.removeAll()
        transcript = ""
        
        recorder.requestPermission { [weak self] granted in
            guard let self = self else { return }
            guard granted else { return }
            do {
                try self.recorder.start()
                DispatchQueue.main.async { self.isRecording = true }
            } catch {
                print("Start recording failed: \(error)")
            }
        }
    }
    
    private func stopRecording() {
        recorder.stop()
        isRecording = false
        
        // 处理录制的音频
        processAudioBuffer()
    }
    
    private func processAudioBuffer() {
        guard !audioBuffer.isEmpty, let engine = whisperEngine, modelLoaded else {
            print("Cannot process audio: buffer empty or model not loaded")
            return
        }
        
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let results = engine.transcribe(audioData: self.audioBuffer)
            
            DispatchQueue.main.async {
                self.isProcessing = false
                
                // 合并所有转写结果
                let fullText = results.map { $0.text }.joined(separator: " ")
                if !fullText.isEmpty {
                    self.transcript = fullText
                } else {
                    self.transcript = "未能识别到语音内容"
                }
                
                // 清空音频缓冲区
                self.audioBuffer.removeAll()
            }
        }
    }
}


