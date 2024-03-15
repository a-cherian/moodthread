//
//  Field.swift
//  Moodthread
//
//  Created by AC on 11/1/23.
//

import ObjectiveC
import Foundation

public class Field: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
    var config: ItemConfiguration = ItemConfiguration(label: "N/A", type: .binary)
    var value: Any = false
    var enabled: Bool = true
    
    override public var description: String { return "\(config.type): \(config.label) \(value) \(enabled)" }
    
    init(config: ItemConfiguration, value: Any, enabled: Bool = true) {
        self.config = config
        self.value = value
        self.enabled = true
    }
    
    public required init?(coder: NSCoder) {
        if let config = coder.decodeObject(forKey: "config") as? ItemConfiguration {
            self.config = config
        }
        if let value = coder.decodeObject(forKey: "value") {
            self.value = value
        }
        self.enabled = coder.decodeBool(forKey: "enabled")
    }

    public func encode(with coder: NSCoder) {
        coder.encode(config, forKey: "config")
        coder.encode(value, forKey: "value")
        coder.encode(enabled, forKey: "enabled")
    }
    
    public func isSummarizable() -> Bool {
        return config.type == .binary ||  config.type == .slider || config.type == .number
    }
    
    public func extractFloat() -> Float? {
        return value as? Float
    }
    
    public func extractInt() -> Int? {
        guard let floatVal = value as? Float else { return nil }
        return Int(floatVal)
    }
    
    public func extractBool() -> Bool? {
        return value as? Bool
    }
}

class FieldDataTransformer: NSSecureUnarchiveFromDataTransformer {

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override class func transformedValueClass() -> AnyClass {
        return Field.self
    }

    override class var allowedTopLevelClasses: [AnyClass] {
        return super.allowedTopLevelClasses + [NSArray.self, Field.self, ItemConfiguration.self, NSNumber.self, NSString.self]
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
        }
        return super.transformedValue(data)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let reminder = value as? [Field] else {
            fatalError("Wrong data type: value must be a Field object; received \(type(of: value))")
        }
        return super.reverseTransformedValue(reminder)
    }
}



extension NSValueTransformerName {
    static let fieldToDataTransformer = NSValueTransformerName(rawValue: "FieldToDataTransformer")
}
