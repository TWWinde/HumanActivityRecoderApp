//
//  HumanActivityRecognitionApp.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 08.03.25.
//

import SwiftUI

@main
struct BehaviorMonitorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MotionService.shared)
                .environmentObject(ActivityPredictor.shared)
                .environmentObject(DataRecorder.shared)
        }
    }
}
