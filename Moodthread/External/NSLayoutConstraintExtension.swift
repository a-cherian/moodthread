//
//  NSLayoutConstraintExtension.swift
//  Moodthread
//
//  Created by AC on 1/28/24.
//

import UIKit

extension NSLayoutConstraint
{
    func withPriority(_ priority: Float) -> NSLayoutConstraint
    {
        self.priority = UILayoutPriority(priority)
        return self
    }
}
