import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranscribeViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 状态指示器
                HStack {
                    if !viewModel.modelLoaded {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("正在加载模型...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("模型已加载")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // 转写内容区域
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        if viewModel.isProcessing {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("正在转写...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        
                        Text(viewModel.transcript.isEmpty ? "转写内容将显示在这里" : viewModel.transcript)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                }
                
                // 录音按钮
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.toggleRecording()
                    }) {
                        HStack {
                            Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.title2)
                            Text(viewModel.isRecording ? "停止录音" : "开始录音")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.modelLoaded || viewModel.isProcessing)
                }
            }
            .padding()
            .navigationTitle("Whisper Local")
        }
    }
}

#Preview {
    ContentView()
}


