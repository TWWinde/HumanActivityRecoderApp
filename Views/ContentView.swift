//
//  ContentView.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 08.03.25.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    @EnvironmentObject var motion: MotionService
    @EnvironmentObject var recorder: DataRecorder
    @State private var showExportSheet = false
    @State private var exportFile: URL?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 1. 传感器数据可视化
                SensorGraph(motionData: motion.latestMotionData)
                    .frame(height: 200)
                    .padding(.horizontal)
                
                // 2. 实时数据显示面板
                MotionDataView(motion: motion.latestMotionData)
                    .padding(.horizontal)
                
                // 3. 录制控制面板
                RecordingControl()
                
                // 4. 历史记录列表
                SessionListView()
                
                Spacer()
            }
            .navigationTitle("Activity Recording")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: exportAllData) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(recorder.recordedSessions.isEmpty)
                }
            }
            .sheet(isPresented: $showExportSheet) {
                if let file = exportFile {
                    ActivityViewController(activityItems: [file])
                }
            }
        }
        .onAppear {
            motion.startUpdates()
        }
        .onDisappear {
            motion.stopUpdates()
        }
    }
    
    private func exportAllData() {
        exportFile = recorder.exportAllData()
        showExportSheet = exportFile != nil
    }
}

// MARK: - 子视图组件
struct MotionDataView: View {
    let motion: CMDeviceMotion?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Real-Time Sensor Data").font(.headline)
            
            HStack {
                DataColumn(title: "Acc",
                           values: [
                            ("X", motion?.userAcceleration.x),
                            ("Y", motion?.userAcceleration.y),
                            ("Z", motion?.userAcceleration.z)
                           ])
                
                DataColumn(title: "Gyro",
                           values: [
                            ("X", motion?.rotationRate.x),
                            ("Y", motion?.rotationRate.y),
                            ("Z", motion?.rotationRate.z)
                           ])
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct DataColumn: View {
    let title: String
    let values: [(label: String, value: Double?)]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.subheadline)
            ForEach(values, id: \.label) { item in
                HStack {
                    Text(item.label)
                    Text(String(format: "%.2f", item.value ?? 0))
                        .monospacedDigit()
                }
                .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SessionListView: View {
    @EnvironmentObject var recorder: DataRecorder
    
    var body: some View {
        List {
            Section("Recording History") {
                ForEach(recorder.recordedSessions) { session in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(session.label)
                                .font(.headline)
                            Spacer()
                            Text(session.timestamp, style: .time)
                        }
                        Text("\(session.data.count) data points")
                            .font(.caption)
                    }
                }
                .onDelete { indexes in
                    recorder.deleteSessions(at: indexes)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                               context: Context) {}
}
