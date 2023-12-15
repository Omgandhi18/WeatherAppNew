//
//  ViewController.swift
//  WeatherApp
//
//  Created by Athulya Tech on 7/18/23.
//

import UIKit
import CoreLocation
class ViewController: UIViewController,CLLocationManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    //MARK: Outlets
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblCityCountry: UILabel!
    @IBOutlet weak var lblTempUnit: UILabel!
    @IBOutlet weak var imgWeatherSymbol: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblConditions: UILabel!
    @IBOutlet weak var lblFeelsLike: UILabel!
    @IBOutlet weak var lblPressure: UILabel!
    @IBOutlet weak var clcDailyWeather: UICollectionView!
    @IBOutlet weak var clcHourlyWeather: UICollectionView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    //MARK: Variables
    var refreshControl = UIRefreshControl()

    let locationManager = CLLocationManager()
    var latitude: Double = 0
    var longitude: Double = 0
    var cityName = ""
    var dayArray = [CurrentConditions]()
    var hourArray = [CurrentConditions]()
    //MARK: ViewController lifecycle
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
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        clcDailyWeather.makeViewCurve(radius: 10)
        clcHourlyWeather.makeViewCurve(radius: 10)
       
    }
    override func viewDidAppear(_ animated: Bool) {
        getCity()
    }
    override func viewDidLayoutSubviews() {
        
    }
    //MARK: WebService methods
    func getCity(){
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                        if error != nil {
                            return
                        }else if let country = placemarks?.first?.country,
                            let city = placemarks?.first?.locality {
                            self.lblCityCountry.text = city + ", " + country
                            self.cityName = city
                           
                            self.getWeatherData(city: self.cityName)
                        }
                        else {
                            self.showToastAlert(strmsg: "Failed to get city data", preferredStyle: .alert)
                            self.cityName = "Cupertino"
                            self.getWeatherData(city: self.cityName)
                        }
                    }
        )
        
      
        
    }
    func getWeatherData(city: String){
        let url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(city)?unitGroup=metric&key=AKGKQKRSW8H2522FCFV3NR74X&contentType=json"
            CallService(Model_Name: ResponseModelData.self, URLstr: url,method: HTTPMethodName.GET.rawValue){[self]response in
                responseModel = response
                dayArray = response.days ?? []
                hourArray = response.days?.first?.hours ?? []
                clcDailyWeather.delegate = self
                clcDailyWeather.dataSource = self
                
                clcHourlyWeather.delegate = self
                clcHourlyWeather.dataSource = self
                
                lblTemperature.text = "\(response.currentConditions?.temp ?? 0.00)°"
                lblTempUnit.text = "Celsius"
                imgWeatherSymbol.image = weatherSymbolImageSet(conditions: response.currentConditions?.conditions ?? Conditions.clear,tintColor: "MaroonColor")
                lblConditions.text = response.currentConditions?.conditions?.rawValue
                lblDesc.text = response.description ?? ""
                lblFeelsLike.text = "Feels like" + " " + String(response.currentConditions?.feelslike ?? 0.00) + " °C"
                lblPressure.text = "Pressure: " + String(response.currentConditions?.pressure ?? 0.00) + " Hg"
                
            }OnFail: {[self] err in
                showAlert(message: err, inViewController: self, forCancel: "", forOther: "Ok", isSingle: true){btn in
                    
                }
            }
    }
    @objc func refresh(_ sender: UIRefreshControl){
        getCity()
        refreshControl.endRefreshing()
    }
    //MARK: Location manager delegates
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
    //MARK: CollectonView methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView  == clcDailyWeather{
            return 7
        }
        else{
            return hourArray.count
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayWiseCell", for: indexPath) as! DayWiseCell
        cell.layer.cornerRadius = 10
        var cellObj = CurrentConditions()
        if collectionView == clcDailyWeather{
            cellObj = dayArray[indexPath.row]
        }
        else{
            cellObj = hourArray[indexPath.row]
        }
        cell.lblDate.text = cellObj.datetime ?? ""
        cell.lblTemp.text = String(cellObj.temp ?? 0.00) + " °C"
        cell.lblLow.text = "Min: " + " " + String(cellObj.tempmin ?? 0.00) + " °C"
        cell.lblHigh.text = "Max: " + " " + String(cellObj.tempmax ?? 0.00) + " °C"
       
        return cell
    }
    


}

