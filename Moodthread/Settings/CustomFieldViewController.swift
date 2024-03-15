//
//  CustomFieldViewController.swift
//  Moodthread
//
//  Created by AC on 1/26/24.
//

import UIKit

class CustomFieldViewController: SettingsTableViewController, UITableViewDataSource, CustomFieldCellDelegate, ActionCellDelegate {

    var dataSource: [ItemConfiguration] = []
    
    init() {
        super.init(labels: [:])
        dataSource = DataManager.shared.getCustomFields()
        tableView.reloadData()
        configureTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Customize Fields"
    }
    
    func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomFieldCell.self, forCellReuseIdentifier: CustomFieldCell.identifier)
        tableView.register(ActionCell.self, forCellReuseIdentifier: ActionCell.identifier)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section >= dataSource.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier, for: indexPath) as! ActionCell
            cell.delegate = self
            if(indexPath.section == dataSource.count) { cell.action = "Add" }
            else { cell.action = "Save" }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomFieldCell.identifier, for: indexPath) as! CustomFieldCell
        let config = dataSource[indexPath.section]
        
        cell.position = indexPath.section
        if let config = config as? NumberConfiguration {
            cell.config = config
            cell.extras = [config.minValue, config.maxValue]
        }
        else {
            cell.config = config
        }
        cell.delegate = self
        cell.refreshData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count + 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func didUpdate(config: ItemConfiguration?, position: Int) {
        if let config = config {
            self.dataSource[position] = config
        }
        else {
            didDeleteOccur(position: position)
        }
    }
    
    func didPerformAction(action: String) {
        switch(action) {
        case "Add":
            didAddOccur()
        case "Save":
            didSubmitOccur()
        default:
            return
        }
    }
    
    func saveFields() {
        let configsArray = dataSource.compactMap { $0.stringify() }

        let userDefaults = UserDefaults.standard
//        userDefaults.removeObject(forKey: Constants.CUSTOM_FIELDS_KEY)
        userDefaults.set(configsArray, forKey: Constants.CUSTOM_FIELDS_KEY)
    }
    
    func didAddOccur() {
        dataSource.append(ItemConfiguration(label: "[Enter Label]", type: .slider))
        tableView.reloadData()
    }
    
    func didSubmitOccur() {
        saveFields()
    }
    
    func didDeleteOccur(position: Int) {
        let alert = UIAlertController(
            title: "Confirm deletion",
            message: "This will delete this field.  Do you wish to proceed?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { _ in
                self.dataSource.remove(at: position)
                self.tableView.reloadData()
                self.saveFields()
        }))
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { _ in
            // cancel action
        }))
        present(alert,
                animated: true,
                completion: nil
        )
    }
}

