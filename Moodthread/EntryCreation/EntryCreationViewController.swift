//
//  ViewController.swift
//  Moodthread
//
//  Created by AC on 10/6/23.
//

import UIKit

class EntryCreationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SubmitDelegate, DeleteDelegate, FieldCellDelegate {
    
    let defaultFields: [Field] = [Field(config: NumberConfiguration(label: "Mood", type: .slider, min: 0, max: 5), value: Float(2.5)),
                          Field(config: NumberConfiguration(label: "Energy", type: .slider, min: 0, max: 5), value: Float(2.5))]
    var fields: [Field] = []
    
    var date: Date? = nil
    var timer: Timer? = nil
    var previousEntry: Entry? = nil
    
    var dismissTap = UITapGestureRecognizer()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: CGRect(origin: CGPointZero, size: CGSize(width: 500, height: 200)))
        datePicker.datePickerMode = .dateAndTime
        datePicker.timeZone = TimeZone.current
        datePicker.contentHorizontalAlignment = .center
        datePicker.addTarget(self, action: #selector(didPickDate(sender:)), for: .valueChanged)
        return datePicker
    }()
    
    lazy var fieldsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.tintColor = .black
        collection.showsVerticalScrollIndicator = true
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0);
        collection.dataSource = self
        collection.delegate = self
        collection.register(SliderCell.self, forCellWithReuseIdentifier: SliderCell.identifier)
        collection.register(NumberCell.self, forCellWithReuseIdentifier: NumberCell.identifier)
        collection.register(SelectCell.self, forCellWithReuseIdentifier: SelectCell.identifier)
        collection.register(BinaryCell.self, forCellWithReuseIdentifier: BinaryCell.identifier)
        collection.register(SubmitCell.self, forCellWithReuseIdentifier: SubmitCell.identifier)
        collection.register(DeleteCell.self, forCellWithReuseIdentifier: DeleteCell.identifier)
        return collection
    }()
    
    init(entry: Entry? = nil) {
        super.init(nibName: nil, bundle: nil)
        if let entry = entry {
            previousEntry = entry
            fields = entry.fields!
            date = entry.time
            datePicker.date = entry.time ?? Date()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Add Entry"
        
        loadFields()
        
        addSubviews()
        configureUI()
        addKeyboardDismissGesture()
//        configureTimePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadFields()
        fieldsView.reloadData()
    }
    
    func loadFields() {
        if(previousEntry != nil) { return }
        
        fields = []
        
        let customConfigs = DataManager.shared.getCustomFields()
        let customFields: [Field] = customConfigs.compactMap {
            switch($0.type) {
            case .slider:
                guard let numConfig = $0 as? NumberConfiguration else { return nil }
                return Field(config: $0, value: (numConfig.minValue + numConfig.maxValue) / 2)
            case .number:
                guard let numConfig = $0 as? NumberConfiguration else { return nil }
                return Field(config: $0, value: Int(numConfig.minValue))
            case .binary:
                return Field(config: $0, value: false)
            default:
                return nil
            }
        }
        fields = defaultFields + customFields
    }
    
    func addSubviews() {
        view.addSubview(datePicker)
        view.addSubview(fieldsView)
    }

    func configureUI() {
        configureClock()
        configureItems()
    }
    
    func configureClock() {
        if date == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(didTimeChange), userInfo: nil, repeats: true)
        }
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            datePicker.heightAnchor.constraint(equalToConstant: 40)
        ])
        datePicker.subviews[0].backgroundColor = .black
        datePicker.subviews[0].subviews[0].backgroundColor = .black
        datePicker.subviews[0].subviews[1].backgroundColor = .black
        datePicker.subviews[0].layer.cornerRadius = 10
        datePicker.subviews[0].subviews[0].layer.cornerRadius = 10
