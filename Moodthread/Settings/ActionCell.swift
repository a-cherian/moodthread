//
//  ActionCell.swift
//  Moodthread
//
//  Created by AC on 2/7/24.
//

import UIKit

protocol ActionCellDelegate: AnyObject {
    func didPerformAction(action: String) -> Bool
}

class ActionCell: UITableViewCell {
    weak var delegate: ActionCellDelegate?
    static let identifier = "action"
    
    var action = "Save" {
        didSet {
            actionButton.setTitle(action, for: .normal)
        }
    }
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 3
        button.setTitle(action, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 25, left: 40, bottom: 25, right: 40)
//        UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 50, leading: 50, bottom: 50, trailing: 50)
        
        button.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubviews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(actionButton)
    }
    
    func configureUI() {
        configureActionButton()
    }
    
    func configureActionButton() {
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -80),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 80),
//            submitButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
//            itemLabel.heightAnchor.constraint(equalToConstant: 25),
        ])
    }
    
    @objc func didTapAction() {
        let success = delegate?.didPerformAction(action: action) ?? false
        if(action == "Save" && success) { animateActionButton() }
    }
    
    func animateActionButton() {
        let prevTitle = actionButton.title(for: .normal)
        actionButton.setTitle("", for: .normal)
        actionButton.tintColor = .black
        actionButton.setTitleColor(.black, for: .normal)
        actionButton.setTitle("", for: .normal)
        actionButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        
        UIView.animate(withDuration: 0.8, animations: {
            self.actionButton.backgroundColor = Appearance().tintColor
        }) { _ in
            self.actionButton.setTitle(prevTitle, for: .normal)
            self.actionButton.setImage(UIImage(), for: .normal)
            UIView.animate(withDuration: 0.4, animations: {
                self.actionButton.backgroundColor = .black
                self.actionButton.tintColor = .white
                self.actionButton.setTitleColor(.white, for: .normal)
            })
        }
    }
}
