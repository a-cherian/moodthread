//
//  ViewController.swift
//  Moodthread
//
//  Created by AC on 10/6/23.
//

import UIKit

class EntryCreationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SubmitDelegate, FieldCellDelegate {
    
//    var items: [Field] = [Field(config: NumberConfiguration(label: "Mood", type: .slider, min: 1, max: 5), value: Float(3)),
//                          Field(config: NumberConfiguration(label: "Energy", type: .slider, min: 1, max: 5), value: Float(3)),
//                          Field(config: ItemConfiguration(label: "Toggle", type: .binary), value: false),
//                          Field(config: NumberConfiguration(label: "Number", type: .number, min: -5, max: 10000), value: 23)]
    var items: [Field] = [Field(config: NumberConfiguration(label: "Mood", type: .slider, min: 1, max: 5), value: Float(3)),
                          Field(config: NumberConfiguration(label: "Energy", type: .slider, min: 1, max: 5), value: Float(3))]
    
    var dismissTap = UITapGestureRecognizer()
    lazy var clock: UILabel = {
        let label = UILabel()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE — MMM d — h:mm a"
        label.text = dateFormatter.string(from: Date())
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    lazy var itemsView: UICollectionView = {
//        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
//        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: view.frame.width - 40, height: 120)
//        layout.estimatedItemSize = CGSize(width: view.frame.width - 40, height: 120)
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
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
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviews()
        configureUI()
        addKeyboardDismissGesture()
    }
    
    func addSubviews() {
        view.addSubview(clock)
        view.addSubview(itemsView)
    }

    func configureUI() {
        configureClock()
        configureItems()
    }
    
    func configureClock() {
        clock.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clock.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clock.topAnchor.constraint(equalTo: view.topAnchor),
            clock.heightAnchor.constraint(equalToConstant: 100),
            clock.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(didTimeChange), userInfo: nil, repeats: true)
    }
    
    func configureItems() {
        itemsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            itemsView.topAnchor.constraint(equalTo: clock.bottomAnchor),
            itemsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            itemsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func addKeyboardDismissGesture() {
        dismissTap = UITapGestureRecognizer(target: self, action: #selector(didDismiss))
        view.addGestureRecognizer(dismissTap)
    }
    
    @objc func didTimeChange() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE — MMM d — h:mm a"
        clock.text = dateFormatter.string(from: Date())
    }
    
    @objc func didDismiss() {
        view.endEditing(true)
    }
    
    func didSubmitOccur() {
//        CoreDataManager.shared.deleteAllEntries()
        CoreDataManager.shared.createEntry(time: Date(), fields: items)
//        guard let entries = CoreDataManager.shared.fetchEntries() else { return }
    }
    
    func didChangeValue<T>(value: T, position: Int) {
        items[position].value = value
        print(items[position].value)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item >= items.count {
            let cell = itemsView.dequeueReusableCell(withReuseIdentifier: SubmitCell.identifier, for: indexPath) as! SubmitCell
            cell.delegate = self
            cell.contentView.layer.cornerRadius = 10
            return cell
        }
        
        let item = items[indexPath.item]
        if item.config.type == .slider {
            let sliderConfig = item.config as! NumberConfiguration
            let cell = itemsView.dequeueReusableCell(withReuseIdentifier: SliderCell.identifier, for: indexPath) as! SliderCell
            cell.delegate = self
            cell.position = indexPath.item
            cell.contentView.layer.cornerRadius = 10
            cell.itemLabel.text = sliderConfig.label
            if(!cell.initialized) {
                cell.valueSlider.minimumValue = sliderConfig.minValue
                cell.valueSlider.maximumValue = sliderConfig.maxValue
                cell.valueSlider.value = item.value as! Float
                cell.initialized = true
            }
            return cell
        }
        else if item.config.type == .number {
            let numberConfig = item.config as! NumberConfiguration
            let cell = itemsView.dequeueReusableCell(withReuseIdentifier: NumberCell.identifier, for: indexPath) as! NumberCell
            cell.delegate = self
            cell.position = indexPath.item
            cell.contentView.layer.cornerRadius = 10
            cell.itemLabel.text = numberConfig.label
            if(!cell.initialized) {
                cell.valueStepper.minimumValue = Double(numberConfig.minValue)
                cell.valueStepper.maximumValue = Double(numberConfig.maxValue)
                cell.value = item.value as! Int
                cell.valueStepper.value = Double(cell.value)
                cell.valueTextField.text = String(cell.value)
                cell.initialized = true
            }
            return cell
        }
        else if item.config.type == .binary {
            let cell = itemsView.dequeueReusableCell(withReuseIdentifier: BinaryCell.identifier, for: indexPath) as! BinaryCell
            cell.delegate = self
            cell.position = indexPath.item
            cell.contentView.layer.cornerRadius = 10
            cell.itemLabel.text = item.config.label
            if(!cell.initialized) {
                cell.value = item.value as! Bool
                cell.initialized = true
            }
            return cell
        }
        else if item.config.type == .select {
            let selectConfig = item.config as! SelectConfiguration
            let cell = itemsView.dequeueReusableCell(withReuseIdentifier: SelectCell.identifier, for: indexPath) as! SelectCell
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
        }
        let cell = itemsView.dequeueReusableCell(withReuseIdentifier: SubmitCell.identifier, for: indexPath) as! SubmitCell
        cell.delegate = self
        cell.contentView.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item >= items.count { return CGSize(width: 200, height: 75) }
        
        let item = items[indexPath.item]
        
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

