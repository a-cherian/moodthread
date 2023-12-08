//
//  SelectionOptionCell.swift
//  Moodthread
//
//  Created by AC on 11/1/23.
//

import UIKit

class SelectOptionCell: UICollectionViewCell {
    
    static let identifier = "option"
    weak var delegate: FieldCellDelegate?
    var position = -1
    
    lazy var button: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .white
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(button)
    }
    
    func configureUI() {
        configureButton()
    }
    
    func configureButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 40),
            button.widthAnchor.constraint(equalToConstant: 75)
//            button.leadingAnchor.constraint(equalTo: leadingAnchor),
//            button.trailingAnchor.constraint(equalTo: trailingAnchor),
//            button.topAnchor.constraint(equalTo: topAnchor),
//            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        print("lol")
    }
    
}
