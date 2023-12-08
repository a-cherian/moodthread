//
//  SubmitCell.swift
//  Moodthread
//
//  Created by AC on 10/21/23.
//

import UIKit

protocol SubmitDelegate: AnyObject {
    func didSubmitOccur()
}

class SubmitCell: UICollectionViewCell {
    weak var delegate: SubmitDelegate?
    static let identifier = "submit"
    
    var value: Bool = false {
        didSet {
            submitButton.backgroundColor = value ? .cyan : .black
            submitButton.setTitleColor(value ? .black : .white, for: .normal)
        }
    }
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = value ? .cyan : .black
        button.layer.cornerRadius = 10
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(value ? .black : .white, for: .normal)
        
        button.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .black
        
        addSubviews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(submitButton)
    }
    
    func configureUI() {
        configureSubmitButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.heightAnchor.constraint(equalToConstant: 75),
            submitButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configureSubmitButton() {
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            submitButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            submitButton.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    @objc func didTapSubmit() {
        delegate?.didSubmitOccur()
    }
}
