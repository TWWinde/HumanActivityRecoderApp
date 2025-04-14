//
//  PredictionDisplay.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 13.04.25.
//

import SwiftUI

struct PredictionDisplay: View {
    let prediction: String
    private var color: Color {
        switch prediction {
        case "走": return .green
        case "跑": return .red
        case "坐": return .blue
        default: return .gray
        }
    }
    
    var body: some View {
        VStack {
            Text("当前状态")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(prediction)
                .font(.system(size: 28, weight: .bold))
                .padding()
                .frame(maxWidth: .infinity)
                .background(color.opacity(0.2))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color, lineWidth: 2)
                )
        }
    }
}
