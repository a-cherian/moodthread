//
//  UIButtonEX.swift
//  Moodthread
//
//  Created by AC on 5/21/24.
//

import UIKit

class UIButtonEX: UIButton {
    override var isEnabled: Bool {
            didSet {
                self.tintColor = Appearance().tintColor
            }
        }
}
