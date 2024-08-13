//
//  Type.swift
//  Moodthread
//
//  Created by AC on 1/28/24.
//

import Foundation

enum Type: String, CaseIterable {
    // do NOT change raw type strings, used for encoding/decoding configurations
    case slider = "Slider"
    case number = "Number"
    case binary = "Binary"
    case select = "Selection"
    case multiSelect = "Multi-Selection"
    case txt = "Text"
    case submit = "Submit"
}
