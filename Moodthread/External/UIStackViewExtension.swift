//
//  UIStackViewExtension.swift
//  Moodthread
//
//  Created by AC on 5/22/24.
//

import UIKit

extension UIStackView
{
    func removeFromStack(_ view: UIView) {
        self.removeArrangedSubview(view)
        view.removeFromSuperview()
    }
}
