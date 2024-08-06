//
//  SubmitCell.swift
//  Moodthread
//
//  Created by AC on 10/21/23.
//

import UIKit

class SubmitDeleteCell: UICollectionViewCell {
    weak var delegate: ActionCellDelegate?
    static let identifier = "submitdelete"
    
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
    
    func addDeleteButton() {
        deleteButton.removeFromSuperview()
        contentView.addSubview(deleteButton)
        configureDeleteButton()
    }
    
    func configureSubmitButton() {
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: topAnchor),
            submitButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 75),
            submitButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configureDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            deleteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 75),
            deleteButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func didTapSubmit() {
        if(delegate?.didPerformAction(action: "Submit") ?? false)
        {
            animateSubmitButton()
        }
    }
    
    @objc func didTapDelete() {
        delegate?.didPerformAction(action: "Delete")
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
