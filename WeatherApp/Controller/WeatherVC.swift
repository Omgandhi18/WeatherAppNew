//
//  WeatherVC.swift
//  WeatherApp
//
//  Created by Om Gandhi on 21/06/2024.
//

import UIKit
import CoreLocation
import SceneKit

class WeatherVC: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, sendData{
   
    
   
    

    @IBOutlet weak var lblCityCountry: UILabel!
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblConditions: UILabel!
    @IBOutlet weak var lblHighLow: UILabel!
    @IBOutlet weak var weatherIconView: SCNView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var clcWeek: UICollectionView!
    @IBOutlet weak var switchDayWeek: UISwitch!
    @IBOutlet weak var lblWeek: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet weak var lblRainChance: UILabel!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var lblWind: UILabel!
    @IBOutlet weak var imgWindDir: UIImageView!
    @IBOutlet weak var lblWindSpeed: UILabel!
    
    
    var refreshControl = UIRefreshControl()

    let locationManager = CLLocationManager()
    var latitude: Double = 0
    var longitude: Double = 0
    var cityName = ""
    var dayArray = [CurrentConditions]()
    var hourArray = [CurrentConditions]()
    var collectionViewColor = UIColor()
    var settingsDict = ["tempUnit":"C"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.tintColor = UIColor(named: "LightBlueColor")
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        mainScrollView.isScrollEnabled = true
        mainScrollView.alwaysBounceVertical = true
        mainScrollView.refreshControl = refreshControl
        locationManager.requestAlwaysAuthorization()
               // For use when the app is open
               //locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
            }
        }
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture))
        weatherIconView.addGestureRecognizer(pinchRecognizer)
        btnCurrentLocation.isHidden = true
        
        
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
       
    }
    override func viewDidAppear(_ animated: Bool) {
        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String{
            getCity(api_key: apiKey, latitude: self.latitude, longitude: self.longitude)
        }
    }
    
    @objc func getCity(api_key: String,latitude: Double, longitude: Double){
        
        DispatchQueue.main.async {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                            if error != nil {
                                return
                            }else if let country = placemarks?.first?.country,
                                let city = placemarks?.first?.locality {
                                self.lblCityCountry.text = city + ", " + country
                                
                                self.cityName = city
                               
                                self.getWeatherData(api_key: api_key)
                            }
                            else {
//                                self.showToastAlert(strmsg: "Failed to get city data", preferredStyle: .alert)
                                self.cityName = "Cupertino"
                                self.lblCityCountry.text = "Cupertino, United States"
                                self.getWeatherData(api_key: api_key)
                            }
                        }
            )
        }
        
        
      
        
    }
    @objc func getWeatherData(api_key: String){
        let url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(self.cityName)?unitGroup=metric&key=\(api_key)&contentType=json"
            CallService(Model_Name: ResponseModelData.self, URLstr: url,method: HTTPMethodName.GET.rawValue){[self]response in
                responseModel = response
                dayArray = response.days ?? []
                hourArray = response.days?.first?.hours ?? []
                settingsDict = UserDefaults.standard.value(forKey: "settingsDict") as? [String:String] ?? [:]
                
               
                if settingsDict["tempUnit"] == "C"{
                    lblTemperature.text = "\(String(format: "%.0f", round(response.currentConditions?.temp ?? 0.00)))° C"
//                    UIView.transition(with: lblTemperature, duration: 1.0,options: .transitionCrossDissolve, animations:{[weak self] in
//                        self?.
//                    } )
                    let animation:CATransition = CATransition()
                    animation.timingFunction = CAMediaTimingFunction(name:
                        CAMediaTimingFunctionName.easeInEaseOut)
                    animation.type = CATransitionType.push
                    animation.subtype = CATransitionSubtype.fromTop
                    animation.duration = 0.5
                    self.lblTemperature.layer.add(animation, forKey: CATransitionType.push.rawValue)
                    lblHighLow.text = "High: \(String(format: "%.0f", dayArray.first?.tempmax ?? 0))° C, Low: \(String(format: "%.0f", dayArray.first?.tempmin ?? 0))° C"
                }
                else{
                    lblTemperature.text = "\(String(format: "%.0f", round(response.currentConditions?.temp?.celsiusToFahrenheit() ?? 0.00)))° F"
//                    UIView.transition(with: lblTemperature, duration: 1.0,options: .transitionCrossDissolve, animations:{[weak self] in
//                        self?.
//                    } )
                    let animation:CATransition = CATransition()
                    animation.timingFunction = CAMediaTimingFunction(name:
                        CAMediaTimingFunctionName.easeInEaseOut)
                    animation.type = CATransitionType.push
                    animation.subtype = CATransitionSubtype.fromTop
                    animation.duration = 0.5
                    self.lblTemperature.layer.add(animation, forKey: CATransitionType.push.rawValue)
                    lblHighLow.text = "High: \(String(format: "%.0f", dayArray.first?.tempmax?.celsiusToFahrenheit() ?? 0))° F, Low: \(String(format: "%.0f", dayArray.first?.tempmin?.celsiusToFahrenheit() ?? 0))° F"
                }
               
                lblConditions.text = response.currentConditions?.conditions?.rawValue
                lblRainChance.text = "Chance of rain: \(String(format: "%.0f", response.currentConditions?.precipprob ?? 0.00))%"
                let angle = NSNumber(value: (Float(response.currentConditions?.winddir ?? 0.00) / 180.0) * Float.pi)
                imgWindDir.layer.setValue(angle, forKeyPath: "transform.rotation.z")
                if settingsDict["windUnit"] == "KM"{
                    lblWindSpeed.text = "\(response.currentConditions?.windspeed ?? 0.00) km/h"
                }
                else{
                   
                    lblWindSpeed.text = "\(String(format: "%.1f", response.currentConditions?.windspeed?.kmToMiles() ?? 0.00)) mph"
                }
                
                
                setWeatherUI(conditions: response.currentConditions?.conditions ?? .clear)
                
                clcWeek.delegate = self
                clcWeek.dataSource = self
                clcWeek.reloadData()
                
            }OnFail: {[self] err in
                showAlert(message: err, inViewController: self, forCancel: "", forOther: "Ok", isSingle: true){btn in
                    
                }
            }
    }
    func setTintColours(color:UIColor)
    {
        lblTemperature.textColor = color
        lblConditions.textColor = color
        lblHighLow.textColor = color
        lblCityCountry.textColor = color
        lblDay.textColor = color
        lblWeek.textColor = color
        lblRainChance.textColor = color
        lblWind.textColor = color
        imgWindDir.tintColor = color
        lblWindSpeed.textColor = color
        collectionViewColor = color
        btnSearch.tintColor = color
        btnCurrentLocation.tintColor = color
        btnSettings.tintColor = color
    }
    func setWeatherUI(conditions: Conditions){
        switch conditions{
            
        case .clear:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "Clear.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "clearWeather")
            self.view.backgroundColor = UIColor(named: "clearWeather")
            setTintColours(color: .black)
            break
        case .overcast:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "Overcast.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "overcastWeather")
            self.view.backgroundColor = UIColor(named: "overcastWeather")
            setTintColours(color: .white)
            break
        case .partiallyCloudy:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "PartiallyCloudy.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            self.view.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            setTintColours(color: .black)
            break
        case .rainOvercast:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "RainOvercast.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "rainOvercast")
            self.view.backgroundColor = UIColor(named: "rainOvercast")
            setTintColours(color: .white)
            break
        case .snowOvercast:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "SnowOvercast.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "rainOvercast")
            self.view.backgroundColor = UIColor(named: "rainOvercast")
            setTintColours(color: .white)
            break
        case .rainPartiallyCloudy:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "RainPartiallyCloudy.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            self.view.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            setTintColours(color: .black)
            break
        case .snowPartiallyCloudy:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "SnowPartiallyCloudy.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            self.view.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            setTintColours(color: .black)
            break
        case .snowRainPartiallyCloudy:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "SnowRainPartially.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            self.view.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            setTintColours(color: .black)
            break
        case .snowRainOvercast:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "SnowRainOvercast.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "overcastWeather")
            self.view.backgroundColor = UIColor(named: "overcastWeather")
            setTintColours(color: .white)
            break
        case .rain:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "Rain.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "rainWeather")
            self.view.backgroundColor = UIColor(named: "rainWeather")
            setTintColours(color: .white)
            break
        case .snowy:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "Snow.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "snowWeather")
            self.view.backgroundColor = UIColor(named: "snowWeather")
            setTintColours(color: .black)
            break
        case .storm:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "Storm.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "rainWeather")
            self.view.backgroundColor = UIColor(named: "rainWeather")
            setTintColours(color: .white)
            break
        case .windy:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "Windy.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "windyWeather")
            self.view.backgroundColor = UIColor(named: "windyWeather")
            setTintColours(color: .black)
            break
        case .dry:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "Sun.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "dryWeather")
            self.view.backgroundColor = UIColor(named: "dryWeather")
            setTintColours(color: .black)
            break
        case .fog:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "PartiallyCloudy.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "foggyWeather")
            self.view.backgroundColor = UIColor(named: "foggyWeather")
            setTintColours(color: .black)
            break
        case .haze:
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            weatherIconView.scene = SCNScene(named: "Haze.scn")
            self.weatherIconView.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            mainScrollView.backgroundColor = UIColor(named: "foggyWeather")
            self.view.backgroundColor = UIColor(named: "foggyWeather")
            setTintColours(color: .black)
            break
        }
        
    }
    func sendDataToVC(coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String{
            getCity(api_key: apiKey, latitude: self.latitude, longitude: self.longitude)
        }
        btnCurrentLocation.isHidden = false
    }
    @objc func refresh(_ sender: UIRefreshControl){
        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String{
            getCity(api_key: apiKey, latitude: self.latitude, longitude: self.longitude)
        }
        refreshControl.endRefreshing()
    }
    @objc func pinchGesture(_ sender: UIPinchGestureRecognizer) {
          if sender.numberOfTouches == 2 {
              // Disable zoom
              print("zoom attempted")
          }
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
          else{
          }
      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if switchDayWeek.isOn{
            return dayArray.count
        }
        return hourArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as! WeatherCell
        if switchDayWeek.isOn{
            let dayWeather = dayArray[indexPath.row]
            let conditions = dayWeather.conditions ?? .clear
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: dayWeather.datetime ?? "")
            
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "dd/MM"
            let displayedDate = outputDateFormatter.string(from: date ?? Date())
            switch conditions{
                
            case .clear:
                cell.imgWeather.image = UIImage(systemName: "sun.max.fill")
                break
            case .overcast:
                cell.imgWeather.image = UIImage(systemName: "smoke.fill")
                break
            case .partiallyCloudy:
                cell.imgWeather.image = UIImage(systemName: "cloud.sun.fill")
                break
            case .rainOvercast:
                cell.imgWeather.image = UIImage(systemName: "cloud.rain.fill")
                break
            case .snowOvercast:
                cell.imgWeather.image = UIImage(systemName: "cloud.snow.fill")
                break
            case .rainPartiallyCloudy:
                cell.imgWeather.image = UIImage(systemName: "cloud.sun.rain.fill")
                break
            case .snowPartiallyCloudy:
                cell.imgWeather.image = UIImage(systemName: "sun.snow.fill")
                break
            case .snowRainPartiallyCloudy:
                cell.imgWeather.image = UIImage(systemName: "cloud.sun.fillcloud.sun.rain.fill")
                break
            case .snowRainOvercast:
                cell.imgWeather.image = UIImage(systemName: "cloud.snow.fill")
                break
            case .rain:
                cell.imgWeather.image = UIImage(systemName: "cloud.rain.fill")
                break
            case .snowy:
                cell.imgWeather.image = UIImage(systemName: "snowflake")
                break
            case .storm:
                cell.imgWeather.image = UIImage(systemName: "cloud.bolt.fill")
                break
            case .windy:
                cell.imgWeather.image = UIImage(systemName: "wind")
                break
            case .dry:
                cell.imgWeather.image = UIImage(systemName: "sun.max.fill")
                break
            case .fog:
                cell.imgWeather.image = UIImage(systemName: "sun.dust.fill")
                break
            case .haze:
                cell.imgWeather.image = UIImage(systemName: "sun.haze.fill")
                break
            }
            cell.imgWeather.tintColor = collectionViewColor
            cell.lblDate.text = displayedDate
            settingsDict = UserDefaults.standard.value(forKey: "settingsDict") as? [String:String] ?? [:]
            if settingsDict["tempUnit"] == "C"{
                cell.lblMax.text = "\(String(format: "%.0f", dayWeather.feelslikemax ?? 0))° C"
                cell.lblMin.text = "\(String(format: "%.0f", dayWeather.feelslikemin ?? 0))° C"
            }
            else{
                cell.lblMax.text = "\(String(format: "%.0f", dayWeather.feelslikemax?.celsiusToFahrenheit() ?? 0))° F"
                cell.lblMin.text = "\(String(format: "%.0f", dayWeather.feelslikemin?.celsiusToFahrenheit() ?? 0))° F"
            }
            
           
            cell.makeViewBorderWithCurve(radius: 10,bcolor: collectionViewColor,bwidth: 2)
            cell.lblDate.textColor = collectionViewColor
            cell.lblMin.textColor = collectionViewColor
            cell.lblMax.textColor = collectionViewColor
            
            return cell
        }
        else{
            let dayWeather = hourArray[indexPath.row]
            let conditions = dayWeather.conditions ?? .clear
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            let date = dateFormatter.date(from: dayWeather.datetime ?? "")
            
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "hh:mm"
            let displayedDate = outputDateFormatter.string(from: date ?? Date())
            switch conditions{
                
            case .clear:
                cell.imgWeather.image = UIImage(systemName: "sun.max.fill")
                break
            case .overcast:
                cell.imgWeather.image = UIImage(systemName: "smoke.fill")
                break
            case .partiallyCloudy:
                cell.imgWeather.image = UIImage(systemName: "cloud.sun.fill")
                break
            case .rainOvercast:
                cell.imgWeather.image = UIImage(systemName: "cloud.rain.fill")
                break
            case .snowOvercast:
                cell.imgWeather.image = UIImage(systemName: "cloud.snow.fill")
                break
            case .rainPartiallyCloudy:
                cell.imgWeather.image = UIImage(systemName: "cloud.sun.rain.fill")
                break
            case .snowPartiallyCloudy:
                cell.imgWeather.image = UIImage(systemName: "sun.snow.fill")
                break
            case .snowRainPartiallyCloudy:
                cell.imgWeather.image = UIImage(systemName: "cloud.sun.fillcloud.sun.rain.fill")
                break
            case .snowRainOvercast:
                cell.imgWeather.image = UIImage(systemName: "cloud.snow.fill")
                break
            case .rain:
                cell.imgWeather.image = UIImage(systemName: "cloud.rain.fill")
                break
            case .snowy:
                cell.imgWeather.image = UIImage(systemName: "snowflake")
                break
            case .storm:
                cell.imgWeather.image = UIImage(systemName: "cloud.bolt.fill")
                break
            case .windy:
                cell.imgWeather.image = UIImage(systemName: "wind")
                break
            case .dry:
                cell.imgWeather.image = UIImage(systemName: "sun.max.fill")
                break
            case .fog:
                cell.imgWeather.image = UIImage(systemName: "sun.dust.fill")
                break
            case .haze:
                cell.imgWeather.image = UIImage(systemName: "sun.haze.fill")
                break
            }
            cell.imgWeather.tintColor = collectionViewColor
            cell.lblDate.text = displayedDate
            settingsDict = UserDefaults.standard.value(forKey: "settingsDict") as? [String:String] ?? [:]
            if settingsDict["tempUnit"] == "C"{
                cell.lblMax.text = "\(String(format: "%.0f", dayWeather.feelslike ?? 0))° C"
                cell.lblMin.text = "\(String(format: "%.0f", dayWeather.temp ?? 0))° C"
            }
            else{
                cell.lblMax.text = "\(String(format: "%.0f", dayWeather.feelslike?.celsiusToFahrenheit() ?? 0))° F"
                cell.lblMin.text = "\(String(format: "%.0f", dayWeather.temp?.celsiusToFahrenheit() ?? 0))° F"
            }
            
            cell.makeViewBorderWithCurve(radius: 10,bcolor: collectionViewColor,bwidth: 2)
            cell.lblDate.textColor = collectionViewColor
            cell.lblMin.textColor = collectionViewColor
            cell.lblMax.textColor = collectionViewColor
            
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 128)
    }
    
    @IBAction func switchDayWeek(_ sender: Any) {
        clcWeek.reloadData()
    }
    
    @IBAction func btnSearch(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "searchStory") as! SearchPlaceVC
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func btnCurrentLocation(_ sender: Any) {
        latitude = locationManager.location?.coordinate.latitude ?? 0
        longitude = locationManager.location?.coordinate.longitude ?? 0
        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String{
            getCity(api_key: apiKey, latitude: self.latitude, longitude: self.longitude)
        }
        btnCurrentLocation.isHidden = true
    }
    
    @IBAction func btnSettings(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "settingsStory") as! SettingsVC
        vc.presentationController?.delegate = self
        if let presentationController = vc.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        
        vc.completion = {
            if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String{
                self.getCity(api_key: apiKey, latitude: self.latitude, longitude: self.longitude)
            }
        }
        
        present(vc, animated: true)
    }
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String{
            self.getCity(api_key: apiKey, latitude: self.latitude, longitude: self.longitude)
        }
    }
    
    
}
