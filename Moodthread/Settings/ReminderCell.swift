//
//  ReminderCell.swift
//  Moodthread
//
//  Created by AC on 8/2/24.
//

import UIKit
import UserNotifications

protocol ReminderCellDelegate: AnyObject {
    func didChangeTime(time: Date, position: Int)
    func didTapDelete(position: Int)
}

class ReminderCell: UITableViewCell, UITextFieldDelegate {
    
    static let identifier = "reminder"
    static let size: CGFloat = 50
    
    weak var delegate: ReminderCellDelegate?
    var position = -1
    
    lazy var container: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var timePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: CGRect(origin: CGPointZero, size: CGSize(width: 500, height: 200)))
        datePicker.datePickerMode = .time
        datePicker.timeZone = TimeZone.current
        datePicker.contentHorizontalAlignment = .center
        datePicker.addTarget(self, action: #selector(didPickDate(sender:)), for: .valueChanged)
        return datePicker
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
        contentView.addSubview(timePicker)
        contentView.addSubview(deleteButton)
    }
    
    func configureUI() {
        configureTimePicker()
        configureDeleteButton()
    }
    
    func configureTimePicker() {
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            timePicker.trailingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: 0),
            timePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            timePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configureDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            deleteButton.leadingAnchor.constraint(equalTo: itemLabel.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            deleteButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func didPickDate(sender: UIDatePicker) {
        delegate?.didChangeTime(time: sender.date, position: position)
     }
    
    @objc func didTapDelete() {
        delegate?.didTapDelete(position: position)
    }
    
}
