//
//  Constants.swift
//  Moodthread
//
//  Created by AC on 12/15/23.
//

import UIKit

struct Constants {
    static let accentColor: UIColor = UIColor(red: 151 / 255, green: 209 / 255, blue: 184 / 255, alpha: 1)
    static let themeColors: [UIColor] = [Constants.accentColor, .systemMint, .systemPurple, .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue]
    static let TOP_MARGIN: CGFloat = 20
    static let BOTTOM_MARGIN: CGFloat = -20
    static let WIDTH_MARGIN: CGFloat = -50
    static let CUSTOM_FIELDS_KEY = "customFields"
    static let NOTIFICATIONS_KEY = "notifications"
}
