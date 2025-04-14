//
//  FileManager+Extension.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 13.04.25.
//

import Foundation

extension FileManager {
    func documentDirectory() -> URL {
        urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func loadRecordings() -> [DataRecorder.RecordingSession] {
        let fileURL = documentDirectory().appendingPathComponent("recordings.json")
        
        guard fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        
        return (try? JSONDecoder().decode([DataRecorder.RecordingSession].self, from: data)) ?? []
    }
}
