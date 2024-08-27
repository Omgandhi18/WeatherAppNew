//
//  WeatherVC.swift
//  WeatherApp
//
//  Created by Om Gandhi on 21/06/2024.
//

import UIKit
import CoreLocation
import SceneKit
import WeatherKit


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
    @IBOutlet weak var lblWeatherAttribute: UILabel!
    @IBOutlet weak var lblModelAttribute: UILabel!
    
    
    var refreshControl = UIRefreshControl()
    
    let locationManager = CLLocationManager()
    var latitude: Double = 0
    var longitude: Double = 0
    var cityName = ""
    var dayArray = [DayWeather]()
    var hourArray = [HourWeather]()
    var collectionViewColor = UIColor(.clear)
    var settingsDict = ["tempUnit":"C"]
    var isSearched = false
    let weatherService = WeatherService.shared
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
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Forecast by  Weather", attributes: underlineAttribute)
        lblWeatherAttribute.attributedText = underlineAttributedString
        
        lblWeatherAttribute.isUserInteractionEnabled = true
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.linkLabelTapped(_:)))
        self.lblWeatherAttribute.isUserInteractionEnabled = true
        self.lblWeatherAttribute.addGestureRecognizer(labelTap)
        
        
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        getCity(latitude: self.latitude, longitude: self.longitude)
    }
    @objc func linkLabelTapped(_ sender: UITapGestureRecognizer){
        UIApplication.shared.open(URL(string: "https://developer.apple.com/weatherkit/data-source-attribution/")!)
    }
    @objc func getCity(latitude: Double, longitude: Double){
        
        DispatchQueue.main.async {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    return
                }else if let country = placemarks?.first?.country,
                         let city = placemarks?.first?.locality {
                    self.lblCityCountry.text = city + ", " + country
                    
                    self.cityName = city
                    
                    self.getWeatherData()
                }
                else {
                    //                                self.showToastAlert(strmsg: "Failed to get city data", preferredStyle: .alert)
                    self.cityName = "Cupertino"
                    self.lblCityCountry.text = "Cupertino, United States"
                    self.getWeatherData()
                }
            }
            )
        }
        
        
        
        
    }
    @objc func getWeatherData(){
        Task{
            do{
                let result = try await weatherService.weather(for: CLLocation(latitude: latitude, longitude: longitude))
                settingsDict = UserDefaults.standard.value(forKey: "settingsDict") as? [String:String] ?? [:]
                if settingsDict["tempUnit"] == "C"{
                    lblTemperature.text = "\(String(format: "%.0f", round(result.currentWeather.temperature.value)))° C"
                    //                    UIView.transition(with: lblTemperature, duration: 1.0,options: .transitionCrossDissolve, animations:{[weak self] in
                    //                        self?.
                    //                    } )x
                    lblHighLow.text = "High: \(String(format: "%.0f", result.dailyForecast.first?.highTemperature.value ?? 0))° C, Low: \(String(format: "%.0f", result.dailyForecast.first?.lowTemperature.value ?? 0))° C"
                }
                else{
                    lblTemperature.text = "\(String(format: "%.0f", round(result.currentWeather.temperature.value.celsiusToFahrenheit())))° F"
                    //                    UIView.transition(with: lblTemperature, duration: 1.0,options: .transitionCrossDissolve, animations:{[weak self] in
                    //                        self?.
                    //                    } )
                    lblHighLow.text = "High: \(String(format: "%.0f", result.dailyForecast.first?.highTemperature.value.celsiusToFahrenheit() ?? 0))° F, Low: \(String(format: "%.0f", result.dailyForecast.first?.lowTemperature.value.celsiusToFahrenheit() ?? 0))° F"
                }
                dayArray = result.dailyForecast.forecast
                hourArray = result.hourlyForecast.forecast
                let dailyForecast = result.dailyForecast.first { Calendar.current.isDateInToday($0.date) }
                        if let dailyForecast = dailyForecast {
                            
                            lblRainChance.text = "Chance of rain: \(String(format: "%.0f", dailyForecast.precipitationChance * 100))%"
//                            print("Precipitation chance: \(dailyForecast.precipitationChance * 100)%")
                        }
                lblConditions.text = result.currentWeather.condition.rawValue.capitalized
                
                let angle = NSNumber(value: (Float(result.currentWeather.wind.direction.value) / 180.0) * Float.pi)
                imgWindDir.layer.setValue(angle, forKeyPath: "transform.rotation.z")
                if settingsDict["windUnit"] == "KM"{
                    lblWindSpeed.text = "\(result.currentWeather.wind.speed.value) km/h"
                }
                else{
                    
                    lblWindSpeed.text = "\(String(format: "%.1f", result.currentWeather.wind.speed.value.kmToMiles())) mph"
                }
                setWeatherUI(conditions: result.currentWeather.condition)
                
                clcWeek.delegate = self
                clcWeek.dataSource = self
                clcWeek.reloadData()
                
                
            }catch{
                print(String(describing: error))
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
        lblWeatherAttribute.textColor = color
        lblModelAttribute.textColor = color
    }
    func setWeatherUI(conditions: WeatherCondition){
        switch conditions{
            
        case .blizzard:
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
        case .blowingDust:
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
            
        case .blowingSnow:
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
        case .breezy:
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
        case .cloudy:
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
        case .drizzle:
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
            
        case .flurries:
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
        case .foggy:
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
        case .freezingDrizzle:
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
        case .freezingRain:
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
        case .frigid:
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
        case .hail:
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
        case .heavyRain:
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
        case .heavySnow:
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
        case .hot:
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
        case .hurricane:
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
        case .isolatedThunderstorms:
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
        case .mostlyClear:
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
        case .mostlyCloudy:
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
        case .partlyCloudy:
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
        case .scatteredThunderstorms:
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
        case .sleet:
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
        case .smoky:
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
        case .snow:
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
        case .strongStorms:
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
        case .sunFlurries:
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
        case .sunShowers:
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
        case .thunderstorms:
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
        case .tropicalStorm:
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
        case .wintryMix:
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
        @unknown default:
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
        }
        
    }
    func sendDataToVC(coordinate: CLLocationCoordinate2D) {
        isSearched = true
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        getCity(latitude: self.latitude, longitude: self.longitude)
        btnCurrentLocation.isHidden = false
    }
    @objc func refresh(_ sender: UIRefreshControl){
        getCity(latitude: self.latitude, longitude: self.longitude)
       
        refreshControl.endRefreshing()
    }
    @objc func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.numberOfTouches == 2 {
            // Disable zoom
            print("zoom attempted")
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isSearched{
            if let location = locations.first {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
            }
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
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to get users location")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if switchDayWeek.isOn{
            return 7
        }
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as! WeatherCell
        if switchDayWeek.isOn{
            let dayWeather = dayArray[indexPath.row]
            let conditions = dayWeather.condition
            //            let dateFormatter = DateFormatter()
            //            dateFormatter.dateFormat = "yyyy-MM-dd"
            //            let date = dateFormatter.date(from: dayWeather.date ?? "")
            
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "dd/MM"
            let displayedDate = outputDateFormatter.string(from: dayWeather.date)
            cell.imgWeather.image = UIImage(systemName: dayWeather.symbolName)
            cell.imgWeather.tintColor = collectionViewColor
            cell.lblDate.text = displayedDate
            settingsDict = UserDefaults.standard.value(forKey: "settingsDict") as? [String:String] ?? [:]
            if settingsDict["tempUnit"] == "C"{
                cell.lblMax.text = "\(String(format: "%.0f", dayWeather.highTemperature.value))° C"
                cell.lblMin.text = "\(String(format: "%.0f", dayWeather.lowTemperature.value))° C"
            }
            else{
                cell.lblMax.text = "\(String(format: "%.0f", dayWeather.highTemperature.value.celsiusToFahrenheit()))° F"
                cell.lblMin.text = "\(String(format: "%.0f", dayWeather.lowTemperature.value.celsiusToFahrenheit()))° F"
            }
            
            
            cell.makeViewBorderWithCurve(radius: 10,bcolor: collectionViewColor,bwidth: 2)
            cell.lblDate.textColor = collectionViewColor
            cell.lblMin.textColor = collectionViewColor
            cell.lblMax.textColor = collectionViewColor
            
            return cell
        }
        else{
            let dayWeather = hourArray[indexPath.row]
            
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "hh:mm"
            let displayedDate = outputDateFormatter.string(from: dayWeather.date)
            
            cell.imgWeather.image = UIImage(systemName: dayWeather.symbolName)
            cell.imgWeather.tintColor = collectionViewColor
            cell.lblDate.text = displayedDate
            settingsDict = UserDefaults.standard.value(forKey: "settingsDict") as? [String:String] ?? [:]
            if settingsDict["tempUnit"] == "C"{
                cell.lblMax.text = "\(String(format: "%.0f", dayWeather.apparentTemperature.value))° C"
                cell.lblMin.text = "\(String(format: "%.0f", dayWeather.temperature.value))° C"
            }
            else{
                cell.lblMax.text = "\(String(format: "%.0f", dayWeather.apparentTemperature.value.celsiusToFahrenheit()))° F"
                cell.lblMin.text = "\(String(format: "%.0f", dayWeather.temperature.value.celsiusToFahrenheit()))° F"
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
        isSearched = false
        latitude = locationManager.location?.coordinate.latitude ?? 0
        longitude = locationManager.location?.coordinate.longitude ?? 0
        getCity(latitude: self.latitude, longitude: self.longitude)
        btnCurrentLocation.isHidden = true
    }
    
    @IBAction func btnSettings(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "settingsStory") as! SettingsVC
        vc.presentationController?.delegate = self
        if let presentationController = vc.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        
        vc.completion = {
            self.getCity(latitude: self.latitude, longitude: self.longitude)
        }
        
        present(vc, animated: true)
    }
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        getCity(latitude: self.latitude, longitude: self.longitude)
       
    }
    
    
}
