//
//  ActivityPredictor.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 13.04.25.
//

import CoreML

final class ActivityPredictor: ObservableObject {
    static let shared = ActivityPredictor()
    private let model: ActivityClassifier
    private var buffer: [[Double]] = []
    private let predictionQueue = DispatchQueue(label: "prediction.queue")
    
    @Published var currentPrediction = "等待检测..."
    private let labels = ["走", "跑", "坐", "上下楼梯"]
    
    init() {
        guard let model = try? ActivityClassifier(configuration: MLModelConfiguration()) else {
            fatalError("无法加载CoreML模型")
        }
        self.model = model
    }
    
    func process(data: [Double]) {
        predictionQueue.async { [weak self] in
            self?.buffer.append(data)
            guard let buffer = self?.buffer, buffer.count >= 20 else { return }
            
            let window = Array(buffer.suffix(20))
            guard let mlArray = try? MLMultiArray(shape: [1,20,6], dataType: .double) else { return }
            
            for (t, frame) in window.enumerated() {
                for (c, value) in frame.enumerated() {
                    mlArray[[0, t, c] as [NSNumber]] = NSNumber(value: value)
                }
            }
            
            let input = ActivityClassifierInput(input: mlArray)
            guard let result = try? self?.model.prediction(input: input) else { return }
            
            DispatchQueue.main.async {
                self?.currentPrediction = self?.labels.first { $0 == result.classLabel } ?? "未知"
                if buffer.count > 30 { self?.buffer.removeFirst(10) } // 滑动窗口
            }
        }
    }
}
