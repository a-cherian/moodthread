//
//  RemindersViewController.swift
//  Moodthread
//
//  Created by AC on 8/2/24.
//

import UIKit

//class Time {
//    var hour = 0
//    var minute = 0
//    var am = true
//    
//    init(h: Int, m: Int, am: Bool) {
//        hour = h
//        minute = m
//        self.am = am
//    }
//}

class RemindersViewController: SettingsTableViewController, UITableViewDataSource, ActionCellDelegate, ReminderCellDelegate {

    var dataSource: [Date] = [] {
        didSet {
            didChangeOccur()
        }
    }
    var hasNotificationPermission = false
    
    init() {
        super.init(labels: [:])
        dataSource = DataManager.shared.getNotifications()
        tableView.reloadData()
        configureTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Daily Reminders"
    }
    
    func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ReminderCell.self, forCellReuseIdentifier: ReminderCell.identifier)
        tableView.register(ActionCell.self, forCellReuseIdentifier: ActionCell.identifier)
        
        tableView.rowHeight = UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section >= dataSource.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier, for: indexPath) as! ActionCell
            cell.delegate = self
            if(indexPath.section == dataSource.count) { cell.action = "Add" }
            else { cell.action = "Save" }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.identifier, for: indexPath) as! ReminderCell
        
        cell.position = indexPath.section
        cell.timePicker.date = dataSource[indexPath.section]
        
        cell.delegate = self
//        cell.refreshData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    
    func didChangeTime(time: Date, position: Int) {
        dataSource[position] = time
    }
    
    func didTapDelete(position: Int) {
        let alert = UIAlertController(
            title: "Confirm deletion",
            message: "This will delete this reminder.  Do you wish to proceed?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { _ in
                self.dataSource.remove(at: position)
                self.tableView.reloadData()
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
    
    func didPerformAction(action: String) -> Bool {
        switch(action) {
        case "Add":
            didAddOccur()
            return true
//        case "Save":
//            return didSubmitOccur()
        default:
            return true
        }
    }
    
    func didAddOccur() {
        dataSource.append(Date.now)
        tableView.reloadData()
    }
    
    func didChangeOccur() {
        DataManager.shared.saveNotifications(dates: dataSource)
        tryToDispatchNotifications()
    }
    
    func tryToDispatchNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings {settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotifications()
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert], completionHandler: { didAllow, error in
                    if didAllow {
                        self.dispatchNotifications()
                    }
                })
            default:
                let alert = UIAlertController(
                    title: "Notifications permissions not enabled",
                    message: "Moodthread does not have permissions to send notifications. If you would like to use reminders, please give Moodthread permission to send notifications in your device settings.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: { _ in
                    // cancel action
                }))
                self.present(alert,
                        animated: true,
                        completion: nil
                )
            }
        }
    }
    
    func dispatchNotifications() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = .gmt
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to track your mood!"
        content.body = "Don't forget to log your mood on Moodthread."
        
        dataSource.forEach { date in
            let identifier = dateFormatter.string(from: date)
            
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            notificationCenter.add(request)
        }
    }
}

