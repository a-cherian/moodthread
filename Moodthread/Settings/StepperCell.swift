//
//  StepperCell.swift
//  Moodthread
//
//  Created by AC on 1/29/24.
//

import UIKit

protocol StepperCellDelegate: AnyObject {
    func didStepValue(value: Int, type: String)
}

class StepperCell: UITableViewCell, UITextFieldDelegate {
    
    static let identifier = "stepper"
    static let size: CGFloat = 50
    
    weak var delegate: StepperCellDelegate?
    var position = -1
    var value = 0 {
        didSet {
            valueStepper.value = Double(value)
            valueTextField.text = String(value)
            detailTextLabel?.text = String(value)
        }
    }
    
    lazy var container: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.text = "Blank"
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    lazy var valueStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.setDecrementImage(stepper.decrementImage(for: .normal), for: .normal)
        stepper.setIncrementImage(stepper.incrementImage(for: .normal), for: .normal)
        stepper.value = Double(0)
        
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
        textField.text = String(0)
        textField.delegate = self
        
        textField.addTarget(self, action: #selector(didTextChange), for: .editingDidEnd)
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none
        
        accessoryView = valueStepper
//        addSubviews()
//        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(itemLabel)
        contentView.addSubview(valueStepper)
//        contentView.addSubview(valueTextField)
    }
    
    func configureUI() {
        configureLabel()
//        configureTextField()
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
//        valueTextField.text = String(value)
        delegate?.didStepValue(value: value, type: textLabel?.text ?? "")
    }
    
    @objc func didTextChange() {
        value = Int(valueTextField.text ?? "0") ?? 0
//        valueStepper.value = Double(value)
//        delegate?.didChangeValue(value: value, position: position)
    }
    
}
