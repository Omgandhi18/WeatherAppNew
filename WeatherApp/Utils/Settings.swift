//
//  Settings.swift
//  WeatherApp
//
//  Created by Athulya Tech on 7/18/23.
//


import UIKit
import SVProgressHUD

class Settings: NSObject {
    func showProgress()
    {
        
        SVProgressHUD.setBackgroundColor(UIColor(named: "transparent")!)
        SVProgressHUD.setForegroundColor(UIColor(named: "BlueColor")!)
        SVProgressHUD.setRingThickness(3.0)
        SVProgressHUD.show()
        SVProgressHUD .setDefaultMaskType(SVProgressHUDMaskType.black)
    }

    func showProgressWithStatus(_ status: String)
    {
        SVProgressHUD.setBackgroundColor(UIColor(named: "transparent")!)
        SVProgressHUD.setForegroundColor(UIColor(named: "BlueColor")!)
        SVProgressHUD.setRingThickness(3.0)
        SVProgressHUD.show(withStatus: status)
        SVProgressHUD .setDefaultMaskType(SVProgressHUDMaskType.black)
    }

    func dismissProgress()
    {
        SVProgressHUD.dismiss()
    }
}
