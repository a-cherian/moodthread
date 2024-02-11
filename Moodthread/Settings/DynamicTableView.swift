//
//  DynamicTableView.swift
//  Moodthread
//
//  Created by AC on 1/28/24.
//

import UIKit

class DynamicTableView: UITableView {
   
    override var intrinsicContentSize: CGSize {
//        return self.bounds.size
        return self.contentSize
    }

    override var contentSize: CGSize {
        didSet{
          self.invalidateIntrinsicContentSize()
        }
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.invalidateIntrinsicContentSize()
//    }
    
//    override var intrinsicContentSize: CGSize {
//        get {
//            var height:CGFloat = 0;
//            for s in 0..<self.numberOfSections {
//                let nRowsSection = self.numberOfRows(inSection: s)
//                for r in 0..<nRowsSection {
//                    height += self.rectForRow(at: IndexPath(row: r, section: s)).size.height;
//                }
//            }
//            return CGSize(width: UIView.noIntrinsicMetric, height: height)
//        }
//        set {
//        }
//    }

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }

}
