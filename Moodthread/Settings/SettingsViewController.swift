//
//  SettingsViewController.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import UIKit

class SettingsViewController: SettingsTableViewController, UITableViewDataSource {
    
    let headers = [0: "General", 1: "Appearance"]
    var dataSource = [["Customize Fields", "Daily Reminders"]]
    
    init() {
        super.init(labels: headers)
        configureTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .black
        cell.textLabel?.text = dataSource[indexPath.section][indexPath.item]
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tapped = dataSource[indexPath.section][indexPath.item]
        if tapped == "Customize Fields" {
            self.navigationController?.pushViewController(CustomFieldViewController(), animated: false)
        }
        if tapped == "Daily Reminders" {
            self.navigationController?.pushViewController(RemindersViewController(), animated: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
}

