//
//  SliderItemView.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import UIKit

class SliderItemView: UIView, ItemHolder {
    typealias T = Float
    var value: Float = 3
    var minValue: Float = 1
    var maxValue: Float = 5
    
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
        slider.tintColor = .cyan
        
        slider.addTarget(self, action: #selector(didSizeChange), for: UIControl.Event.valueChanged)
        return slider
    }()
    
    init(label: String, min: Float, max: Float) {
        super.init(frame: CGRectZero)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
        layer.cornerRadius = 10
        
        self.value = min + max / 2
        minValue = min
        maxValue = max
        
        itemLabel.text = label
        
        addSubviews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() {
        valueSlider.minimumValue = minValue
        valueSlider.maximumValue = maxValue
        valueSlider.value = (minValue + maxValue) / 2
    }
    
    func addSubviews() {
        addSubview(valueSlider)
        addSubview(itemLabel)
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
    
    @objc func didSizeChange() {
        value = valueSlider.value
    }
}

