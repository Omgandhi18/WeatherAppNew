//
//  MyTabController.swift
//  WeatherApp
//
//  Created by Athulya Tech on 7/19/23.
//

import UIKit

class MyTabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        self.tabBar.isTranslucent = true
        if self.traitCollection.userInterfaceStyle == .light {
                    // User Interface is Light
            self.tabBar.backgroundColor = .whiteTransparent
            self.tabBar.tintColor = .black
            self.tabBar.unselectedItemTintColor = .darkGray
            print("App switched to light mode")
                } else {
                    // User Interface is Dark
                    self.tabBar.backgroundColor = .transparent
                    self.tabBar.tintColor = .white
                    self.tabBar.unselectedItemTintColor = .gray
                    print("App switched to dark mode")
                    
                }
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                if self.traitCollection.userInterfaceStyle == .light {
                    // Code to execute in light mode
                    self.tabBar.backgroundColor = .whiteTransparent
                    self.tabBar.tintColor = .black
                    self.tabBar.unselectedItemTintColor = .darkGray
                    print("App switched to light mode")
                } else {
                    // Code to execute in dark mode
                    self.tabBar.backgroundColor = .transparent
                    self.tabBar.tintColor = .white
                    self.tabBar.unselectedItemTintColor = .gray
                    print("App switched to dark mode")
                }
            })
        } else {
            self.tabBar.backgroundColor = .transparent
        }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
