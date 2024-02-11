//
//  SliderCell.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import UIKit

class SliderCell: UICollectionViewCell, FieldCell {
    
    static let identifier = "slider"
    weak var delegate: FieldCellDelegate?
    var position = -1
    
    typealias T = Float
    var type: Type = .slider
    var label: String = ""
    var value: Float = 0
    var initialized: Bool = false
    
    lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.text = "Blank"
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    lazy var valueSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValueImage = UIImage(systemName: "minus")
        slider.maximumValueImage = UIImage(systemName: "plus")
        slider.tintColor = Appearance().tintColor
        
        slider.addTarget(self, action: #selector(didValueChange), for: UIControl.Event.valueChanged)
        return slider
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
        contentView.addSubview(valueSlider)
        contentView.addSubview(itemLabel)
    }
    
    func configureUI() {
        configureLabel()
        configureSlider()
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
    
    func configureSlider() {
        valueSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            valueSlider.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            valueSlider.heightAnchor.constraint(equalToConstant: 50),
            valueSlider.widthAnchor.constraint(equalTo: widthAnchor, constant: -40)
        ])
    }
    
    @objc func didValueChange() {
        value = valueSlider.value
        delegate?.didChangeValue(value: value, position: position)
    }
}

