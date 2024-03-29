//
//  BinaryCell.swift
//  Moodthread
//
//  Created by AC on 10/21/23.
//

import UIKit

class BinaryCell: UICollectionViewCell, FieldCell {
    
    static let identifier = "binary"
    weak var delegate: FieldCellDelegate?
    var position = -1
    
    typealias T = Bool
    var type: Type = .binary
    var label: String = ""
    var value: Bool = false {
        didSet {
            trueButton.backgroundColor = value ? Appearance().tintColor : .black
            trueButton.tintColor = value ? .black : .white
            
            falseButton.backgroundColor = value ? .black : Appearance().tintColor
            falseButton.tintColor = value ? .white : .black
        }
    }
    var initialized: Bool = false
    var enabled: Bool = true {
        didSet {
            disableButton.tintColor = enabled ? .gray : .red
            if(enabled) {
                overlayView.removeFromSuperview()
            }
            else {
                addSubview(overlayView)
                addSubview(disableButton)
                configureOverlayView()
            }
        }
    }
    
    lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.text = "Blank"
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    lazy var disableButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .gray
        
        button.addTarget(self, action: #selector(didTapDisable), for: .touchUpInside)
        return button
    }()
    
    lazy var overlayView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .black
        view.alpha = 0.6
        return view
    }()
    
    lazy var trueButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.backgroundColor = value ? Appearance().tintColor : .black
        button.tintColor = value ? .black : .white
        button.layer.cornerRadius = 10
        
        button.addTarget(self, action: #selector(didTapTrue), for: .touchUpInside)
        return button
    }()
    
    lazy var falseButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.backgroundColor = value ? .black : Appearance().tintColor
        button.tintColor = value ? .white : .black
        button.layer.cornerRadius = 10
        
        button.addTarget(self, action: #selector(didTapFalse), for: .touchUpInside)
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
        contentView.addSubview(itemLabel)
        contentView.addSubview(disableButton)
        contentView.addSubview(trueButton)
        contentView.addSubview(falseButton)
    }
    
    func configureUI() {
        configureLabel()
        configureDisableButton()
        configureTrueButton()
        configureFalseButton()
    }
    
    func configureLabel() {
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            itemLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            itemLabel.heightAnchor.constraint(equalToConstant: 25),
            itemLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -40)
        ])
    }
    
    func configureTrueButton() {
        trueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            trueButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -10),
            trueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            trueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureFalseButton() {
        falseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            falseButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 10),
            falseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            falseButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            falseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureDisableButton() {
        disableButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            disableButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            disableButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            disableButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    func configureOverlayView() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.heightAnchor.constraint(equalTo: heightAnchor),
            overlayView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    @objc func didTapDisable() {
        enabled = !enabled
        delegate?.didToggle(enabled: enabled, position: position)
    }
    
    @objc func didTapTrue() {
        value = true
        delegate?.didChangeValue(value: value, position: position)
    }
    
    @objc func didTapFalse() {
        value = false
        delegate?.didChangeValue(value: value, position: position)
    }
}
