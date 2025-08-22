import AVFoundation
import Foundation

public final class AudioRecorder: NSObject {
    public enum RecorderError: Error {
        case permissionDenied
        case engineUnavailable
        case formatError
        case converterError
        case sessionError(Error)
    }

    public struct Config {
        public var sampleRate: Double = 16_000
        public var channelCount: AVAudioChannelCount = 1
        public var bufferDuration: TimeInterval = 0.05
        public var enableAGC: Bool = false
        public init() {}
    }

    public typealias PCMHandler = (_ buffer: AVAudioPCMBuffer, _ format: AVAudioFormat) -> Void

    private let audioEngine = AVAudioEngine()
    private let session = AVAudioSession.sharedInstance()
    private let config: Config
    private var converter: AVAudioConverter?
    private var outputFormat: AVAudioFormat
    private var isConfigured = false

    private let processingQueue = DispatchQueue(label: "audio.recorder.processing")

    public var onPCM: PCMHandler?

    public init(config: Config = Config()) {
        self.config = config
        self.outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: config.sampleRate,
            channels: config.channelCount,
            interleaved: false
        )!
        super.init()
    }

    public func requestPermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    public func start() throws {
        guard AVAudioSession.sharedInstance().recordPermission == .granted else {
            throw RecorderError.permissionDenied
        }

        try configureSession()
        try configureEngineIfNeeded()

        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                throw RecorderError.engineUnavailable
            }
        }
    }

    public func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        try? session.setActive(false, options: [.notifyOthersOnDeactivation])
    }

    private func configureSession() throws {
        do {
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setPreferredSampleRate(config.sampleRate)
            try session.setPreferredIOBufferDuration(config.bufferDuration)
            try session.setActive(true)
        } catch {
            throw RecorderError.sessionError(error)
        }
    }

    private func configureEngineIfNeeded() throws {
        guard !isConfigured else { return }

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)

        guard let converter = AVAudioConverter(from: inputFormat, to: outputFormat) else {
            throw RecorderError.converterError
        }
        self.converter = converter

        let bufferSize: AVAudioFrameCount = 2048
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { [weak self] buffer, when in
            guard let self else { return }
            self.processingQueue.async {
                self.processBuffer(buffer: buffer, inputFormat: inputFormat)
            }
        }

        audioEngine.prepare()
        isConfigured = true
    }

    private func processBuffer(buffer: AVAudioPCMBuffer, inputFormat: AVAudioFormat) {
        guard let converter else { return }

        let frameCapacity = AVAudioFrameCount(Double(buffer.frameLength) * (outputFormat.sampleRate / inputFormat.sampleRate))
        guard let outBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: frameCapacity) else { return }

        var error: NSError?
        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }

        converter.convert(to: outBuffer, error: &error, withInputFrom: inputBlock)

        if let error { print("Audio convert error: \(error)") }
        guard outBuffer.frameLength > 0 else { return }

        onPCM?(outBuffer, outputFormat)
    }
}


