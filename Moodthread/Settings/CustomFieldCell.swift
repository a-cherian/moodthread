//
//  CustomFieldCell.swift
//  Moodthread
//
//  Created by AC on 1/26/24.
//

import UIKit

protocol CustomFieldCellDelegate: AnyObject {
    func didUpdate(config: ItemConfiguration?, position: Int)
}

class CustomFieldCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate, PickerCellDelegate, LabelCellDelegate, StepperCellDelegate {
    static let identifier = "field"
    static let genericFormat = [LabelCell.identifier, DropdownCell.identifier, PickerCell.identifier]
    static let numberFormat = [LabelCell.identifier, DropdownCell.identifier, PickerCell.identifier, "Min", "Max"]
    
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
            delegate?.didUpdate(config: config, position: position)
        }
    }
    var extras: [Float] = [0, 5]
    
    var selectedIndices: [Int] = []
    var visibleIndices: [Int] = []
    var visibleCells: [String] {
        return visibleIndices.sorted(by: { $0 < $1 }).compactMap { format[config.type]?[$0] }
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRectZero, style: .plain)
        
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.layer.cornerCurve = .continuous
        table.layer.cornerRadius = 10
        table.isScrollEnabled = false
        
        table.dataSource = self
        table.delegate = self
        table.register(LabelCell.self, forCellReuseIdentifier: LabelCell.identifier)
        table.register(DropdownCell.self, forCellReuseIdentifier: DropdownCell.identifier)
        table.register(PickerCell.self, forCellReuseIdentifier: PickerCell.identifier)
        table.register(StepperCell.self, forCellReuseIdentifier: StepperCell.identifier)
        
        return table
    }()
    
    lazy var container: UIView = {
        let view = UIView()
        return view
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
        contentView.addSubview(container)
        container.addSubview(tableView)
    }

    func configureUI() {
        configureContainer()
        configureTableView()
    }
    
    func configureContainer() {
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: container.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200 + 100)
        ])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = visibleCells[indexPath.item]
        
        if(type == LabelCell.identifier) {
            let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
            cell.itemLabel.text = config.label
            cell.delegate = self
            return cell
        }
        if(type == PickerCell.identifier) {
            let cell = tableView.dequeueReusableCell(withIdentifier: PickerCell.identifier, for: indexPath) as! PickerCell
            cell.pickerView.selectRow(Type.allCases.firstIndex(of: config.type) ?? 0, inComponent: 0, animated: false)
            cell.delegate = self
            return cell
        }
        if(type == DropdownCell.identifier) {
            let cell = tableView.dequeueReusableCell(withIdentifier: DropdownCell.identifier, for: indexPath)
            cell.textLabel?.text = "Type"
            cell.detailTextLabel?.text = config.type.rawValue
            if(cell.accessoryView == nil) {
                cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.down"))
            }
//            cell.accessoryType = .disclosureIndicator
            return cell
        }
        if(type == "Min" || type == "Max") {
            let cell = tableView.dequeueReusableCell(withIdentifier: StepperCell.identifier, for: indexPath) as! StepperCell
            cell.textLabel?.text = type
            cell.detailTextLabel?.text = String(cell.value)
            cell.delegate = self
            cell.position = indexPath.row
            cell.value = (type == "Min") ? Int(extras[0]) : Int(extras[1])
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return format[type]?.count ?? 0
        return visibleCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let visible = hiddenIndices.map { format[type]?[$0] }
//        print("HELLOOOOOO")
//        let type = visibleCells[indexPath.item]
//        
//        if(type == PickerCell.identifier) {
//            return 200
//        }
//        return 50
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50
//        guard let type = visibleCells[indexPath.item] else { return 0 }
        let type = visibleCells[indexPath.item]
        
//        if(selectedIndices.contains(indexPath.row - 1)) { return 0 }
        if(type == PickerCell.identifier) { return PickerCell.size }
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let type = format[currType]?[indexPath.item] else { return }
        let type = visibleCells[indexPath.item]
        
        if(type == DropdownCell.identifier) {
            let cell = tableView.cellForRow(at: indexPath)
            
            if(visibleIndices.contains(indexPath.row + 1)) {
//                selectedIndices.append(indexPath.row)
                visibleIndices.removeAll(where: { $0 == indexPath.row + 1 })
                cell?.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
            }
            else {
                visibleIndices.append(indexPath.row + 1)
                cell?.accessoryView = UIImageView(image: UIImage(systemName: "chevron.down"))
            }
            
            tableView.reloadData()
        }
    }
    
    func refreshData(currentVisible: [Int]? = nil) {
        refreshConfig()
        refreshIndices(currentVisible: currentVisible)
        tableView.reloadData()
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
    
    func didTapDelete() {
        delegate?.didUpdate(config: nil, position: position)
    }
    
    func didStepValue(value: Int, type: String) {
        guard let numConfig = config as? NumberConfiguration else { return }
        if(type == "Min") { config = createConfig(label: numConfig.label, type: numConfig.type, min: Float(value), max: numConfig.maxValue) }
        if(type == "Max") { config = createConfig(label: numConfig.label, type: numConfig.type, min: numConfig.minValue, max: Float(value)) }
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
