//
//  StartupScreen.swift
//  WeatherApp
//
//  Created by Om Gandhi on 19/12/23.
//

import UIKit
import CoreLocation
import SDWebImage
class StartupScreen: UIViewController,CLLocationManagerDelegate{
    
    @IBOutlet weak var imgView: SDAnimatedImageView!
    
    let locationManager = CLLocationManager()
    var latitude: Double = 0
    var longitude: Double = 0
    var locationEnabled = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.traitCollection.userInterfaceStyle == .dark {
                    // User Interface is Dark
            let animatedLogo = SDAnimatedImage(named: "LogoDark.gif")
            imgView.image = animatedLogo
            }
        else {
                    // User Interface is Light
            let animatedLogo = SDAnimatedImage(named: "Logo.gif")
            imgView.image = animatedLogo
                    
                }
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                if self.traitCollection.userInterfaceStyle == .light {
                    // Code to execute in light mode
                    let animatedLogo = SDAnimatedImage(named: "Logo.gif")
                    self.imgView.image = animatedLogo
                    print("App switched to light mode")
                } else {
                    // Code to execute in dark mode
                    let animatedLogo = SDAnimatedImage(named: "LogoDark.gif")
                    self.imgView.image = animatedLogo
                    print("App switched to dark mode")
                }
            })
        } else {
            
        }
       
        locationManager.requestAlwaysAuthorization()
               // For use when the app is open
               //locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        let group = DispatchGroup()
            group.enter()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationEnabled = true
            }
            else{
                self.locationEnabled = false
            }
            group.leave()
        }
        group.wait()
        if locationEnabled{
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // your code here
                let vc = self.storyboard?.instantiateViewController(identifier: "weatherStory") as! WeatherVC
                if !UserDefaults.contains("settingsDict"){
                    let settingsDict = ["tempUnit":"C","windUnit":"KM"]
                    UserDefaults.standard.setValue(settingsDict, forKey: "settingsDict")
                }
                UIApplication.shared.windows.first?.rootViewController = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
            
        }
        else{
            self.showAlert(message: "Location services not enabled. Can't proceed", inViewController: self, forCancel: "", forOther: "Ok", isSingle: true){btn in
            }
        }
        // Do any additional setup after loading the view.
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          if let location = locations.first {
              latitude = location.coordinate.latitude
              longitude = location.coordinate.longitude
          }
      }
      func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
          if (status == CLAuthorizationStatus.denied){
              showAlert("Access denied",message: "We need your location", inViewController: self, forCancel: "", forOther: "Open settings",isSingle: true){btn in
                  if let url = URL(string: UIApplication.openSettingsURLString){
                                  UIApplication.shared.open(url, options: [:], completionHandler: nil)
                              }
              }
          }
      }
    

}
