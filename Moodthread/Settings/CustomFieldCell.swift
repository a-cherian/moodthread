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
    
//    var field: String = ""
//    var currType: Type = .slider {
//        didSet {
//            visibleIndices = [Int](0..<(format[currType]?.count ?? 0))
//            tableView.reloadData()
//            refreshConfig()
//        }
//    }
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
//                configureStepper(stepper: minStepper)
                configureRowView(row: maxStepper)
//                configureStepper(stepper: maxStepper)
//                cell.config = config
//                cell.extras = [config.minValue, config.maxValue]
            }
            
            delegate?.didModify(config: config, position: position)
            delegate?.didUpdateView()
        }
    }
    var extras: [Float] = [0, 5]
    
    var selectedIndices: [Int] = []
    var visibleIndices: [Int] = []
    var visibleCells: [String] {
        return visibleIndices.sorted(by: { $0 < $1 }).compactMap { format[config.type]?[$0] }
    }
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
//        button.imageView?.contentMode = .scaleAspectFit
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 20)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.adjustsImageWhenDisabled = false
        button.isEnabled = false
//        button.titleLabel?.numberOfLines = 1
//        button.titleLabel?.lineBreakMode = .
        
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
//        contentView.addSubview(container)
//        container.addSubview(tableView)
        contentView.addSubview(stackView)
        
        labelView.addSubview(itemLabel)
        labelView.addSubview(deleteButton)
        stackView.addArrangedSubview(labelView)
        
        dropdownView.addSubview(typeLabel)
        dropdownView.addSubview(dropdownButton)
        stackView.addArrangedSubview(dropdownView)
        
//        stackView.addArrangedSubview(pickerView)
    }

    func configureUI() {
//        configureContainer()
//        configureTableView()
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
            label.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -15),
//            label.heightAnchor.constraint(equalToConstant: 40)
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
//            pickerView.heightAnchor.constraint(lessThanOrEqualToConstant: <#T##CGFloat#>: 200)
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
//        return Type.allCases.count - 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CustomFieldCell.validTypes[row].rawValue
//        return Type.allCases[row].rawValue
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
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let type = visibleCells[indexPath.item]
//        
//        if(type == LabelCell.identifier) {
//            let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
//            cell.itemLabel.text = config.label
//            cell.delegate = self
//            return cell
//        }
//        if(type == PickerCell.identifier) {
//            let cell = tableView.dequeueReusableCell(withIdentifier: PickerCell.identifier, for: indexPath) as! PickerCell
//            cell.pickerView.selectRow(Type.allCases.firstIndex(of: config.type) ?? 0, inComponent: 0, animated: false)
//            cell.delegate = self
//            return cell
//        }
//        if(type == DropdownCell.identifier) {
//            let cell = tableView.dequeueReusableCell(withIdentifier: DropdownCell.identifier, for: indexPath)
//            cell.textLabel?.text = "Type"
//            cell.detailTextLabel?.text = config.type.rawValue
//            if(cell.accessoryView == nil) {
//                cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.down"))
//            }
////            cell.accessoryType = .disclosureIndicator
//            return cell
//        }
//        if(type == "Min" || type == "Max") {
//            let cell = tableView.dequeueReusableCell(withIdentifier: StepperCell.identifier, for: indexPath) as! StepperCell
//            cell.textLabel?.text = type
//            cell.detailTextLabel?.text = String(cell.value)
//            cell.delegate = self
//            cell.position = indexPath.row
//            cell.value = (type == "Min") ? Int(extras[0]) : Int(extras[1])
//            return cell
//        }
//        else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
//            return cell
//        }
//    }
//    
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return format[type]?.count ?? 0
//        return visibleCells.count
//    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        let visible = hiddenIndices.map { format[type]?[$0] }
////        print("HELLOOOOOO")
////        let type = visibleCells[indexPath.item]
////        
////        if(type == PickerCell.identifier) {
////            return 200
////        }
////        return 50
//        return UITableView.automaticDimension
//    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
////        return 50
////        guard let type = visibleCells[indexPath.item] else { return 0 }
//        let type = visibleCells[indexPath.item]
//        
////        if(selectedIndices.contains(indexPath.row - 1)) { return 0 }
//        if(type == PickerCell.identifier) { return PickerCell.size }
//        return 50
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        guard let type = format[currType]?[indexPath.item] else { return }
//        let type = visibleCells[indexPath.item]
//        
//        if(type == DropdownCell.identifier) {
//            let cell = tableView.cellForRow(at: indexPath)
//            
//            if(visibleIndices.contains(indexPath.row + 1)) {
////                selectedIndices.append(indexPath.row)
//                visibleIndices.removeAll(where: { $0 == indexPath.row + 1 })
//                cell?.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
//            }
//            else {
//                visibleIndices.append(indexPath.row + 1)
//                cell?.accessoryView = UIImageView(image: UIImage(systemName: "chevron.down"))
//            }
//            
//            tableView.reloadData()
//        }
//    }
    
//    func setup(_ numButtons: Int) -> Void {
//
//        // cells are reused, so remove any previously created buttons
//        theStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//
//        for i in 1...numButtons {
//            let b = UIButton(type: .system)
//            b.setTitle("Button \(i)", for: .normal)
//            b.backgroundColor = .blue
//            b.setTitleColor(.white, for: .normal)
//            theStackView.addArrangedSubview(b)
//        }
//
//    }
    
    func refreshData(currentVisible: [Int]? = nil) {
        refreshConfig()
//        refreshIndices(currentVisible: currentVisible)
    }
    
    func refreshIndices(currentVisible: [Int]? = nil) {
        visibleIndices = [Int](0..<(format[config.type]?.count ?? 0))
        visibleIndices.forEach { index in
            visibleIndices.removeAll(where: { $0 == index + 1 && format[config.type]?[index] == DropdownCell.identifier })
        }
        guard let currentVisible = currentVisible else { return }
        visibleIndices = visibleIndices + (currentVisible.filter({ $0 < format[config.type]?.count ?? 0 && !visibleIndices.contains($0)}))
    }
    
    func didPickValue(value: String) {
        config.type = Type(rawValue: value) ?? .slider
        refreshData(currentVisible: visibleIndices)
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
