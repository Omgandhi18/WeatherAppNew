//
//  SearchPlaceVC.swift
//  WeatherApp
//
// 
//

import UIKit
import MapKit
protocol sendData{
    func sendDataToVC(coordinate: CLLocationCoordinate2D)
}
class SearchPlaceVC: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource, MKLocalSearchCompleterDelegate{
   
    

    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblSearchResults: UITableView!
    
    
    var searchCompleter = MKLocalSearchCompleter()
   
    var searchResults = [MKLocalSearchCompletion]()

    var delegate: sendData?
    
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
                    self.dismiss(animated: true)
                    self.delegate?.sendDataToVC(coordinate: coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
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
        if textField.text?.count ?? 0 < 1{
            searchResults = []
            tblSearchResults.reloadData()
        }
        textField.resignFirstResponder()
        return true
       
    }

}
