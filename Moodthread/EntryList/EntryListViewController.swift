//
//  EntryListViewController.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import UIKit

class EntryListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var items: [Field] = [Field(config: NumberConfiguration(label: "Mood", type: .slider, min: 0, max: 5), value: Float(3)),
                          Field(config: NumberConfiguration(label: "Energy", type: .slider, min: 0, max: 5), value: Float(3)),
                          Field(config: ItemConfiguration(label: "Toggle", type: .binary), value: false),
                          Field(config: NumberConfiguration(label: "Number", type: .number, min: -5, max: 10000), value: 23)]
    var entries: [[Any]] = []
    
    var dismissTap = UITapGestureRecognizer()
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Entry List"
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    lazy var entriesView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.tintColor = .black
        collection.showsVerticalScrollIndicator = true
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0);
        collection.dataSource = self
        collection.delegate = self
        collection.register(EntryCell.self, forCellWithReuseIdentifier: EntryCell.identifier)
        collection.register(DateCell.self, forCellWithReuseIdentifier: DateCell.identifier)
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        refreshEntries()
        
        addSubviews()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshEntries()
    }
    
    func addSubviews() {
        view.addSubview(label)
        view.addSubview(entriesView)
    }

    func configureUI() {
        configureLabel()
        configureEntries()
    }
    
    func configureLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.heightAnchor.constraint(equalToConstant: 100),
            label.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    func configureEntries() {
        entriesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            entriesView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            entriesView.topAnchor.constraint(equalTo: label.bottomAnchor),
            entriesView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            entriesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            entriesView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func refreshEntries() {
        let fetched = CoreDataManager.shared.fetchEntries() ?? []
        entries = []
        
        var i = 0
        while i < fetched.count-1 {
            // section separators go here
            let first = fetched[i]
            let second = fetched[i + 1]
            entries.append([first, getIcons(fields: first.fields!), getText(fields: first.fields!)])
            if(!Calendar.current.isDate(first.time ?? Date(), equalTo: second.time ?? Date(), toGranularity: .day)) {
                entries.append([second.time as Any])
                i += 1
            }
            
            i += 1
        }
        let first = fetched[0]
        entries.insert([first.time as Any], at: 0)
        entries.append([fetched[fetched.count - 1], getIcons(fields: first.fields!), getText(fields: first.fields!)])
        
        entriesView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let entry = entries[indexPath.item][0] as? Date {
            let cell = entriesView.dequeueReusableCell(withReuseIdentifier: DateCell.identifier, for: indexPath) as! DateCell
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E — MMM d"
            cell.date.text = dateFormatter.string(from: entry)
            cell.position = indexPath.item
            cell.contentView.layer.cornerRadius = 10
            
            return cell
        }
        if let entry = entries[indexPath.item][0] as? Entry {
            let cell = entriesView.dequeueReusableCell(withReuseIdentifier: EntryCell.identifier, for: indexPath) as! EntryCell
            guard let images = entries[indexPath.item][1] as? [UIImage] else { return cell }
            guard let text = entries[indexPath.item][2] as? String else { return cell }
            cell.position = indexPath.item
            cell.contentView.layer.cornerRadius = 10
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            cell.date.text = dateFormatter.string(from: entry.time ?? Date())

            cell.setIcons(icons: images)
            cell.setSummary(text: text)
            
            return cell
        }
        let cell = entriesView.dequeueReusableCell(withReuseIdentifier: DateCell.identifier, for: indexPath) as! DateCell
        print("heyyy")

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if entries[indexPath.item][0] is Date {
            return CGSize(width: view.frame.width - 40, height: 50)
        }
        if let entry = entries[indexPath.item][0] as? Entry {
            let summaryFieldCount = entry.fields!.suffix(from: 2).filter({ $0.isSummarizable() }).count
            return CGSize(width: Int(view.frame.width) - 40, height: 70 + (30 * summaryFieldCount))
        }
        return CGSize(width: 0, height: 0)
    }
    
    func getIcons(fields: [Field]) -> [UIImage] {
        let mood = fields[0].value as! Double
        let energy = fields[1].value as! Double
        
        var images: [UIImage] = []
        
        switch (mood) {
        case 0..<1:
            images.append(UIImage(named: "fi-sr-frown") ?? UIImage())
        case 1..<2:
            images.append(UIImage(named: "fi-sr-face-disappointed") ?? UIImage())
        case 2..<3:
            images.append(UIImage(named: "fi-sr-neutral") ?? UIImage())
        case 3..<4:
            images.append(UIImage(named: "fi-sr-smile-beam") ?? UIImage())
        case 4...5:
            images.append(UIImage(named: "fi-sr-face-awesome") ?? UIImage())
        default:
            images.append(UIImage(named: "fi-sr-neutral") ?? UIImage())
        }
        
        switch (energy) {
        case 0..<1.5:
            images.append(UIImage(named: "fi-sr-battery-quarter") ?? UIImage())
        case 1.5..<3:
            images.append(UIImage(named: "fi-sr-battery-half") ?? UIImage())
        case 3..<4.5:
            images.append(UIImage(named: "fi-sr-battery-three-quarters") ?? UIImage())
        case 4.5..<5:
            images.append(UIImage(named: "fi-sr-battery-full") ?? UIImage())
        default:
            images.append(UIImage(named: "fi-sr-battery-half") ?? UIImage())
        }
        
        return images
    }
    
    func getText(fields: [Field]) -> String {
        let customFields = fields.suffix(from: 2)
        
        var text = ""
        customFields.forEach {field in
            if field.isSummarizable() {
                text = text + "\u{2022} " + field.config.label + ": " + String(field.extractInt()) + "\n"
            }
        }
        text = String(text.dropLast())
        print(text)
        return text
    }
}



