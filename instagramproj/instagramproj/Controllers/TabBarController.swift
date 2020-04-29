//
//  TabBarController.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    private lazy var profileVC: ProfileViewController = {
        let vc = ProfileViewController()
        vc.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 1)
        return vc
    }()
    
    private lazy var feedView: UINavigationController = {
        let vc = ViewController()
        vc.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        return UINavigationController(rootViewController: vc)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [feedView, profileVC]

    }

}
