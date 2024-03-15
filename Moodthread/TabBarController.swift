//
//  TabBarController.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTabs()
        self.selectedIndex = 2
    }
    
    private func configureTabs() {
        let calendar = CalendarViewController()
        calendar.tabBarItem.image = UIImage(systemName: "calendar")
        calendar.tabBarItem.title = "Calendar"
        let calendarNav = UINavigationController(rootViewController: calendar)
        
        let entryList = EntryListViewController()
        entryList.tabBarItem.image = UIImage(systemName: "line.3.horizontal")
        entryList.tabBarItem.title = "Moodthread"
        let entryListNav = UINavigationController(rootViewController: entryList)
        
        let entryCreation = EntryCreationViewController()
        entryCreation.tabBarItem.image = UIImage(systemName: "plus.diamond")
        entryCreation.tabBarItem.title = "Add Entry"
        let entryCreationNav = UINavigationController(rootViewController: entryCreation)
        
        let stats = StatsViewController()
        stats.tabBarItem.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
        stats.tabBarItem.title = "Statistics"
        let statsNav = UINavigationController(rootViewController: stats)
        
//        let settings = SettingsViewController()
        let settings = CustomFieldViewController()
        settings.tabBarItem.image = UIImage(systemName: "gearshape.fill")
        settings.tabBarItem.title = "Customize"
        let settingsNav = UINavigationController(rootViewController: settings)
        
        tabBar.backgroundColor = .black
        
        setViewControllers([calendarNav, entryListNav, entryCreationNav, statsNav, settingsNav], animated: true)
    }
}
