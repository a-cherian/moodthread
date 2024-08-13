//
//  SelectCell.swift
//  Moodthread
//
//  Created by AC on 10/31/23.
//

import UIKit

class SelectCell: UICollectionViewCell, FieldCell/*, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout*/ {
    
    static let identifier = "select"
    weak var delegate: FieldCellDelegate?
    var position = -1
    
    typealias T = String
    var type: Type = .select
    var label: String = ""
    var value: String = "" {
        didSet {
//            trueButton.backgroundColor = value ? Appearance.tintColor : .black
//            trueButton.tintColor = value ? .black : .white
//            
//            falseButton.backgroundColor = value ? .black : Appearance.tintColor
//            falseButton.tintColor = value ? .white : .black
        }
    }
    var initialized: Bool = false
    
    var options: [String] = []
    
    lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.text = "Blank"
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
//    lazy var buttonsView: UICollectionView = {
////        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
////        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
//        let layout = UICollectionViewFlowLayout()
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        layout.scrollDirection = .vertical
//        let collection = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
//        collection.backgroundColor = Appearance.tintColor
//        collection.showsVerticalScrollIndicator = true
////        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0);
//        collection.dataSource = self
//        collection.delegate = self
//        collection.register(SelectOptionCell.self, forCellWithReuseIdentifier: SelectOptionCell.identifier)
//        return collection
//    }()
    
    lazy var buttonsView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.backgroundColor = UIColor.orange
        return stack
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
        contentView.addSubview(buttonsView)
    }
    
    func configureUI() {
        configureView()
        configureLabel()
//        configureCollection()
    }
    
    func configureView() {
//        mainView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            mainView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40)
//        ])
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
    
    func configureButton(button: UIButton, title: String) {
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 10
        button.sizeToFit()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
////            button.widthAnchor.constraint(equalTo: buttonsView.widthAnchor, constant: -20),
////            button.heightAnchor.constraint(equalToConstant: 20)
//        ])
    }
    
    func configureCollection() {
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsView.topAnchor.constraint(equalTo: itemLabel.topAnchor, constant: 20),
            buttonsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
//            buttonsView.heightAnchor.constraint(equalToConstant: 200),
//            heightAnchor.constraint(equalToConstant: buttonsView.collectionViewLayout.collectionViewContentSize.height + 100)
        ])
        bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: 20).isActive = true
        
        options.forEach { item in
            let button = UIButton()
            configureButton(button: button, title: item)
            buttonsView.addArrangedSubview(button)
        }
    }
    
    @objc func didTapButton(_ sender: UIButton) {
        value = options[sender.tag]
    }
    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return options.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let item = options[indexPath.item]
//        let cell = buttonsView.dequeueReusableCell(withReuseIdentifier: SliderCell.identifier, for: indexPath) as! SelectOptionCell
//        cell.button.setTitle(item, for: .normal)
//        
//        return cell
//    }
}
