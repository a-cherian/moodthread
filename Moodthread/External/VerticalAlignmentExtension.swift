//
//  VerticalAlignmentExtension.swift
//  Moodthread
//
//  Created by AC on 2/15/24.
//

import Foundation
import SwiftUI

extension HorizontalAlignment {
    /// A custom alignment for image titles.
    private struct PickerAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            // Default to bottom alignment if no guides are set.
            context[HorizontalAlignment.trailing]
        }
    }


    /// A guide for aligning titles.
    static let pickerAlignmentGuide = HorizontalAlignment(
        PickerAlignment.self
    )
}
