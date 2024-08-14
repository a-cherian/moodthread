//
//  CustomFieldCell.swift
//  Moodthread
//
//  Created by AC on 1/26/24.
//

import UIKit

protocol CustomFieldCellDelegate: AnyObject {
    func didUpdateView()
    func didModify(config: ItemConfiguration?, position: Int)
}

class CustomFieldCell: UITableViewCell, StepperViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    static let identifier = "field"
    static let genericFormat = [LabelCell.identifier, DropdownCell.identifier, PickerCell.identifier]
    static let numberFormat = [LabelCell.identifier, DropdownCell.identifier, PickerCell.identifier, "Min", "Max"]
    static let validTypes: [Type] = [Type.slider, Type.number, Type.binary]
    
    let format: [Type: [String]] = [.slider : CustomFieldCell.numberFormat,
                                    .number : CustomFieldCell.numberFormat,
                                    .binary : CustomFieldCell.genericFormat,
                                    .select : CustomFieldCell.genericFormat,
                                    .multiSelect : CustomFieldCell.genericFormat,
                                    .txt : CustomFieldCell.genericFormat]
    
    weak var delegate: CustomFieldCellDelegate?
    var position = -1
    
    var config = ItemConfiguration(label: "", type: .binary) {
        didSet {
            itemLabel.text = config.label
            dropdownButton.setTitle(config.type.rawValue, for: .normal)
            pickerView.selectRow(CustomFieldCell.validTypes.firstIndex(of: config.type) ?? 0, inComponent: 0, animated: false)
            
            stackView.removeFromStack(minStepper)
            stackView.removeFromStack(maxStepper)
            
            if let config = config as? NumberConfiguration {
                stackView.addArrangedSubview(minStepper)
                stackView.addArrangedSubview(maxStepper)
                
                configureRowView(row: minStepper)
                configureRowView(row: maxStepper)
            }
            
            delegate?.didModify(config: config, position: position)
            delegate?.didUpdateView()
        }
    }
    var extras: [Float] = [0, 5]
    
    var selectedIndices: [Int] = []
    var dropdown = false {
        didSet {
            if(dropdown) {
                dropdownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                stackView.insertArrangedSubview(pickerView, at: 2)
            }
            else {
                dropdownButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
                stackView.removeFromStack(pickerView)
            }
            delegate?.didUpdateView()
        }
    }
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.spacing = 5
        stack.backgroundColor = UIColor.black
        return stack
    }()
    
    lazy var labelView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var itemLabel: UITextField = {
        let textField = UITextField()
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
    
    lazy var dropdownView: UIView = {
        let view = UIView()
        
        let dropdownTap = UITapGestureRecognizer(target: self, action: #selector(didTapDropdown))
        view.addGestureRecognizer(dropdownTap)
        
        return view
    }()
    
    lazy var typeLabel: UILabel = {
        let textField = UILabel()
        textField.textColor = .white
        textField.textAlignment = .left
        textField.text = "Type"
        return textField
    }()
    
    lazy var dropdownButton: UIButton = {
        let button = UIButtonEX()
        
        button.backgroundColor = .clear
        button.tintColor = Appearance().tintColor
        button.layer.cornerRadius = 10
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.setTitleColor(.gray, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 20)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.adjustsImageWhenDisabled = false
        button.isEnabled = false
        
        return button
    }()
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    lazy var minStepper: StepperView = {
        let stepper = StepperView()
        
        stepper.itemLabel.text = "Min"
        stepper.value = Int(extras[0])
        stepper.delegate = self
        
        return stepper
    }()
    
    lazy var maxStepper: StepperView = {
        let stepper = StepperView()
        
        stepper.itemLabel.text = "Max"
        stepper.value = Int(extras[1])
        stepper.delegate = self
        
        return stepper
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none
        
        addSubviews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(stackView)
        
        labelView.addSubview(itemLabel)
        labelView.addSubview(deleteButton)
        stackView.addArrangedSubview(labelView)
        
        dropdownView.addSubview(typeLabel)
        dropdownView.addSubview(dropdownButton)
        stackView.addArrangedSubview(dropdownView)
    }

    func configureUI() {
        configureStackView()
        
        configureRowView(row: labelView)
        configureLabel(label: itemLabel, parent: labelView, sibling: deleteButton)
        configureRowButton(button: deleteButton, parent: labelView)
        
        configureRowView(row: dropdownView)
        configureLabel(label: typeLabel, parent: dropdownView, sibling: dropdownButton)
        configureRowButton(button: dropdownButton, parent: dropdownView)
        
        configurePicker()
        
        stackView.addArrangedSubview(minStepper)
        stackView.addArrangedSubview(maxStepper)
        
        configureRowView(row: minStepper)
        configureStepper(stepper: minStepper)
        configureRowView(row: maxStepper)
        configureStepper(stepper: maxStepper)
        
        stackView.removeFromStack(minStepper)
        stackView.removeFromStack(maxStepper)
    }
    
    func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configureRowView(row: UIView) {
        row.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20),
            row.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20),
            row.heightAnchor.constraint(equalToConstant: 50).withPriority(999)
        ])
    }
    
    func configureLabel(label: UIView, parent: UIView, sibling: UIView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: sibling.trailingAnchor),
            label.topAnchor.constraint(equalTo: parent.topAnchor, constant: 15),
            label.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -15)
        ])
    }
    
    func configureRowButton(button: UIView, parent: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            button.leadingAnchor.constraint(equalTo: itemLabel.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            button.topAnchor.constraint(equalTo: parent.topAnchor, constant: 15),
            button.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -15),
//            button.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configurePicker() {
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.heightAnchor.constraint(equalToConstant: 100).withPriority(999)
        ])
    }
    
    func configureStepper(stepper: UIView) {
        stepper.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepper.heightAnchor.constraint(equalToConstant: 50).withPriority(999)
        ])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CustomFieldCell.validTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CustomFieldCell.validTypes[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didPickValue(value: Type.allCases[row].rawValue)
    }
    
    @objc func didTextChange() {
        didChangeLabel(label: itemLabel.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func didTapDropdown() {
        dropdown = !dropdown
    }

    
    func refreshData() {
        refreshConfig()
    }
    
    func didPickValue(value: String) {
        config.type = Type(rawValue: value) ?? .slider
        refreshData()
    }
    
    func didChangeLabel(label: String) {
        guard let numConfig = config as? NumberConfiguration else {
            config = createConfig(label: label, type: config.type)
            return
        }
        config = createConfig(label: label, type: numConfig.type, min: numConfig.minValue, max: numConfig.maxValue)
    }
    
    @objc func didTapDelete() {
        delegate?.didModify(config: nil, position: position)
    }
    
    func didStepValue(value: Int, type: String) {
        guard let numConfig = config as? NumberConfiguration else { return }
        if(type == "Min") {
            config = createConfig(label: numConfig.label, type: numConfig.type, min: Float(value), max: numConfig.maxValue)
            extras[0] = Float(value)
        }
        if(type == "Max") {
            config = createConfig(label: numConfig.label, type: numConfig.type, min: numConfig.minValue, max: Float(value))
            extras[1] = Float(value)
        }
    }
    
    func refreshConfig() {
        if(format[config.type] == CustomFieldCell.numberFormat) {
            config = createConfig(label: config.label, type: config.type, min: extras[0], max: extras[1])
        }
        else {
            config = createConfig(label: config.label, type: config.type)
        }
    }
    
    func createConfig(label: String, type: Type, min: Float? = nil, max: Float? = nil) -> ItemConfiguration {
        guard let min = min, let max = max else { return ItemConfiguration(label: label, type: type) }
        return NumberConfiguration(label: label, type: type, min: min, max: max)
    }
}
