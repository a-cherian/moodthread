//
//  LabelCell.swift
//  Moodthread
//
//  Created by AC on 2/7/24.
//

import UIKit

protocol LabelCellDelegate: AnyObject {
    func didChangeLabel(label: String)
    func didTapDelete()
}

class LabelCell: UITableViewCell, UITextFieldDelegate {
    
    static let identifier = "label"
    static let size: CGFloat = 50
    
    weak var delegate: LabelCellDelegate?
    
    lazy var container: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var itemLabel: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.backgroundColor = .black
        textField.textColor = .white
        textField.textAlignment = .left
        textField.text = String(0)
        textField.delegate = self
        
        textField.addTarget(self, action: #selector(didTextChange), for: .editingDidEnd)
        return textField
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .clear
        button.tintColor = .red
        button.layer.cornerRadius = 10
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        
        button.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none
        
        addSubviews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(itemLabel)
        contentView.addSubview(deleteButton)
    }
    
    func configureUI() {
        configureLabel()
        configureDeleteButton()
    }
    
    func configureLabel() {
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            itemLabel.trailingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: -20),
            itemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            itemLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }
    
    func configureDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            deleteButton.leadingAnchor.constraint(equalTo: itemLabel.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }
    
    @objc func didTextChange() {
        delegate?.didChangeLabel(label: itemLabel.text ?? "")
    }
    
    @objc func didTapDelete() {
        delegate?.didTapDelete()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
