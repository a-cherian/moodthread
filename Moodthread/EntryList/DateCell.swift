//
//  DateCell.swift
//  Moodthread
//
//  Created by AC on 12/7/23.
//

import UIKit

class DateCell: UICollectionViewCell {
    
    static let identifier = "date"
    var position = -1
    var initialized: Bool = false
    
    lazy var date: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        
        addSubviews()
        configureUI(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(date)
    }
    
    func configureUI(frame: CGRect) {
        configureLabel()
    }
    
    func configureLabel() {
        date.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            date.centerXAnchor.constraint(equalTo: centerXAnchor),
            date.topAnchor.constraint(equalTo: topAnchor, constant: 20)
        ])
    }
}

