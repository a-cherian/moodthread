//
//  SettingsViewController.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import UIKit

class SettingsViewController: SettingsTableViewController, UITableViewDataSource {
    
    let headers = [0: "General", 1: "Appearance"]
    var dataSource = [["Customize Fields", "Theme Color", "Reminders"]]
    
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
        if tapped == "Theme Color" {
            if let scene = (UIApplication.shared.connectedScenes.first as? UIWindowScene), let window = scene.windows.first {
                let current = Constants.themeColors.firstIndex(of: window.tintColor) ?? 0
                if(current == Constants.themeColors.count - 1) { window.tintColor = Constants.themeColors[0] }
                else { window.tintColor = Constants.themeColors[current + 1] }
            }
//            let picker = UIColorPickerViewController()
////            picker.delegate = self
//            self.navigationController?.pushViewController(picker, animated: false)
        }
        if tapped == "Reminders" {
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
}

