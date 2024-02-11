//
//  UIImageExtension.swift
//  Moodthread
//
//  Created by AC on 12/7/23.
//

import UIKit

extension UIImage
{
    func scale(width: CGFloat, height: CGFloat) -> UIImage {
        guard self.size.width != width else { return self }
        
        let newSize = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.setFillColor(Constants.accentColor.cgColor)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
    
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
