//
//  ViewController.swift
//  WeatherApp
//
//  Created by Athulya Tech on 7/18/23.
//

import UIKit
import CoreLocation
import AVKit
class ViewController: UIViewController,CLLocationManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    //MARK: Outlets
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblCityCountry: UILabel!
    @IBOutlet weak var lblTempUnit: UILabel!
    @IBOutlet weak var lblWeeklyForecast: UILabel!
    
    @IBOutlet weak var lblHourlyForecast: UILabel!
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
    var player: AVPlayer!
    var avpController  = AVPlayerViewController()
    var isFromSearch = false
    //MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.tintColor = UIColor(named: "MaroonColor")
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        mainScrollView.isScrollEnabled = true
        mainScrollView.alwaysBounceVertical = true
        mainScrollView.refreshControl = refreshControl
        if !isFromSearch{
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
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
//        if !isFromSearch{
//            NotificationCenter.default.addObserver(self, selector: #selector(getCity), name: UIApplication.willEnterForegroundNotification, object: UIApplication.shared)
//        }
        
        clcDailyWeather.makeViewCurve(radius: 10)
        clcHourlyWeather.makeViewCurve(radius: 10)
       
    }
    override func viewDidAppear(_ animated: Bool) {
//        getCity()
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self)
    }
    //MARK: WebService methods
    @objc func getCity(){
        
        DispatchQueue.main.async {
            let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                            if error != nil {
                                return
                            }else if let country = placemarks?.first?.country,
                                let city = placemarks?.first?.locality {
                                self.lblCityCountry.text = city + ", " + country
                                self.lblCityCountry.textDropShadow()
                                self.cityName = city
                               
                                self.getWeatherData()
                            }
                            else {
                                self.showToastAlert(strmsg: "Failed to get city data", preferredStyle: .alert)
                                self.cityName = "Cupertino"
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
                clcDailyWeather.delegate = self
                clcDailyWeather.dataSource = self
                
                clcHourlyWeather.delegate = self
                clcHourlyWeather.dataSource = self
                
                lblTemperature.text = "\(response.currentConditions?.temp ?? 0.00)°"
                lblTemperature.textDropShadow()
                
                lblTempUnit.text = "Celsius"
                lblTempUnit.textDropShadow()
               
                lblConditions.text = response.currentConditions?.conditions?.rawValue
                lblConditions.textDropShadow()
                
                lblDesc.text = response.description ?? ""
                lblDesc.textDropShadow()
                
                lblFeelsLike.text = "Feels like" + " " + String(response.currentConditions?.feelslike ?? 0.00) + " °C"
                lblFeelsLike.textColor = .white
                lblFeelsLike.textDropShadow()
               
                lblPressure.text = "Pressure: " + String(response.currentConditions?.pressure ?? 0.00) + " Hg"
                lblPressure.textColor = .white
                lblPressure.textDropShadow()
               
                lblWeeklyForecast.textColor = .white
                lblWeeklyForecast.textDropShadow()
               
                lblHourlyForecast.textColor = .white
                lblHourlyForecast.textDropShadow()
               
                setVideo(response: response)
                
                clcDailyWeather.reloadData()
                clcHourlyWeather.reloadData()
            }OnFail: {[self] err in
                showAlert(message: err, inViewController: self, forCancel: "", forOther: "Ok", isSingle: true){btn in
                    
                }
            }
    }
    func setVideo(response: ResponseModelData){
        var url: URL
        let todayDate = DateFormatter.today.date(from: response.currentConditions?.datetime ?? "00:00:00")
        responseDate = todayDate ?? Date()
        if DateInterval(start: DateFormatter.today.date(from: "6:00:00") ?? Date(), end: DateFormatter.today.date(from: "11:59:59") ?? Date()).contains(todayDate ?? Date()){
            print("Morning")
            url = setVideoURLMorning(conditions: response.currentConditions?.conditions ?? Conditions.clear)
        }
        else if DateInterval(start: DateFormatter.today.date(from: "12:00:00") ?? Date(), end: DateFormatter.today.date(from: "16:59:59") ?? Date()).contains(todayDate ?? Date()){
            print("Noon")
            url = setVideoURLAfternoon(conditions: response.currentConditions?.conditions ?? Conditions.clear)
        }
        else if DateInterval(start: DateFormatter.today.date(from: "17:00:00") ?? Date(), end: DateFormatter.today.date(from: "22:59:59") ?? Date()).contains(todayDate ?? Date()){
            print("Evening")
            url = setVideoURLEvening(conditions: response.currentConditions?.conditions ?? Conditions.clear)
        }
        else{
            print("Night")
            url = setVideoURLNight(conditions: response.currentConditions?.conditions ?? Conditions.clear)
        }
//        else if DateInterval(start: DateFormatter.today.date(from: "23:00:00") ?? Date(), end: DateFormatter.today.date(from: "5:59:59") ?? Date()).contains(todayDate ?? Date()){
//            print("Night")
//        }
//        else{
//            print("Error in getting time")
//        }
        
        
//        let url = Bundle.main.url(forResource: "Beach", withExtension: "mp4")
        player = AVPlayer(url: url)
        player.isMuted = true
        avpController.player = player
        avpController.videoGravity = .resizeAspectFill

        avpController.view.frame.size.height = viewVideo.frame.size.height

        avpController.view.frame.size.width = viewVideo.frame.size.width

        self.viewVideo.addSubview(avpController.view)
        player.play()
        loopVideo(videoPlayer: player)
        
        
    }
    
    func loopVideo(videoPlayer: AVPlayer){
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil){notification in
//            videoPlayer.seek(to: CMTime.zero)
//            videoPlayer.play()
//        }
    }
    @objc func refresh(_ sender: UIRefreshControl){
//        getCity()
        refreshControl.endRefreshing()
    }
    //MARK: Location manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isFromSearch{
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
              getCity()
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
        return CGSize(width: collectionView.frame.width/3 + 40, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayWiseCell", for: indexPath) as! DayWiseCell
//        cell.layer.cornerRadius = 15
        var cellObj = CurrentConditions()
        var dateTime = ""
        if collectionView == clcDailyWeather{
            
            cellObj = dayArray[indexPath.row]
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"

            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd MMM"

            if let date = dateFormatterGet.date(from: cellObj.datetime ?? "") {
                dateTime = dateFormatterPrint.string(from: date)
                print(dateFormatterPrint.string(from: date))
            } else {
               print("There was an error decoding the string")
            }
            cell.lblLow.text = "Min: " + " " + String(cellObj.tempmin ?? 0.00) + " °C"
            cell.lblHigh.text = "Max: " + " " + String(cellObj.tempmax ?? 0.00) + " °C"
            cell.lblDate.text = dateTime
        }
        else{
            cellObj = hourArray[indexPath.row]
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "HH:mm:ss"

            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "hh a"

            if let date = dateFormatterGet.date(from: cellObj.datetime ?? "") {
                dateTime = dateFormatterPrint.string(from: date)
                print(dateFormatterPrint.string(from: date))
            } else {
               print("There was an error decoding the string")
            }
            cell.lblLow.text = ""
            cell.lblHigh.text = ""
            cell.lblDate.text = dateTime
        }
        
        cell.lblTemp.text = String(cellObj.temp ?? 0.00) + " °C"
        
        cell.viewShadow()
        return cell
    }
    


}

