//
//  CustomFieldCell.swift
//  Moodthread
//
//  Created by AC on 1/26/24.
//

import UIKit

protocol PickerCellDelegate: AnyObject {
    func didPickValue(value: String)
}


class PickerCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    static let identifier = "picker"
    static let size: CGFloat = 100
    static let validTypes: [Type] = [Type.slider, Type.number, Type.binary]
    
    weak var delegate: PickerCellDelegate?
    
    lazy var container: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
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
        container.addSubview(pickerView)
    }

    func configureUI() {
        configureContainer()
        configurePicker()
    }
    
    func configureContainer() {
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).withPriority(999),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configurePicker() {
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: container.topAnchor),
            pickerView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            pickerView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//            pickerView.heightAnchor.constraint(lessThanOrEqualToConstant: <#T##CGFloat#>: 200)
            pickerView.heightAnchor.constraint(equalToConstant: PickerCell.size)/*.withPriority(999)*/
        ])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PickerCell.validTypes.count
//        return Type.allCases.count - 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PickerCell.validTypes[row].rawValue
//        return Type.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didPickValue(value: Type.allCases[row].rawValue)
    }
    
}
