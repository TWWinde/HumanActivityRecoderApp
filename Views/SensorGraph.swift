//
//  SensorGraph.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 13.04.25.
//

import SwiftUI
import CoreMotion

struct SensorGraph: View {
    let motionData: CMDeviceMotion?
    private let labels = ["AX", "AY", "AZ", "GX", "GY", "GZ"]
    private let colors: [Color] = [.red, .green, .blue, .orange, .purple, .pink]
    
    // 数据标准化范围
    private let accRange: ClosedRange<CGFloat> = -2.0...2.0  // 加速度范围 (±2g)
    private let gyroRange: ClosedRange<CGFloat> = -3.0...3.0 // 陀螺仪范围 (±3 rad/s)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Real-Time Sensor Data")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { index in
                        SensorBar(
                            label: labels[index],
                            value: normalizedValue(for: index),
                            color: colors[index],
                            rawValue: actualValue(for: index)
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - 数据处理方法
    private func normalizedValue(for index: Int) -> CGFloat {
        guard let motion = motionData else { return 0 }
        
        let value: Double
        if index < 3 {
            // 加速度数据 (0-2对应AX/AY/AZ)
            value = [motion.userAcceleration.x, motion.userAcceleration.y, motion.userAcceleration.z][index]
            return normalize(value, range: accRange)
        } else {
            // 陀螺仪数据 (3-5对应GX/GY/GZ)
            value = [motion.rotationRate.x, motion.rotationRate.y, motion.rotationRate.z][index - 3]
            return normalize(value, range: gyroRange)
        }
    }
    
    private func actualValue(for index: Int) -> Double {
        guard let motion = motionData else { return 0 }
        return index < 3 ?
            [motion.userAcceleration.x, motion.userAcceleration.y, motion.userAcceleration.z][index] :
            [motion.rotationRate.x, motion.rotationRate.y, motion.rotationRate.z][index - 3]
    }
    
    private func normalize(_ value: Double, range: ClosedRange<CGFloat>) -> CGFloat {
        let clampedValue = CGFloat(value).clamped(to: range)
        return (clampedValue - range.lowerBound) / (range.upperBound - range.lowerBound) * 100
    }
}

// MARK: - 子组件
struct SensorBar: View {
    let label: String
    let value: CGFloat  // 标准化后的值 (0-100)
    let color: Color
    let rawValue: Double
    
    var body: some View {
        VStack(spacing: 4) {
            // 数值标签
            Text("\(rawValue, specifier: "%.2f")")
                .font(.system(size: 11, design: .monospaced))
                .frame(width: 40)
            
            // 柱状图
            ZStack(alignment: .bottom) {
                // 背景轨道
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 20, height: 100)
                
                // 数据柱 (带动画)
                Capsule()
                    .fill(color)
                    .frame(width: 20, height: abs(value))
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: value)
            }
            
            // 轴标签
            Text(label)
                .font(.system(size: 12, weight: .bold))
        }
    }
}

// MARK: - 扩展方法
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
