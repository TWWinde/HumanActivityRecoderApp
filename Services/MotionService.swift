//
//  MotionService.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 09.03.25.
//

import CoreMotion

final class MotionService: ObservableObject {
    static let shared = MotionService()
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    @Published var latestMotionData: CMDeviceMotion?
    
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("设备不支持运动传感器")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 0.02 // 10Hz采样率
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, error in
            guard let motion = motion, error == nil else {
                print("传感器数据错误: \(error?.localizedDescription ?? "未知错误")")
                return
            }
            
            // 主线程更新UI相关数据
            DispatchQueue.main.async {
                self?.latestMotionData = motion
            }
            
            // 后台线程处理录制
            if DataRecorder.shared.isRecording {
                DataRecorder.shared.record(data: motion)
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        print("传感器已停止")
    }
    
    deinit {
        stopUpdates()
    }
}
