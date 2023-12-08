//
//  NumberCell.swift
//  Moodthread
//
//  Created by AC on 10/30/23.
//

import UIKit

class NumberCell: UICollectionViewCell, FieldCell, UITextFieldDelegate {
    
    static let identifier = "number"
    weak var delegate: FieldCellDelegate?
    var position = -1
    
    typealias T = Int
    var type: Type = .number
    var label: String = ""
    var value: Int = 0
    var initialized: Bool = false
    
    lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.text = "Blank"
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    lazy var valueStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.tintColor = .cyan
        stepper.setDecrementImage(stepper.decrementImage(for: .normal), for: .normal)
        stepper.setIncrementImage(stepper.incrementImage(for: .normal), for: .normal)
        stepper.value = Double(value)
        
        stepper.addTarget(self, action: #selector(didStepperChange), for: .valueChanged)
        return stepper
    }()
    
    lazy var valueTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tintColor = .black
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.textAlignment = .center
        textField.text = String(value)
        textField.delegate = self
        
        textField.addTarget(self, action: #selector(didTextChange), for: .editingDidEnd)
        return textField
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
        contentView.addSubview(valueStepper)
        contentView.addSubview(valueTextField)
    }
    
    func configureUI() {
        configureLabel()
        configureTextField()
        configureStepper()
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
    
    func configureTextField() {
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            valueTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            valueTextField.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            valueTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            valueTextField.widthAnchor.constraint(equalTo: widthAnchor, constant: -140)
        ])
    }
    
    func configureStepper() {
        valueStepper.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            valueStepper.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            valueStepper.topAnchor.constraint(equalTo: valueTextField.topAnchor),
            valueStepper.bottomAnchor.constraint(equalTo: valueTextField.bottomAnchor)
        ])
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    @objc func didStepperChange() {
        value = Int(valueStepper.value)
        valueTextField.text = String(value)
        delegate?.didChangeValue(value: value, position: position)
    }
    
    @objc func didTextChange() {
        value = Int(valueTextField.text ?? "0") ?? 0
        valueStepper.value = Double(value)
        delegate?.didChangeValue(value: value, position: position)
    }
}


