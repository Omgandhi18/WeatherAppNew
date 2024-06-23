//
//  SettingsVC.swift
//  WeatherApp
//
//  Created by Om Gandhi on 23/06/2024.
//

import UIKit
class SettingsVC: UIViewController {

    @IBOutlet weak var switchTempUnit: UISwitch!
    @IBOutlet weak var lblTopBar: UILabel!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var switchWind: UISwitch!
    
    var completion: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblTopBar.layer.cornerRadius = lblTopBar.frame.size.height/2
        lblTopBar.layer.masksToBounds = true
        
        let settingsDict = UserDefaults.standard.value(forKey: "settingsDict") as? [String:String] ?? [:]
        if settingsDict["tempUnit"] == "C"{
            switchTempUnit.isOn = false
        }
        else{
            switchTempUnit.isOn = true
        }
        if settingsDict["windUnit"] == "KM"{
            switchWind.isOn = false
        }
        else{
            switchWind.isOn = true
        }
        
    }
    override func viewDidLayoutSubviews() {
       
    }
    

    @IBAction func switchTempUnit(_ sender: UISwitch) {
        var dictionary = UserDefaults.standard.value(forKey: "settingsDict") as? [String:String]
        if sender.isOn{
            dictionary?["tempUnit"] = "F"
        }
        else{
            dictionary?["tempUnit"] = "C"
        }
        UserDefaults.standard.setValue(dictionary, forKey: "settingsDict")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func switchWindSpeed(_ sender: UISwitch) {
        var dictionary = UserDefaults.standard.value(forKey: "settingsDict") as? [String:String]
        if sender.isOn{
            dictionary?["windUnit"] = "MI"
        }
        else{
            dictionary?["windUnit"] = "KM"
        }
        UserDefaults.standard.setValue(dictionary, forKey: "settingsDict")
        UserDefaults.standard.synchronize()
    }
    @IBAction func dismissBtn(_ sender: Any) {
        dismiss(animated: true){
            if let completion = self.completion{
              completion()
            }
        }
    }
}
