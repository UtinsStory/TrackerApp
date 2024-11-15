//
//  TabBarController.swift
//  TrackerApp
//
//  Created by Гена Утин on 04.10.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerVC = TrackerViewController()
        let statisticsVC = StatisticsViewController()
        
        trackerVC.tabBarItem = UITabBarItem(title: LocalizationHelper.localizedString("trackers"),
                                            image: UIImage(named: "trackers_tabbar"),
                                            selectedImage: nil)
        
        statisticsVC.tabBarItem = UITabBarItem(title: LocalizationHelper.localizedString("statistic"),
                                               image: UIImage(named: "stats_tabbar"),
                                               selectedImage: nil)
        
       let trackerNavigationController = UINavigationController(rootViewController: trackerVC)
        
        
        let separatorImage = UIImage()
        self.tabBar.shadowImage = separatorImage
        self.tabBar.backgroundImage = separatorImage
        self.tabBar.layer.borderWidth = 0.50
        self.tabBar.clipsToBounds = true
        
        self.viewControllers = [trackerNavigationController, statisticsVC]
        
    }
}
