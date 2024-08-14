//
//  EntryListViewController.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import UIKit

class EntryListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var items: [Field] = []
    var cells: [[Any]] = []
    var preset: Bool = false
    
    let ENTRY_INDEX = 0
    let ICON_INDEX = 1
    let COLOR_INDEX = 2
    let TEXT_INDEX = 3
    
    let MOOD = 0
    let ENERGY = 1
    
    var dismissTap = UITapGestureRecognizer()
    
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
    
    init(entries: [Entry]? = nil) {
        super.init(nibName: nil, bundle: nil)
        if let entries = entries {
            entries.forEach { entry in
                cells.append(getEntryCell(entry: entry))
            }
            
            if entries.count == 0 { return }
            let first = entries[0]
            cells.insert([first.time as Any], at: 0)
            
            preset = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Your Moodthread"
        
        refreshEntries()
        addSubviews()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshEntries()
    }
    
    func addSubviews() {
        view.addSubview(entriesView)
    }

    func configureUI() {
        configureEntries()
    }
    
    func configureEntries() {
        entriesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            entriesView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            entriesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            entriesView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            entriesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            entriesView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func refreshEntries() {
        let fetched = DataManager.shared.fetchEntries()
        
        if(fetched.count == 0) {
            cells = [["No entries to display."], [""], ["Add an entry to start tracking"], ["your Moodthread!"]]
            entriesView.reloadData()
            return
        }
        
        if preset {
            fetched.forEach { cell in
                if let match = cells.firstIndex(where: {($0[0] as? Entry)?.objectID == cell.objectID}) {
                    cells[match] = getEntryCell(entry: cell)
                }
            }
            
            entriesView.reloadData()
            return
        }
        
        cells = []

        var i = 0
        while i < fetched.count-1 {
            let first = fetched[i]
            let second = fetched[i + 1]
            cells.append(getEntryCell(entry: first))
            if(!Calendar.current.isDate(first.time ?? Date(), equalTo: second.time ?? Date(), toGranularity: .day)) {
                cells.append([second.time as Any])
            }
            
            i += 1
        }
        
        if fetched.count == 0 { return }
        let first = fetched[0]
        cells.insert([first.time as Any], at: 0)
        let last = fetched[fetched.count - 1]
        cells.append(getEntryCell(entry: last))
        
        entriesView.reloadData()
    }
    
    func getEntryCell(entry: Entry) -> [Any] {
        guard let fields = entry.fields else { return [entry, UIImage(), ""] }
        
        let tuples: [(Float, Float, Float)] = fields.compactMap { (field: Field) -> (Float, Float, Float)? in
            guard let config = field.config as? NumberConfiguration else { return nil }
            if(!["Mood", "Energy"].contains(config.label)) { return nil }
            
            return (field.extractFloat() ?? (config.maxValue + config.minValue) / 2, config.minValue, config.maxValue)
        }
        
        let icons = [Appearance.getIcons(values: tuples[MOOD])[MOOD], Appearance.getIcons(values: tuples[ENERGY])[ENERGY]]
        let colors = [Appearance.getColor(values: tuples[MOOD])[MOOD], Appearance.getColor(values: tuples[ENERGY])[ENERGY]]
        let text = getText(fields: fields)
        
        return [entry, icons, colors, text]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let date = cells[indexPath.item][ENTRY_INDEX] as? Date {
            let cell = entriesView.dequeueReusableCell(withReuseIdentifier: DateCell.identifier, for: indexPath) as! DateCell
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE — MMM d"
            cell.date.text = dateFormatter.string(from: date)
            cell.position = indexPath.item
            cell.contentView.layer.cornerRadius = 10
            
            return cell
        }
        if let entry = cells[indexPath.item][ENTRY_INDEX] as? Entry {
            let cell = entriesView.dequeueReusableCell(withReuseIdentifier: EntryCell.identifier, for: indexPath) as! EntryCell
            guard let images = cells[indexPath.item][ICON_INDEX] as? [UIImage?] else { return cell }
            guard let colors = cells[indexPath.item][COLOR_INDEX] as? [UIColor] else { return cell }
            guard let text = cells[indexPath.item][TEXT_INDEX] as? String else { return cell }
            cell.position = indexPath.item
            cell.contentView.layer.cornerRadius = 10
            cell.arrowButton.tag = cell.position
            cell.arrowButton.addTarget(self, action: #selector(didTapArrowButton(_:)), for: .touchUpInside)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            cell.date.text = dateFormatter.string(from: entry.time ?? Date())

            cell.setIcons(icons: images, colors: colors)
            cell.setSummary(text: text)
            
            return cell
        }
        
        let cell = entriesView.dequeueReusableCell(withReuseIdentifier: DateCell.identifier, for: indexPath) as! DateCell
        cell.date.text = cells[indexPath.item][ENTRY_INDEX] as? String ?? ""

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cells[indexPath.item][ENTRY_INDEX] is String {
            return CGSize(width: view.frame.width - 40, height: 10)
        }
        if cells[indexPath.item][ENTRY_INDEX] is Date {
            return CGSize(width: view.frame.width - 40, height: 50)
        }
        if let entry = cells[indexPath.item][ENTRY_INDEX] as? Entry {
            let summaryFieldCount = entry.fields?.suffix(from: 2).filter({ $0.isSummarizable() && $0.enabled }).count ?? 0
            return CGSize(width: Int(view.frame.width) - 40, height: 70 + (30 * summaryFieldCount))
        }
        return CGSize(width: 0, height: 0)
    }
    
    func getText(fields: [Field]) -> String {
        let customFields = fields.suffix(from: 2)
        
        var text = ""
        customFields.forEach {field in
            if field.isSummarizable() && field.enabled {
                if field.config.type == .binary { text = text + "\u{2022} " + field.config.label + ": " + (field.extractBool() ?? false ? "Yes" : "No") + "\n" }
                else { text = text + "\u{2022} " + field.config.label + ": " + String(field.extractInt() ?? 0) + "\n" }
            }
        }
        text = String(text.dropLast())
        return text
    }
    
    @objc func didTapArrowButton(_ sender: UIButton) {
        guard let entry = cells[sender.tag][ENTRY_INDEX] as? Entry else { return }
        self.navigationController?.pushViewController(EntryCreationViewController(entry: entry), animated: true)
    }
}



