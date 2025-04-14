//
//  DataRecorder.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 13.04.25.
//

import Foundation
import CoreMotion

final class DataRecorder: ObservableObject {
    static let shared = DataRecorder()
    private let fileManager = FileManager.default
    private let ioQueue = DispatchQueue(label: "com.recorder.io", qos: .userInitiated)
    
    @Published private(set) var isRecording = false
    @Published private(set) var currentLabel = ""
    @Published private(set) var recordedSessions: [RecordingSession] = []
    
    private var currentSessionData: [SensorData] = []
    
    struct RecordingSession: Identifiable, Codable {
        var id = UUID()
        let label: String
        let data: [SensorData]
        let timestamp: Date
    }
    
    struct SensorData: Codable {
        let timestamp: TimeInterval
        let accX: Double
        let accY: Double
        let accZ: Double
        let gyroX: Double
        let gyroY: Double
        let gyroZ: Double

        init(timestamp: TimeInterval, acceleration: CMAcceleration, rotationRate: CMRotationRate) {
            self.timestamp = timestamp
            self.accX = acceleration.x
            self.accY = acceleration.y
            self.accZ = acceleration.z
            self.gyroX = rotationRate.x
            self.gyroY = rotationRate.y
            self.gyroZ = rotationRate.z
        }
    }
    
    func startRecording(label: String) {
        ioQueue.async {
            self.currentLabel = label
            self.currentSessionData.removeAll()
            DispatchQueue.main.async {
                self.isRecording = true
            }
        }
    }
    
    func record(data: CMDeviceMotion) {
        guard isRecording else { return }
        
        ioQueue.async {
            let sensorData = SensorData(
                timestamp: Date().timeIntervalSince1970,
                acceleration: data.userAcceleration,
                rotationRate: data.rotationRate
            )
            self.currentSessionData.append(sensorData)
        }
    }
    
    func stopRecording() {
        ioQueue.async {
            let session = RecordingSession(
                label: self.currentLabel,
                data: self.currentSessionData,
                timestamp: Date()
            )
            self.recordedSessions.append(session)
            
            DispatchQueue.main.async {
                self.isRecording = false
                self.saveSessionsToDisk()
            }
        }
    }
    // 在 DataRecorder 类中添加：
    func deleteSessions(at indexes: IndexSet) {
        ioQueue.async {
            self.recordedSessions.remove(atOffsets: indexes)
            DispatchQueue.main.async {
                self.saveSessionsToDisk()
            }
        }
    }

    func clearAllSessions() {
        ioQueue.async {
            self.recordedSessions.removeAll()
            DispatchQueue.main.async {
                self.saveSessionsToDisk()
            }
        }
    }
    
    private func saveSessionsToDisk() {
        let fileURL = FileManager.default
            .documentDirectory()
            .appendingPathComponent("recordings.json")
        
        do {
            let data = try JSONEncoder().encode(recordedSessions)
            try data.write(to: fileURL)
        } catch {
            print("保存失败: \(error)")
        }
    }
    
    func exportAllData() -> URL? {
        let fileURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("motion_data_\(Date().ISO8601Format()).json")
        
        do {
            let data = try JSONEncoder().encode(recordedSessions)
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("导出失败: \(error)")
            return nil
        }
    }
}
