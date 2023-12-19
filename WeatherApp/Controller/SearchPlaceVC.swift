//
//  SearchPlaceVC.swift
//  WeatherApp
//
//  Created by Athulya Tech on 7/19/23.
//

import UIKit
import MapKit
class SearchPlaceVC: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource, MKLocalSearchCompleterDelegate{
   
    

    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblSearchResults: UITableView!
    
    
    var searchCompleter = MKLocalSearchCompleter()
   
    var searchResults = [MKLocalSearchCompletion]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if txtSearch.text?.count ?? 0 < 1{
            searchResults = []
            tblSearchResults.reloadData()
        }
        txtSearch.resignFirstResponder()
    }
    

    func getWeatherData(city: String){
        let url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(city)?unitGroup=metric&key=AKGKQKRSW8H2522FCFV3NR74X&contentType=json"
            CallService(Model_Name: ResponseModelData.self, URLstr: url,method: HTTPMethodName.GET.rawValue){[self] response in
                
                
            }OnFail: {[self] err in
                showAlert(message: err, inViewController: self, forCancel: "", forOther: "Ok", isSingle: true){btn in
                    
                }
            }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = searchResult.title
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14,weight: .semibold)
            cell.detailTextLabel?.text = searchResult.subtitle
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
            return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let completion = searchResults[indexPath.row]
                
        let searchRequest = MKLocalSearch.Request(completion: completion)
                let search = MKLocalSearch(request: searchRequest)
                search.start { (response, error) in
                    let coordinate = response?.mapItems[0].placemark.coordinate
                    let popup = self.storyboard?.instantiateViewController(withIdentifier: "CurrentWeatherStory") as! ViewController
                    let navigationController = UINavigationController(rootViewController: popup)
                    navigationController.modalPresentationStyle = UIModalPresentationStyle.popover
                    popup.latitude = coordinate?.latitude ?? 0.00
                    popup.longitude = coordinate?.longitude ?? 0.00
                    popup.isFromSearch = true
                    self.present(navigationController, animated: true, completion: nil)
                    print(String(describing: coordinate))
                }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            searchResults = completer.results
            tblSearchResults.reloadData()
        }

    private func completer(completer: MKLocalSearchCompleter, didFailWithError error: NSError) {
            // handle error
        }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count ?? 0 < 1{
            searchResults = []
            tblSearchResults.reloadData()
        }
        else{
            searchCompleter.queryFragment = txtSearch.text!
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if txtSearch.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
//            getWeatherData(city: txtSearch.text ?? "")
//        }
        if textField.text?.count ?? 0 < 1{
            searchResults = []
            tblSearchResults.reloadData()
        }
        textField.resignFirstResponder()
        return true
       
    }

}
