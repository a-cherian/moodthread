//
//  DropdownButtonCell.swift
//  Moodthread
//
//  Created by AC on 1/28/24.
//

import UIKit

class DropdownCell: UITableViewCell {
    
    static let identifier = "dropdown"
    static let size: CGFloat = 50
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
