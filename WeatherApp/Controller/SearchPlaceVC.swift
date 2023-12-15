//
//  SearchPlaceVC.swift
//  WeatherApp
//
//  Created by Athulya Tech on 7/19/23.
//

import UIKit

class SearchPlaceVC: UIViewController,UITextFieldDelegate{

    @IBOutlet weak var viewMainBack: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblDestination: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var imgWeather: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblSunrise: UILabel!
    @IBOutlet weak var lblSunset: UILabel!
    @IBOutlet weak var SunRiseSetView: UIView!
    @IBOutlet weak var lblHumidity: UILabel!
    @IBOutlet weak var lblDew: UILabel!
    @IBOutlet weak var HumidDewView: UIView!
    @IBOutlet weak var lblPrecipitation: UILabel!
    @IBOutlet weak var lblPrecipProb: UILabel!
    @IBOutlet weak var PrecipView: UIView!
    @IBOutlet weak var lblWindSpeed: UILabel!
    @IBOutlet weak var lblPressure: UILabel!
    @IBOutlet weak var WindView: UIView!
    @IBOutlet weak var SubstituteView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        viewMainBack.isHidden = true
        SubstituteView.makeViewCurve(radius: 10)
        SubstituteView.isHidden = false
        
    }
    

    func getWeatherData(city: String){
        let url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(city)?unitGroup=metric&key=AKGKQKRSW8H2522FCFV3NR74X&contentType=json"
            CallService(Model_Name: ResponseModelData.self, URLstr: url,method: HTTPMethodName.GET.rawValue){[self]response in
                SubstituteView.isHidden = true
                viewMainBack.isHidden = false
                viewMainBack.makeViewCurve(radius: 10)
                SunRiseSetView.makeViewCurve(radius: 10)
                PrecipView.makeViewCurve(radius: 10)
                HumidDewView.makeViewCurve(radius: 10)
                WindView.makeViewCurve(radius: 10)
                
                lblDestination.text = response.resolvedAddress ?? ""
                
                lblTemp.text = String(response.currentConditions?.temp ?? 0.00) + " °C"
                
                imgWeather.image = weatherSymbolImageSet(conditions: response.currentConditions?.conditions ?? Conditions.clear,tintColor: "background")
                
                lblDesc.text = response.description ?? ""
                
                lblSunrise.text = "Rise: " + (response.currentConditions?.sunrise ?? "")
                lblSunset.text = "Set: " + (response.currentConditions?.sunset ?? "")
                
                lblHumidity.text = "Humidity: " + String(response.currentConditions?.humidity ?? 0.00) + "%"
                lblDew.text = "Dew: " + String(response.currentConditions?.dew ?? 0.00) + " °C Td"
                
                lblPrecipitation.text = "Precip: " + String(response.currentConditions?.precip ?? 0.00) + " mm"
                lblPrecipProb.text = "PrecipProb: " + String(response.currentConditions?.precipprob ?? 0.00) + " mm"
                
                lblPressure.text = "Pressure: " + String(response.currentConditions?.pressure ?? 0.00) + " Hg"
                lblWindSpeed.text = "Windspeed: " + String(response.currentConditions?.windspeed ?? 0.00) + " km/h"
                
            }OnFail: {[self] err in
                showAlert(message: err, inViewController: self, forCancel: "", forOther: "Ok", isSingle: true){btn in
                    
                }
            }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if txtSearch.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            getWeatherData(city: txtSearch.text ?? "")
        }
        textField.resignFirstResponder()
        return true
       
    }

}
