//
//  SubmitCell.swift
//  Moodthread
//
//  Created by AC on 10/21/23.
//

import UIKit

protocol SubmitDelegate: AnyObject {
    func didSubmitOccur() -> Bool
}

class SubmitCell: UICollectionViewCell {
    weak var delegate: SubmitDelegate?
    static let identifier = "submit"
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 3
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
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
    }
    
    func configureSubmitButton() {
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            submitButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            submitButton.topAnchor.constraint(equalTo: topAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 75),
            submitButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func didTapSubmit() {
        if(delegate?.didSubmitOccur() ?? false)
        {
            animateSubmitButton()
        }
    }
    
    func animateSubmitButton() {
        submitButton.setTitle("", for: .normal)
        submitButton.tintColor = .black
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.setTitle("", for: .normal)
        submitButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        
        UIView.animate(withDuration: 0.8, animations: {
            self.submitButton.backgroundColor = Appearance().tintColor
        }) { _ in
            self.submitButton.setTitle("Submit", for: .normal)
            self.submitButton.setImage(UIImage(), for: .normal)
            UIView.animate(withDuration: 0.4, animations: {
                self.submitButton.backgroundColor = .black
                self.submitButton.tintColor = .white
                self.submitButton.setTitleColor(.white, for: .normal)
            })
        }
    }
}
