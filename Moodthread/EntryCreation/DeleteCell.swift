//
//  DeleteCell.swift
//  Moodthread
//
//  Created by AC on 12/8/23.
//

import UIKit

protocol DeleteDelegate: AnyObject {
    func didDeleteOccur()
}

class DeleteCell: UICollectionViewCell {
    weak var delegate: DeleteDelegate?
    static let identifier = "delete"
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.red, for: .normal)
        
        button.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        
        addSubviews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(deleteButton)
    }
    
    func configureUI() {
        configureDeleteButton()
    }
    
    func configureDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc func didTapDelete() {
        delegate?.didDeleteOccur()
    }
}
