//
//  MLMultiArray+Extension.swift
//  HumanActivityRecognition
//
//  Created by Tang Wenwu on 09.03.25.
//

import CoreML

extension MLMultiArray {
    static func from(_ array: [[Double]], shape: [NSNumber]) throws -> MLMultiArray {
        let mlArray = try MLMultiArray(shape: shape, dataType: .double)
        
        for (t, frame) in array.enumerated() {
            for (c, value) in frame.enumerated() {
                let index = [0, t, c] as [NSNumber]
                mlArray[index] = NSNumber(value: value)
            }
        }
        return mlArray
    }
}
