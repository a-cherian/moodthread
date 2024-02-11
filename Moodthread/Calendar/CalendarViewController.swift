//
//  CalendarViewController.swift
//  Moodthread
//
//  Created by AC on 10/6/23.
//

import UIKit

class CalendarViewController: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var statsManager: StatsManager = StatsManager(entries: [])
    var currentOption: (String, String) = ("Mood", "Average") {
        didSet {
            fieldSelector.setTitle(currentOption.0 + " • " + currentOption.1, for: .normal)
            refreshCalendar()
        }
    }
    
    var fieldSelector: UIButton = {
        let button = UIButton()
        
        button.tintColor = .black
        button.setTitle("Mood • Average", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.setImage(UIImage(systemName: "arrowtriangle.down.circle"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.sizeToFit()
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    var calendarView: UICalendarView = {
        let calendar = UICalendarView()
        
        calendar.calendar = Calendar(identifier: .gregorian)
        calendar.backgroundColor = .black
        calendar.layer.cornerCurve = .continuous
        calendar.layer.cornerRadius = 10
        
        return calendar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Calendar"
        
        refreshEntries()
        addSubviews()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshEntries()
    }
    
    func addSubviews() {
        view.addSubview(fieldSelector)
        view.addSubview(calendarView)
    }

    func configureUI() {
        configureFieldSelector()
        configureCalendar()
    }
    
    func configureFieldSelector() {
        fieldSelector.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fieldSelector.centerXAnchor.constraint(equalTo: calendarView.centerXAnchor),
            fieldSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.TOP_LABEL_MARGIN),
            fieldSelector.heightAnchor.constraint(equalToConstant: 20),
            fieldSelector.widthAnchor.constraint(equalTo: calendarView.widthAnchor)
        ])
    }
    
    func configureCalendar() {
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        calendarView.delegate = self
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            calendarView.topAnchor.constraint(equalTo: fieldSelector.bottomAnchor, constant: Constants.TOP_LABEL_MARGIN),
            calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            calendarView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50)
        ])
    }
    
    func refreshEntries() {
        let fetched = (DataManager.shared.fetchEntries() ?? []).sorted(by: { $0.time ?? Date() > $1.time ?? Date() })
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        let dateComponents = getDateComponents()
        let visibleDates: Dictionary<String, DateComponents> = dateComponents.reduce(into: [String:DateComponents]()) {
            $0[dateFormatter.string(from: Calendar.current.date(from: $1) ?? Date())] = $1
        }
        let filteredEntries = fetched.filter { visibleDates[dateFormatter.string(from: $0.time ?? Date())] != nil }
        
        statsManager = StatsManager(entries: filteredEntries)
        
        var actionItems: [UIAction] = []
        let options = statsManager.getStatsOptions()
        options.forEach { option in
            let item = UIAction(title: option.0 + " • " + option.1) { (action) in
                self.currentOption = option
            }
            actionItems.append(item)
        }
        

        fieldSelector.menu = UIMenu(title: "", options: .displayInline, children: actionItems)
        
        refreshCalendar()
    }
    
    func getColor(values: (v: Float, min: Float, max: Float)?) -> UIColor {
        guard let values = values else { return .gray }
        
        let range = values.max - values.min
        
        switch (values.v) {
        case values.min..<(values.min + range/3):
            return .red
        case (values.min + range/3)..<(values.min + range * 2/3):
            return .yellow
        case (values.min + range * 2/3)...values.max:
            return .green
        default:
            return .gray
        }
    }
    
    func refreshCalendar() {
        self.calendarView.reloadDecorations(forDateComponents: getDateComponents(), animated: false)
    }
    
    func getDateComponents() -> [DateComponents] {
        let shownMonth = self.calendarView.visibleDateComponents
        var dateComponents: [DateComponents] = []
        for i in 1...31 {
            var copy = shownMonth
            copy.day = i
            if(copy.isValidDate(in: self.calendarView.calendar)) { dateComponents.append(copy) }
        }
        return dateComponents
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let dayEntries: [Entry] = statsManager.data[[dateComponents.year ?? 0, dateComponents.month ?? 0, dateComponents.day ?? 0]] ?? []
        if dayEntries.count == 0 { return .default() }
        
        let tintColor = Appearance().tintColor
        
        switch(currentOption.1) {
        case "Average", "Highest", "Lowest":
            guard let values = statsManager.getNumberStats(date: dateComponents, for: currentOption) else { return .default() }
            let icons = Appearance.getIcons(values: values)
            var icon = icons[2]
            
            if(currentOption.0 == "Mood") { icon = icons[0] }
            else if(currentOption.0 == "Energy") { icon = icons[1] }
            else if(icon == nil) { return .default(color: tintColor) }
            else { return formatTextDecoration(value: values.v) }
            
            return formatIconDecoration(icon: icon, color: self.getColor(values: values))
        case "Recorded":
            let value = statsManager.getBooleanStats(date: dateComponents, for: currentOption)
            if !value { return .default(color: tintColor) }
            return formatIconDecoration(icon: UIImage(systemName: "doc.text"), color: tintColor)
        case "Always True", "Once True":
            let value = statsManager.getBooleanStats(date: dateComponents, for: currentOption)
            return formatIconDecoration(icon: value ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark"), color: value ? .green : .red)
        default:
            return .default(color: tintColor)
        }
    }
    
    func formatTextDecoration(value: Float) -> UICalendarView.Decoration {
        return .customView {
            let view = UIView()
            let label = UILabel()
            
            label.text = value.formatted(FloatingPointFormatStyle())
            label.textColor = Appearance().tintColor
            label.textAlignment = .center
            
            view.addSubview(label)
            
            return label
        }
    }
    
    func formatIconDecoration(icon: UIImage?, color: UIColor) -> UICalendarView.Decoration {
        return .customView {
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
            
            let imageView = UIImageView()
            imageView.image = icon
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = color
            
            view.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                imageView.heightAnchor.constraint(equalTo: view.heightAnchor),
                imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ])
            
            return view
        }
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents else { return }
        
        let dayEntries: [Entry] = statsManager.data[[dateComponents.year ?? 0, dateComponents.month ?? 0, dateComponents.day ?? 0]] ?? []
        
        if(dayEntries.count != 0) { self.navigationController?.pushViewController(EntryListViewController(entries: dayEntries), animated: true) }
        
        selection.selectedDate = nil
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        refreshEntries()
        
        if(!statsManager.getStatsOptions().contains(where: { $0.0 == currentOption.0 && $0.1 == currentOption.1 })) {
            currentOption = ("Mood", "Average")
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return statsManager.getStatsOptions().count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statsManager.getStatsOptions().count
    }
}

