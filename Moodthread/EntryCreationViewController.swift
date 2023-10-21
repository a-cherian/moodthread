//
//  ViewController.swift
//  Moodthread
//
//  Created by AC on 10/6/23.
//

import UIKit

class EntryCreationViewController: UIViewController {
    
    let items: [any ItemHolder & UIView] = [SliderItemView(label: "Mood", min: 1, max: 5), SliderItemView(label: "Energy", min: 1, max: 5)]
    
    lazy var clock: UILabel = {
        let label = UILabel()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE — MMM d — h:mm a"
        label.text = dateFormatter.string(from: Date())
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviews()
        configureUI()
    }
    
    func addSubviews() {
        view.addSubview(clock)
        items.forEach { item in
            view.addSubview(item)
        }
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
        var previous: UIView = clock
        items.forEach { item in
            item.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                item.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                item.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20),
                item.heightAnchor.constraint(equalToConstant: 120),
                item.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20)
            ])
            
            item.initialize()
            previous = item
        }
    }
    
    @objc func didTimeChange() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE — MMM d — h:mm a"
        clock.text = dateFormatter.string(from: Date())
    }
}

