//
//  RecordingControl.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 13.04.25.
//

import SwiftUI

struct RecordingControl: View {
    @EnvironmentObject var recorder: DataRecorder
    @State private var showActionSheet = false
    
    let actions = ["Walk", "Run", "Sit", "Lay", "Jump"]
    
    var body: some View {
        VStack(spacing: 20) {
            // 录制/停止按钮
            Button(action: mainButtonAction) {
                HStack {
                    Image(systemName: recorder.isRecording ? "stop.fill" : "record.circle")
                    Text(recorder.isRecording ? "Stop Recording" : "Start Recording")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(recorder.isRecording ? Color.red : Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            
            // 导出按钮
            if !recorder.recordedSessions.isEmpty {
                Button(action: exportData) {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Chose an activity"),
                buttons: actions.map { action in
                    .default(Text(action)) {
                        recorder.startRecording(label: action)
                    }
                } + [.cancel()]
            )
        }
    }
    
    private func mainButtonAction() {
        if recorder.isRecording {
            recorder.stopRecording()
        } else {
            showActionSheet = true
        }
    }
    
    private func exportData() {
        guard let url = recorder.exportAllData() else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
    }
}