//        datePicker.subviews[0].subviews[0].subviews[0].alpha = 0
    }
    
    func configureItems() {
        fieldsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fieldsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fieldsView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            fieldsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fieldsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fieldsView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func addKeyboardDismissGesture() {
        dismissTap = UITapGestureRecognizer(target: self, action: #selector(didDismiss))
        view.addGestureRecognizer(dismissTap)
    }
    
    @objc func didTimeChange() {
        if(date != nil) { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE — MMM d — h:mm a"
        datePicker.date = Date()
    }
    
    @objc func didPickDate(sender: UIDatePicker) {
        date = sender.date
     }

    
    @objc func didDismiss() {
        view.endEditing(true)
    }
    
    func didSubmitOccur() -> Bool {
        if let entry = previousEntry {
            entry.fields = fields
            entry.time = date ?? entry.time
            DataManager.shared.updateEntry(entry: entry)
            self.navigationController?.popViewController(animated: true)
        }
        else {
            DataManager.shared.createEntry(time: date ?? Date(), fields: fields)
        }
        
        return true
    }
    
    
    func didDeleteOccur() {
        // TO DO: confirm delete
        let alert = UIAlertController(
            title: "Confirm deletion",
            message: "This will delete this entry. This action is irreversible. Do you wish to proceed?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { _ in
                self.didDeleteConfirmOccur()
        }))
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { _ in
            // cancel action
        }))
        present(alert,
                animated: true,
                completion: nil
        )
    }
    
    func didDeleteConfirmOccur() {
        if let entry = previousEntry {
            DataManager.shared.deleteEntry(entry: entry)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func didChangeValue<T>(value: T, position: Int) {
        fields[position].value = value
    }
    
    func didToggle(enabled: Bool, position: Int) {
        fields[position].enabled = enabled
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if previousEntry != nil { return fields.count + 2 }
        return fields.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == fields.count {
            let cell = fieldsView.dequeueReusableCell(withReuseIdentifier: SubmitCell.identifier, for: indexPath) as! SubmitCell
            cell.delegate = self
            cell.contentView.layer.cornerRadius = 10
            return cell
        }
        
        if indexPath.item == fields.count + 1 {
            let cell = fieldsView.dequeueReusableCell(withReuseIdentifier: DeleteCell.identifier, for: indexPath) as! DeleteCell
            cell.delegate = self
            cell.contentView.layer.cornerRadius = 10
            return cell
        }
        
        let item = fields[indexPath.item]
        
        switch(item.config.type) {
        case .slider:
            let sliderConfig = item.config as! NumberConfiguration
            let cell = fieldsView.dequeueReusableCell(withReuseIdentifier: SliderCell.identifier, for: indexPath) as! SliderCell
            cell.delegate = self
            cell.position = indexPath.item
            cell.enabled = item.enabled
            cell.contentView.layer.cornerRadius = 10
            cell.itemLabel.text = sliderConfig.label
            if(sliderConfig.minValue != cell.valueSlider.minimumValue || sliderConfig.maxValue != cell.valueSlider.maximumValue) {
                cell.initialized = false
            }
            if(!cell.initialized) {
                cell.valueSlider.minimumValue = sliderConfig.minValue
                cell.valueSlider.maximumValue = sliderConfig.maxValue
                cell.valueSlider.value = item.value as! Float
                cell.initialized = true
            }
            return cell
        case .number:
            let numberConfig = item.config as! NumberConfiguration
            let cell = fieldsView.dequeueReusableCell(withReuseIdentifier: NumberCell.identifier, for: indexPath) as! NumberCell
            cell.delegate = self
            cell.position = indexPath.item
            cell.enabled = item.enabled
            cell.contentView.layer.cornerRadius = 10
            cell.itemLabel.text = numberConfig.label
            if(Double(numberConfig.minValue) != cell.valueStepper.minimumValue || Double(numberConfig.maxValue) != cell.valueStepper.maximumValue) {
                cell.initialized = false
            }
            if(!cell.initialized) {
                cell.valueStepper.minimumValue = Double(numberConfig.minValue)
                cell.valueStepper.maximumValue = Double(numberConfig.maxValue)
                cell.value = item.value as! Int
                cell.valueStepper.value = Double(cell.value)
                cell.valueTextField.text = String(cell.value)
                cell.initialized = true
            }
            return cell
        case .binary:
            let cell = fieldsView.dequeueReusableCell(withReuseIdentifier: BinaryCell.identifier, for: indexPath) as! BinaryCell
            cell.delegate = self
            cell.position = indexPath.item
            cell.enabled = item.enabled
            cell.contentView.layer.cornerRadius = 10
            cell.itemLabel.text = item.config.label
            if(!cell.initialized) {
                cell.value = (item.value as! NSNumber).boolValue
//                cell.value = item.value as! Bool
                cell.initialized = true
            }
            return cell
        case .select:
            let selectConfig = item.config as! SelectConfiguration
            let cell = fieldsView.dequeueReusableCell(withReuseIdentifier: SelectCell.identifier, for: indexPath) as! SelectCell
            cell.delegate = self
            cell.position = indexPath.item
            cell.contentView.layer.cornerRadius = 10
            cell.itemLabel.text = selectConfig.label
            if(!cell.initialized) {
                cell.options = selectConfig.options
//                cell.buttonsView.reloadData()
//                cell.buttonsView.collectionViewLayout.invalidateLayout()
                cell.configureCollection()
                cell.initialized = true
            }
            return cell
//        case .multiSelect:
//            <#code#>
//        case .txt:
//            <#code#>
        default:
            let cell = fieldsView.dequeueReusableCell(withReuseIdentifier: SubmitCell.identifier, for: indexPath) as! SubmitCell
            cell.delegate = self
            cell.contentView.layer.cornerRadius = 10
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == fields.count { return CGSize(width: 200, height: 75) } // submit cell
        if indexPath.item == fields.count + 1 { return CGSize(width: 200, height: 50) } // delete cell
        
        let item = fields[indexPath.item]
        
        let viewWidth = view.frame.width - 40
        let submitWidth = 200
        
        if item.config.type == .slider || item.config.type == .binary || item.config.type == .number || item.config.type == .select {
            return CGSize(width: viewWidth, height: 120)
        }
//        if item.type == .select {
//            let cell = itemsView.dequeueReusableCell(withReuseIdentifier: SelectCell.identifier, for: indexPath) as! SelectCell
//            return cell.buttonsView.contentSize
////            return UICollectionViewFlowLayout.automaticSize
//        }
        else if item.config.type == .submit {
            return CGSize(width: submitWidth, height: 75)
        }
        else {
            return CGSize(width: 0, height: 0)
        }
    }
}

