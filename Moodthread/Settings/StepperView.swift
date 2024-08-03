//
//  StepperView.swift
//  Moodthread
//
//  Created by AC on 5/22/24.
//

import UIKit

protocol StepperViewDelegate: AnyObject {
    func didStepValue(value: Int, type: String)
}

class StepperView: UIView, UITextFieldDelegate {
    
    static let identifier = "stepper"
    static let size: CGFloat = 50
    
    weak var delegate: StepperViewDelegate?
    var position = -1
    var value = 0 {
        didSet {
            valueStepper.value = Double(value)
            valueTextField.text = String(value)
            delegate?.didStepValue(value: value, type: itemLabel.text ?? "")
//            detailTextLabel?.text = String(value)
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
        stepper.minimumValue = -Double.greatestFiniteMagnitude
        stepper.maximumValue = Double.greatestFiniteMagnitude
        
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
        textField.layer.cornerRadius = 5
        
        textField.addTarget(self, action: #selector(didTextChange), for: .editingDidEnd)
        return textField
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
        addSubview(itemLabel)
        addSubview(valueStepper)
        addSubview(valueTextField)
    }
    
    func configureUI() {
        configureLabel()
        configureTextField()
        configureStepper()
    }
    
    func configureLabel() {
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemLabel.trailingAnchor.constraint(equalTo: valueStepper.trailingAnchor),
            itemLabel.topAnchor.constraint(equalTo: topAnchor),
            itemLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func configureTextField() {
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            valueTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueTextField.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            valueTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            valueTextField.widthAnchor.constraint(equalToConstant: 100),
//            valueTextField.heightAnchor.constraint(equalToConstant: 30).with
        ])
    }
    
    func configureStepper() {
        valueStepper.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            valueStepper.trailingAnchor.constraint(equalTo: valueTextField.leadingAnchor, constant: -20),
            valueStepper.topAnchor.constraint(equalTo: valueTextField.topAnchor),
            valueStepper.bottomAnchor.constraint(equalTo: valueTextField.bottomAnchor),
            valueStepper.heightAnchor.constraint(equalTo: valueTextField.heightAnchor)
        ])
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var allowedCharacters = CharacterSet.decimalDigits
        allowedCharacters.insert("-")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    @objc func didStepperChange() {
        value = Int(valueStepper.value)
    }
    
    @objc func didTextChange() {
        value = Int(valueTextField.text ?? "0") ?? 0
//        valueStepper.value = Double(value)
//        delegate?.didChangeValue(value: value, position: position)
    }
    
}
