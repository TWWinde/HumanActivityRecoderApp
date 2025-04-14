//
//  PredictionService.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 09.03.25.
//

import CoreML

class PredictionService {
    static let shared = PredictionService()
    
    private let classifier: ActivityClassifier
    
    private init() {
        do {
            classifier = try ActivityClassifier(configuration: MLModelConfiguration())
        } catch {
            fatalError("无法加载模型: \(error)")
        }
    }
    
    func normalizeZScore(windowData: [[Double]]) -> [[Double]] {
        var normalizedData = windowData
        
        let featureCount = windowData.first?.count ?? 0
        
        for featureIndex in 0..<featureCount {
            let featureValues = windowData.map { $0[featureIndex] }
            
            let mean = featureValues.reduce(0, +) / Double(featureValues.count)
            let std = sqrt(featureValues.reduce(0) { $0 + pow($1 - mean, 2) } / Double(featureValues.count))
            
            for timeIndex in 0..<windowData.count {
                let value = windowData[timeIndex][featureIndex]
                if std != 0 {
                    normalizedData[timeIndex][featureIndex] = (value - mean) / std
                } else {
                    normalizedData[timeIndex][featureIndex] = 0
                }
            }
        }
        
        return normalizedData
    }

    func predict(windowData: [[Double]]) -> String? {
        
        let normalizedData = normalizeZScore(windowData: windowData)
        
        guard let mlArray = try? MLMultiArray(shape: [1, 128, 6], dataType: .double) else {
            print("MLMultiArray 初始化失败")
            return nil
        }
        
        // 填充 MLMultiArray
        for (t, frame) in normalizedData.enumerated() {
            for (c, value) in frame.enumerated() {
                let index = [0, NSNumber(value: t), NSNumber(value: c)]
                mlArray[index] = NSNumber(value: value)
            }
        }
        
        do {
            let output = try classifier.prediction(input: mlArray)
            let predictedClass = output.classLabel
            print("预测类别: \(predictedClass)")
            return predictedClass
        } catch {
            print("预测失败: \(error)")
            return nil
        }
    }
}
