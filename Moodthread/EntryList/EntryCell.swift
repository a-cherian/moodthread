//
//  EntryCell.swift
//  Moodthread
//
//  Created by AC on 11/15/23.
//

import UIKit

class EntryCell: UICollectionViewCell {
    
    static let identifier = "entry"
    var position = -1
    var initialized: Bool = false
    
    lazy var date: UILabel = {
        let label = UILabel()
        label.text = "Blank"
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    lazy var moodIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "fi-sr-neutral"))
        imageView.tintColor = .white
        return imageView
    }()
    
    lazy var energyIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "fi-sr-battery-half"))
        imageView.tintColor = .white
        return imageView
    }()
    
    lazy var arrowButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = Appearance().tintColor
        
        return button
    }()
    
    lazy var dividerView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "square.fill"))
        imageView.tintColor = .white
        return imageView
    }()
    
    lazy var summary: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 5
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .black
        
        addSubviews()
        configureUI(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(date)
        contentView.addSubview(moodIconView)
        contentView.addSubview(energyIconView)
        contentView.addSubview(arrowButton)
        contentView.addSubview(dividerView)
        contentView.addSubview(summary)
    }
    
    func configureUI(frame: CGRect) {
        configureLabel()
        configureMoodIcon()
        configureEnergyIcon()
        configureArrow()
        configureDivider()
        configureSummary()
    }
    
    func configureLabel() {
        date.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            date.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            date.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            date.heightAnchor.constraint(equalToConstant: 25),
            date.widthAnchor.constraint(equalTo: widthAnchor, constant: -40)
        ])
    }
    
    func configureMoodIcon() {
        moodIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moodIconView.trailingAnchor.constraint(equalTo: energyIconView.leadingAnchor, constant: -20),
            moodIconView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            moodIconView.heightAnchor.constraint(equalToConstant: 30),
            moodIconView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configureEnergyIcon() {
        energyIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            energyIconView.trailingAnchor.constraint(equalTo: dividerView.leadingAnchor, constant: -15),
            energyIconView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            energyIconView.heightAnchor.constraint(equalToConstant: 30),
            energyIconView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configureArrow() {
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arrowButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            arrowButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            arrowButton.heightAnchor.constraint(equalToConstant: frame.height),
            arrowButton.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configureDivider() {
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dividerView.trailingAnchor.constraint(equalTo: arrowButton.leadingAnchor),
            dividerView.topAnchor.constraint(equalTo: topAnchor),
            dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dividerView.widthAnchor.constraint(equalToConstant: 3)
        ])
    }
    
    func configureSummary() {
        summary.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            summary.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            summary.trailingAnchor.constraint(equalTo: dividerView.leadingAnchor, constant: -15),
            summary.topAnchor.constraint(equalTo: moodIconView.bottomAnchor, constant: 5),
            summary.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func setIcons(icons: [UIImage?], colors: [UIColor]) {
        moodIconView.image = icons[0]
        moodIconView.tintColor = colors[0]
        
        energyIconView.image = icons[1]
        energyIconView.tintColor = colors[1]
    }
    
//    func setSummary(fields: [Field]) {
    func setSummary(text: String) {
//        if text == "" {
//            summary.removeFromSuperview()
//            summary.text = ""
//            return
//        }
        
        summary.numberOfLines =  text.filter{ $0 == "\n" }.count + 1
        summary.text = text
    }
}

