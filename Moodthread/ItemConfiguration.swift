//
//  Item.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import Foundation

class ItemConfiguration : NSObject, NSSecureCoding {
    public class var supportsSecureCoding: Bool { return true }
    
    static let genericTypes: [Type] = [.binary, .txt]
    static let numberTypes: [Type] = [.slider, .number]
    static let selectTypes: [Type] = [.select, .multiSelect]
    
    var label: String = "N/A"
    var type: Type = .binary
    
    init(label: String, type: Type) {
        self.label = label
        self.type = type
    }
    
    init?(stringified: [String]) {
        if stringified.count < 2 { return }
        self.label = stringified[0]
        self.type = Type(rawValue: stringified[1]) ?? .slider
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
    
    func stringify() -> [String] {
        var stringified = [String]()
        stringified.append(label)
        stringified.append(type.rawValue)
        return stringified
    }
    
    static func unstringify(string: [String]) -> ItemConfiguration? {
        if string.count < 2 { return nil }
        
        let type = Type(rawValue: string[1]) ?? .slider
        
        switch(type) {
        case _ where genericTypes.contains(type):
            return ItemConfiguration(label: string[0], type: type)
        case _ where numberTypes.contains(type):
            if(string.count < 4) { return nil }
            return NumberConfiguration(label: string[0], type: type, min: Float(string[2]) ?? 0, max: Float(string[3]) ?? 5)
        case _ where selectTypes.contains(type):
            return nil
        default:
            return nil
        }
//        return ItemConfiguratio
    }
}

class NumberConfiguration : ItemConfiguration {
    override public class var supportsSecureCoding: Bool { return true }
    
    var minValue: Float = 0
    var maxValue: Float = 5
    
    init(label: String, type: Type, min: Float, max: Float) {
        self.minValue = min
        self.maxValue = max
        super.init(label: label, type: type)
    }
    
    override init?(stringified: [String]) {
        super.init(stringified: stringified)
        if stringified.count < 4 { return }
        self.minValue = Float(stringified[2]) ?? minValue
        self.maxValue = Float(stringified[3]) ?? maxValue
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
    
    override func stringify() -> [String] {
        var stringified = super.stringify()
        stringified.append(String(minValue))
        stringified.append(String(maxValue))
        return stringified
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
