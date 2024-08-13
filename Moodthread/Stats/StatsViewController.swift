//
//  StatsViewController.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import UIKit
import SwiftUI

class StatsViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    var statsManager: StatsManager = StatsManager(entries: [])
    var currentMonth = Calendar.current.dateComponents([.day, .month, .year], from: Date()) {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            monthSelector.setTitle(dateFormatter.string(from: Calendar.current.date(from: currentMonth) ?? Date()), for: .normal)
            self.refreshEntries()
        }
    }
    var compareController: UIHostingController<LineChartView>? = nil
    
    var pickerController: UIViewController = {
        let controller = UIViewController()
        let popoverSize = CGSize(width: 400, height: 300)
//        controller.view = monthPicker
        controller.preferredContentSize = popoverSize
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.permittedArrowDirections = .up
        return controller
    }()

    var monthSelector: UIButton = {
        let button = UIButton()
        
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.setImage(UIImage(systemName: "arrowtriangle.down.circle"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.sizeToFit()
        button.showsMenuAsPrimaryAction = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        button.setTitle(dateFormatter.string(from: Date()), for: .normal)
        
        button.addTarget(self, action: #selector(didTapMonthSelector(_:)), for: .touchUpInside)
        
        return button
    }()
    
    var monthPicker: MonthYearWheelPicker = {
        let picker = MonthYearWheelPicker()
    
        picker.backgroundColor = .darkGray
        
        return picker
    }()
    
    var chartStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillProportionally
//        stack.layoutMargins = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        return stack
    }()
    
    var chartScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Statistics"
        
        monthPicker.onDateSelected = didPickDate
        pickerController.popoverPresentationController?.delegate = self
        pickerController.popoverPresentationController?.sourceView = monthSelector
        pickerController.popoverPresentationController?.sourceRect = monthSelector.bounds
        pickerController.view = monthPicker
        
        addSubviews()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshEntries()
    }
    
    func addSubviews() {
        view.addSubview(monthSelector)
        view.addSubview(chartScrollView)
        chartScrollView.addSubview(chartStack)
        refreshCharts()
    }

    func configureUI() {
        configureMonthSelector()
        configureChartScrollView()
        configureChartStack()
    }
    
    func configureMonthSelector() {
        monthSelector.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            monthSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.TOP_MARGIN),
            monthSelector.heightAnchor.constraint(equalToConstant: 20),
            monthSelector.widthAnchor.constraint(equalTo: view.widthAnchor, constant: Constants.WIDTH_MARGIN)
        ])
    }
    
    func configureMonthPicker() {
        monthPicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            monthPicker.topAnchor.constraint(equalTo: monthSelector.bottomAnchor, constant: Constants.TOP_MARGIN),
            monthPicker.heightAnchor.constraint(equalToConstant: 300),
            monthPicker.widthAnchor.constraint(equalTo: view.widthAnchor, constant: Constants.WIDTH_MARGIN * 2)
        ])
    }
    
    func configureChartScrollView() {
        chartScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chartScrollView.topAnchor.constraint(equalTo: monthSelector.bottomAnchor, constant: Constants.TOP_MARGIN),
            chartScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            chartScrollView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: Constants.WIDTH_MARGIN)
        ])
    }
    
    func configureChartStack() {
        chartStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartStack.topAnchor.constraint(equalTo: chartScrollView.topAnchor),
            chartStack.bottomAnchor.constraint(equalTo: chartScrollView.bottomAnchor),
            chartStack.trailingAnchor.constraint(equalTo: chartScrollView.trailingAnchor),
            chartStack.leadingAnchor.constraint(equalTo: chartScrollView.leadingAnchor),
            chartStack.widthAnchor.constraint(equalTo: chartScrollView.widthAnchor)
        ])
    }
    
    @objc func didTapMonthSelector(_ sender: UIButton) {
        pickerController.popoverPresentationController?.sourceView = monthSelector
        pickerController.popoverPresentationController?.sourceRect = monthSelector.bounds
        pickerController.view = monthPicker
        if(!isModal(pickerController)) {
            self.present(pickerController, animated: true)
        }
    }
    
    func didPickDate(month: Int, year: Int) {
        currentMonth = DateComponents(calendar: Calendar.current, year: year, month: month)
    }
    
    func refreshEntries() {
        let fetched = DataManager.shared.fetchEntries()
        
        statsManager = StatsManager(entries: fetched, dates: getDateComponents())
        
        monthPicker.maximumDate = fetched.first?.time ?? Date()
        monthPicker.minimumDate = fetched.last?.time ?? Date()
        
        refreshCharts()
    }
    
    func refreshCharts() {
        chartStack.subviews.forEach {
            chartStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        if(statsManager.data.count == 0) {
            let emptyLabel = UILabel()
            if let descriptor = emptyLabel.font.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits([.traitItalic])) {
                emptyLabel.font = UIFont(descriptor: descriptor, size: 18)
            }
            emptyLabel.text = "No data for this period of time."
            emptyLabel.textColor = .gray
            emptyLabel.textAlignment = .center
            chartStack.addArrangedSubview(emptyLabel)
            return
        }
        
        let options = statsManager.getStatsOptions()
        
        let moodController = UIHostingController(rootView: LineChartView(statsManager: statsManager, fixedField: "Mood"))
        moodController.sizingOptions = .intrinsicContentSize
        chartStack.addArrangedSubview(moodController.view)
        
        let energyController = UIHostingController(rootView: LineChartView(statsManager: statsManager, fixedField: "Energy"))
        energyController.sizingOptions = .intrinsicContentSize
        chartStack.addArrangedSubview(energyController.view)
        
        var visitedBool: [String] = []
        options.forEach { option in
            if(!StatsManager.booleanStats.contains(option.1)) { return }
            if(visitedBool.contains(option.0)) { return }
            visitedBool.append(option.0)
            
            let boolController = UIHostingController(rootView: HorizontalBarView(statsManager: statsManager, field: option.0))
            boolController.sizingOptions = .intrinsicContentSize
            chartStack.addArrangedSubview(boolController.view)
        }
        
        compareController = UIHostingController(rootView: LineChartView(statsManager: statsManager))
        compareController?.sizingOptions = .intrinsicContentSize
        chartStack.addArrangedSubview(compareController?.view ?? UIView())
        
        chartStack.subviews.forEach {
            $0.layer.cornerRadius = 10
        }
    }
    
    func getDateComponents() -> [DateComponents] {
        let shownMonth = currentMonth
        var dateComponents: [DateComponents] = []
        for i in 1...31 {
            var copy = shownMonth
            copy.day = i
            if(copy.isValidDate(in: Calendar.current)) { dateComponents.append(copy) }
        }
        return dateComponents
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func isModal(_ vc: UIViewController) -> Bool {
        return vc.presentingViewController?.presentedViewController == vc
            || (vc.navigationController != nil && vc.navigationController?.presentingViewController?.presentedViewController == vc.navigationController)
            || vc.tabBarController?.presentingViewController is UITabBarController
    }
}

