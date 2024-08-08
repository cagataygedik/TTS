//
//  TTSTabBarController.swift
//  TTS
//
//  Created by Celil Çağatay Gedik on 7.08.2024.
//

import UIKit

final class TTSTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    private func configureTabBar() {
        viewControllers = [createAppleViewController(), createMapBoxViewController(), createBarkViewController()]
    }
    
    func createAppleViewController() -> UINavigationController {
        let appleViewController = AppleViewController()
        appleViewController.title = "Apple"
        let tabBarItem = UITabBarItem(title: "Apple", image: UIImage(systemName: "apple.logo"), tag: 0)
        appleViewController.tabBarItem = tabBarItem
        return UINavigationController(rootViewController: appleViewController)
    }
    
    func createMapBoxViewController() -> UINavigationController {
        let mapBoxViewController = MapBoxViewController()
        mapBoxViewController.title = "MapBox"
        let tabBarItem = UITabBarItem(title: "MapBox", image: UIImage(systemName: "map.circle"), tag: 1)
        mapBoxViewController.tabBarItem = tabBarItem
        return UINavigationController(rootViewController: mapBoxViewController)
    }
    
    func createBarkViewController() -> UINavigationController {
        let barkViewController = BarkViewController()
        barkViewController.title = "Bark"
        let tabBarItem = UITabBarItem(title: "Bark", image: UIImage(systemName: "dog.fill"), tag: 1)
        barkViewController.tabBarItem = tabBarItem
        return UINavigationController(rootViewController: barkViewController)
    }
}
