//
//  Appearance.swift
//  Moodthread
//
//  Created by AC on 1/26/24.
//

import UIKit

struct Appearance {
    // mood icon asset names
    static let MOOD_HIGHEST = "fi-sr-face-awesome"
    static let MOOD_MID_HIGH = "fi-sr-smile-beam"
    static let MOOD_MID = "fi-sr-neutral"
    static let MOOD_MID_LOW = "fi-sr-face-disappointed"
    static let MOOD_LOWEST = "fi-sr-frown"
    
    // energy icon asset names
    static let ENERGY_100 = "fi-sr-battery-full"
    static let ENERGY_75 = "fi-sr-battery-three-quarters"
    static let ENERGY_50 = "fi-sr-battery-half"
    static let ENERGY_25 = "fi-sr-battery-quarter"
    
    // misc icon asset names
    static let MISC = "hexagon.fill"
    
    var tintColor = {
        guard let scene = (UIApplication.shared.connectedScenes.first as? UIWindowScene), let window = scene.windows.first else {
            return Constants.accentColor
        }
        return window.tintColor ?? Constants.accentColor
    }()
    
    static func getIcons(values: (v: Float, min: Float, max: Float)?) -> [UIImage?] {
        guard let values = values else { return [nil, nil, nil] }
        
        var images: [UIImage?] = []
        
        let mood_icons = [MOOD_LOWEST, MOOD_MID_HIGH, MOOD_MID, MOOD_MID_LOW, MOOD_HIGHEST]
        
//        print(Float(mood_icons.count) / (values.max - values.min))
//        print(values.v / Float(mood_icons.count) / (values.max - values.min))
        
//        images.append(UIImage(named: mood_icons[(values.max - values.min) / values.v]))
        
//        let margin =  (values.max - values.min) / Float(mood_icons.count)
        
        
        switch (values.v) {
        case ..<1:
            images.append(UIImage(named: MOOD_LOWEST)?.withRenderingMode(.alwaysTemplate))
        case 1..<2:
            images.append(UIImage(named: MOOD_MID_LOW)?.withRenderingMode(.alwaysTemplate))
        case 2..<3:
            images.append(UIImage(named: MOOD_MID)?.withRenderingMode(.alwaysTemplate))
        case 3..<4:
            images.append(UIImage(named: MOOD_MID_HIGH)?.withRenderingMode(.alwaysTemplate))
        case 4...:
            images.append(UIImage(named: MOOD_HIGHEST)?.withRenderingMode(.alwaysTemplate))
        default:
            images.append(nil)
        }
        
        switch (values.v) {
        case ..<1.25:
            images.append(UIImage(named: ENERGY_25)?.withRenderingMode(.alwaysTemplate))
        case 1.25..<2.5:
            images.append(UIImage(named: ENERGY_50)?.withRenderingMode(.alwaysTemplate))
        case 2.5..<3.75:
            images.append(UIImage(named: ENERGY_75)?.withRenderingMode(.alwaysTemplate))
        case 3.75...:
            images.append(UIImage(named: ENERGY_100)?.withRenderingMode(.alwaysTemplate))
        default:
            images.append(nil)
        }
        
        let percentage = (values.v - values.min) / (values.max - values.min)
        switch (percentage) {
        case 0..<0.25:
            images.append(UIImage(systemName: MISC)?.withRenderingMode(.alwaysTemplate))
        case 0.25..<0.5:
            images.append(UIImage(systemName: MISC)?.withRenderingMode(.alwaysTemplate))
        case 0.5..<0.75:
            images.append(UIImage(systemName: MISC)?.withRenderingMode(.alwaysTemplate))
        case 0.75...1:
            images.append(UIImage(systemName: MISC)?.withRenderingMode(.alwaysTemplate))
        default:
            images.append(nil)
        }
        
        return images
    }
    
    static func getColor(values: (v: Float, min: Float, max: Float)?) -> UIColor {
        guard let values = values else { return .gray }
        
        let range = values.max - values.min
        
        switch (values.v) {
        case values.min..<(values.min + range/3):
            return .red
        case (values.min + range/3)..<(values.min + range * 2/3):
            return .yellow
        case (values.min + range * 2/3)...values.max:
            return .green
        default:
            return .gray
        }
    }
}
