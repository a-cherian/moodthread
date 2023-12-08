//
//  Item.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

protocol FieldCellDelegate: AnyObject {
    func didChangeValue<T>(value: T, position: Int)
}

protocol FieldCell {
    associatedtype T
    
    var label: String { get set }
    var type: Type { get set }
    var value: T { get set }
}
