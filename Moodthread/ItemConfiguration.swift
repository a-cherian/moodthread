//
//  Item.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import Foundation

enum Type: String {
    case slider = "slider"
    case binary = "binary"
    case select = "select"
    case multiSelect = "multiSelect"
    case number = "number"
    case txt = "txt"
    case submit = "submit"
}

class ItemConfiguration : NSObject, NSSecureCoding {
    public class var supportsSecureCoding: Bool { return true }
    
    var label: String = "N/A"
    var type: Type = .binary
    
    init(label: String, type: Type) {
        self.label = label
        self.type = type
    }
    
    public required init?(coder: NSCoder) {
        if let label = coder.decodeObject(forKey: "label") as? String {
            self.label = label
        }
        if let type = coder.decodeObject(forKey: "type") as? String {
            self.type = Type(rawValue: type) ?? .binary
        }
    }

    public func encode(with coder: NSCoder) {
        coder.encode(label, forKey: "label")
        coder.encode(type.rawValue, forKey: "type")
    }
}

class NumberConfiguration : ItemConfiguration {
    override public class var supportsSecureCoding: Bool { return true }
    
    var minValue: Float = 1
    var maxValue: Float = 5
    
    init(label: String, type: Type, min: Float, max: Float) {
        self.minValue = min
        self.maxValue = max
        super.init(label: label, type: type)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.minValue = coder.decodeFloat(forKey: "minValue")
        self.maxValue = coder.decodeFloat(forKey: "maxValue")
    }
    
    override public func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(minValue, forKey: "minValue")
        coder.encode(maxValue, forKey: "maxValue")
    }
}

class SelectConfiguration : ItemConfiguration {
    override public class var supportsSecureCoding: Bool { return true }
    
    var options: [String] = []
    
    init(label: String, type: Type, options: [String]) {
        self.options = options
        super.init(label: label, type: type)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        if let options = coder.decodeObject(forKey: "options") as? [String] {
            self.options = options
        }
    }
    
    override public func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(options, forKey: "options")
    }
}
