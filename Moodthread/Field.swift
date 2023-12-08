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
    override public var description: String { return "\(config.type): \(config.label) \(value)" }
    
    init(config: ItemConfiguration, value: Any) {
        self.config = config
        self.value = value
    }
    
    public required init?(coder: NSCoder) {
        if let config = coder.decodeObject(forKey: "config") as? ItemConfiguration {
            self.config = config
        }
        if let value = coder.decodeObject(forKey: "value") {
            self.value = value
        }
    }

    public func encode(with coder: NSCoder) {
        coder.encode(config, forKey: "config")
        coder.encode(value, forKey: "value")
    }
    
    public func isSummarizable() -> Bool {
        return config.type == .binary ||  config.type == .slider || config.type == .number
    }
    
    public func extractDouble() -> Double {
        return value as? Double ?? 0
    }
    
    public func extractInt() -> Int {
        return Int(value as? Double ?? 0)
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
