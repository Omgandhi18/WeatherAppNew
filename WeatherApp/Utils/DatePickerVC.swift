//
//  DatePickerVC.swift
//  WeatherApp
//
//  Created by Athulya Tech on 7/18/23.
//

import UIKit

class DatePickerVC: UIViewController {
//MARK: Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    //MARK: Variables
    var titleLabel = "DateTime"
    var showDateTime = ""
    var minDate=Date()
    var noOfDays = Int()
    var maxDate=Date()
    var isTimePicker = false
    var onCompletionDone: ((String?) -> Void)?
    //===================================================================
    // MARK: - VIEW CONTROLLER LIFE CYCLE
    //===================================================================
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if !isTimePicker{
            datePicker.minimumDate = minDate
            if noOfDays != 0{
                datePicker.maximumDate = maxDate
            }
        }
        
        datePicker.date = Date()
        if titleLabel == "DateTime" {
            datePicker.date = getlocalToserverDate(date: showDateTime, input: date_format+" "+time_format) ?? Date()
            datePicker.datePickerMode = .dateAndTime
            datePicker.preferredDatePickerStyle = .inline
        } else if titleLabel == "Date" {
            datePicker.date = getlocalToserverDate(date: showDateTime, input: date_format) ?? Date()
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .inline
        } else if titleLabel == "Time" {
            datePicker.date = getlocalToserverDate(date: showDateTime, input: time_format) ?? Date()
            datePicker.datePickerMode = .time
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.center = view.center
        }else if titleLabel == "H/m" {
            datePicker.date = getDateinHrsMin(date: showDateTime, input: hrs_min_format) ?? Date()
            datePicker.locale = Locale(identifier: "en_gb")
            datePicker.datePickerMode = .time
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.center = view.center
        }else {
            datePicker.datePickerMode = .dateAndTime
            datePicker.preferredDatePickerStyle = .inline
        }
        
    }
    override func viewDidLayoutSubviews() {
        btnDone.tintColor = .systemTeal
        btnCancel.tintColor = .red
        datePicker.tintColor = .systemTeal
    }
    //===================================================================
    // MARK: - Button Actions
    //===================================================================
    @IBAction func btnDone(_ sender: Any) {
        valueChanged()
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    func valueChanged(){
        if titleLabel == "DateTime" {
            let strDate = getserverToLocalDate(date: datePicker.date, output: date_format+" "+time_format)
            self.onCompletionDone!(strDate)
        } else if titleLabel == "Date" {
            let strDate = getserverToLocalDate(date: datePicker.date, output: date_format)
            self.onCompletionDone!(strDate)
        } else if titleLabel == "Time" {
            let strDate = getserverToLocalDate(date: datePicker.date, output: time_format)
            self.onCompletionDone!(strDate)
        }else if titleLabel == "H/m" {
            let strDate = getHrsMininDate(date: datePicker.date, output: hrs_min_format)
            self.onCompletionDone!(strDate)
        }else {
            let strDate = getserverToLocalDate(date: datePicker.date, output: date_format+" "+time_format)
            self.onCompletionDone!(strDate)
        }
    
        
    }
    

}
