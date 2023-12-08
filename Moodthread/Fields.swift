//
//  Fields.swift
//  Moodthread
//
//  Created by AC on 11/2/23.
//

import Foundation

public class Fields: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
    public var fields: [Field] = []
    
    init(fields: [Field]) {
        self.fields = fields
    }
    
    public required init?(coder: NSCoder) {
        if let fields = coder.decodeObject(forKey: "fields") as? [Field] {
            self.fields = fields
        }
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(fields, forKey: "fields")
    }
}
