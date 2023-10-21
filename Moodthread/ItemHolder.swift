//
//  ItemHolder.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

protocol ItemHolder {
    associatedtype T
    var value: T { get set }
    
    func initialize()
}
