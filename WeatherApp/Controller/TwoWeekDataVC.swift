//
//  TwoWeekDataVC.swift
//  WeatherApp
//
//  Created by Athulya Tech on 7/19/23.
//

import UIKit

class TwoWeekDataVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    
//MARK: Outlets
    @IBOutlet weak var tblData: UITableView!
    @IBOutlet weak var tblHeaderView: UIView!
    
    //MARK: Variables
    var twoWeekArr = [CurrentConditions]()
    //MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        tblData.tableHeaderView = tblHeaderView
        twoWeekArr = responseModel.days ?? []
    }
    //MARK: Tableview Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twoWeekArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "twoWeekCell", for: indexPath) as! TwoWeekTableCell
        let obj = twoWeekArr[indexPath.row]
        cell.cellBackView.makeViewCurve(radius: 10)
        cell.cellBackView.viewShadow()
        cell.lblDate.text = obj.datetime ?? ""
        cell.imgWeather.image = weatherSymbolImageSet(conditions: obj.conditions ?? Conditions.clear, tintColor: "WhiteColor")
        cell.lblTemp.text = "Temp: " + "\(obj.temp ?? 0.00) °C"
        cell.lblMinTemp.text = "Min: " + "\(obj.tempmin ?? 0.00) °C"
        cell.lblMaxTemp.text = "Max: " + "\(obj.tempmax ?? 0.00) °C"
        cell.lblDesc.text = obj.description ?? ""
        return cell
    }

}
