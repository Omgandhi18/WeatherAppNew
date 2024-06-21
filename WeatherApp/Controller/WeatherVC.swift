//
//  WeatherVC.swift
//  WeatherApp
//
//  Created by Om Gandhi on 21/06/2024.
//

import UIKit
import CoreLocation
import SceneKit

class WeatherVC: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
   
    

    @IBOutlet weak var lblCityCountry: UILabel!
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblConditions: UILabel!
    @IBOutlet weak var lblHighLow: UILabel!
    @IBOutlet weak var weatherIconView: SCNView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var clcWeek: UICollectionView!
    
    
    var refreshControl = UIRefreshControl()

    let locationManager = CLLocationManager()
    var latitude: Double = 0
    var longitude: Double = 0
    var cityName = ""
    var dayArray = [CurrentConditions]()
    var hourArray = [CurrentConditions]()
    var collectionViewColor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.tintColor = UIColor(named: "MaroonColor")
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
        var pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture))
        weatherIconView.addGestureRecognizer(pinchRecognizer)

        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getCity()
    }
    
    @objc func getCity(){
        
        DispatchQueue.main.async {
            let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
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
                                self.showToastAlert(strmsg: "Failed to get city data", preferredStyle: .alert)
                                self.cityName = "Cupertino"
                                self.lblCityCountry.text = "Cupertino, United States"
                                self.getWeatherData()
                            }
                        }
            )
        }
        
        
      
        
    }
    @objc func getWeatherData(){
        let url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(self.cityName)?unitGroup=metric&key=AKGKQKRSW8H2522FCFV3NR74X&contentType=json"
            CallService(Model_Name: ResponseModelData.self, URLstr: url,method: HTTPMethodName.GET.rawValue){[self]response in
                responseModel = response
                dayArray = response.days ?? []
                hourArray = response.days?.first?.hours ?? []
                
                lblTemperature.text = "\(String(format: "%.0f", round(response.currentConditions?.temp ?? 0.00)))° C"
                
                
                lblConditions.text = response.currentConditions?.conditions?.rawValue
                lblHighLow.text = "High: \(String(format: "%.0f", dayArray.first?.feelslikemax ?? 0))° C, Low: \(String(format: "%.0f", dayArray.first?.feelslikemin ?? 0))° C"
                
                
                set3DModel(conditions: response.currentConditions?.conditions ?? .clear)
                
                clcWeek.delegate = self
                clcWeek.dataSource = self
                clcWeek.reloadData()
                
            }OnFail: {[self] err in
                showAlert(message: err, inViewController: self, forCancel: "", forOther: "Ok", isSingle: true){btn in
                    
                }
            }
    }
    func set3DModel(conditions: Conditions){
        switch conditions{
            
        case .clear:
            weatherIconView.scene = SCNScene(named: "Clear.scn")
            mainScrollView.backgroundColor = UIColor(named: "clearWeather")
            lblTemperature.textColor = .black
            lblConditions.textColor = .black
            lblHighLow.textColor = .black
            lblCityCountry.textColor = .black
            collectionViewColor = .black
            break
        case .overcast:
            weatherIconView.scene = SCNScene(named: "Overcast.scn")
            mainScrollView.backgroundColor = UIColor(named: "overcastWeather")
            lblTemperature.textColor = .white
            lblConditions.textColor = .white
            lblHighLow.textColor = .white
            lblCityCountry.textColor = .white
            collectionViewColor = .white
            break
        case .partiallyCloudy:
            weatherIconView.scene = SCNScene(named: "PartiallyCloudy.scn")
            mainScrollView.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            lblTemperature.textColor = .black
            lblConditions.textColor = .black
            lblHighLow.textColor = .black
            lblCityCountry.textColor = .black
            collectionViewColor = .black
            break
        case .rainOvercast:
            weatherIconView.scene = SCNScene(named: "RainOvercast.scn")
            mainScrollView.backgroundColor = UIColor(named: "rainOvercast")
            lblTemperature.textColor = .white
            lblConditions.textColor = .white
            lblHighLow.textColor = .white
            lblCityCountry.textColor = .white
            collectionViewColor = .white
            break
        case .snowOvercast:
            weatherIconView.scene = SCNScene(named: "SnowOvercast.scn")
            weatherIconView.scene = SCNScene(named: "RainOvercast.scn")
            mainScrollView.backgroundColor = UIColor(named: "rainOvercast")
            lblTemperature.textColor = .white
            lblConditions.textColor = .white
            lblHighLow.textColor = .white
            lblCityCountry.textColor = .white
            collectionViewColor = .white
            break
        case .rainPartiallyCloudy:
            weatherIconView.scene = SCNScene(named: "RainPartiallyCloudy.scn")
            weatherIconView.scene = SCNScene(named: "PartiallyCloudy.scn")
            mainScrollView.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            lblTemperature.textColor = .black
            lblConditions.textColor = .black
            lblHighLow.textColor = .black
            lblCityCountry.textColor = .black
            collectionViewColor = .black
            
            break
        case .snowPartiallyCloudy:
            weatherIconView.scene = SCNScene(named: "SnowPartiallyCloudy.scn")
            weatherIconView.scene = SCNScene(named: "PartiallyCloudy.scn")
            mainScrollView.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            lblTemperature.textColor = .black
            lblConditions.textColor = .black
            lblHighLow.textColor = .black
            lblCityCountry.textColor = .black
            collectionViewColor = .black
            break
        case .snowRainPartiallyCloudy:
            weatherIconView.scene = SCNScene(named: "SnowRainPartially.scn")
            weatherIconView.scene = SCNScene(named: "PartiallyCloudy.scn")
            mainScrollView.backgroundColor = UIColor(named: "partiallyCloudyWeather")
            lblTemperature.textColor = .black
            lblConditions.textColor = .black
            lblHighLow.textColor = .black
            lblCityCountry.textColor = .black
            collectionViewColor = .black
            break
        case .snowRainOvercast:
            weatherIconView.scene = SCNScene(named: "SnowRainOvercast.scn")
            mainScrollView.backgroundColor = UIColor(named: "overcastWeather")
            lblTemperature.textColor = .white
            lblConditions.textColor = .white
            lblHighLow.textColor = .white
            lblCityCountry.textColor = .white
            collectionViewColor = .white
            break
        case .rain:
            weatherIconView.scene = SCNScene(named: "Rain.scn")
            mainScrollView.backgroundColor = UIColor(named: "rainWeather")
            lblTemperature.textColor = .white
            lblConditions.textColor = .white
            lblHighLow.textColor = .white
            lblCityCountry.textColor = .white
            collectionViewColor = .white
            break
        case .snowy:
            weatherIconView.scene = SCNScene(named: "Snow.scn")
            mainScrollView.backgroundColor = UIColor(named: "snowWeather")
            lblTemperature.textColor = .black
            lblConditions.textColor = .black
            lblHighLow.textColor = .black
            lblCityCountry.textColor = .black
            collectionViewColor = .black
            break
        case .storm:
            weatherIconView.scene = SCNScene(named: "Storm.scn")
            mainScrollView.backgroundColor = UIColor(named: "rainWeather")
            lblTemperature.textColor = .white
            lblConditions.textColor = .white
            lblHighLow.textColor = .white
            lblCityCountry.textColor = .white
            break
        case .windy:
            weatherIconView.scene = SCNScene(named: "Windy.scn")
            mainScrollView.backgroundColor = UIColor(named: "windyWeather")
            lblTemperature.textColor = .black
            lblConditions.textColor = .black
            lblHighLow.textColor = .black
            lblCityCountry.textColor = .black
            collectionViewColor = .black
            break
        case .dry:
            weatherIconView.scene = SCNScene(named: "Sun.scn")
            mainScrollView.backgroundColor = UIColor(named: "dryWeather")
            lblTemperature.textColor = .black
            lblConditions.textColor = .black
            lblHighLow.textColor = .black
            lblCityCountry.textColor = .black
            collectionViewColor = .black
            break
        case .fog:
            weatherIconView.scene = SCNScene(named: "PartiallyCloudy.scn")
            mainScrollView.backgroundColor = UIColor(named: "foggyWeather")
            lblTemperature.textColor = .black
            lblConditions.textColor = .black
            lblHighLow.textColor = .black
            lblCityCountry.textColor = .black
            collectionViewColor = .black
            break
        case .haze:
            weatherIconView.scene = SCNScene(named: "Haze.scn")
            mainScrollView.backgroundColor = UIColor(named: "foggyWeather")
            lblTemperature.textColor = .black
            lblConditions.textColor = .black
            lblHighLow.textColor = .black
            lblCityCountry.textColor = .black
            collectionViewColor = .black
            break
        }
        
    }
    @objc func refresh(_ sender: UIRefreshControl){
        getCity()
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
              getCity()
          }
      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dayArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as! WeatherCell
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
        cell.lblMax.text = "\(String(format: "%.0f", dayWeather.feelslikemax ?? 0))° C"
        cell.lblMin.text = "\(String(format: "%.0f", dayWeather.feelslikemin ?? 0))° C"
        cell.makeViewBorderWithCurve(radius: 10,bcolor: collectionViewColor,bwidth: 2)
        cell.lblDate.textColor = collectionViewColor
        cell.lblMin.textColor = collectionViewColor
        cell.lblMax.textColor = collectionViewColor
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 128)
    }

}
