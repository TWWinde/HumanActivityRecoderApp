//
//  Constants.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 13.04.25.
//

import CoreGraphics

enum Constants {
    static let sampleRate = 10 // Hz
    static let predictionWindowSize = 20 // 样本数
    static let accRange: ClosedRange<CGFloat> = -2.0...2.0 // g
    static let gyroRange: ClosedRange<CGFloat> = -3.0...3.0 // rad/s
}
