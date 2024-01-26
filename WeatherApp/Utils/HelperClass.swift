//
//  HelperClass.swift
//  WeatherApp
//
//  Created by Athulya Tech on 7/18/23.
//

import Foundation
import UIKit
import MessageUI

// MARK: - Common
let AlertTitle                      = "Demo"
let AppDel                          = UIApplication.shared.delegate as? AppDelegate
var date_format = "dd/MM/yyyy"
var time_format = "hh:mm a"
var date_time_format = date_format + " " + time_format
var hrs_min_format = "HH:mm"
var responseModel = ResponseModelData()
var responseDate = Date()
//MARK: ALERT MESSAGE :-
enum AlertMsg: String {
    case internetConnection         = "The Internet connection appears to be offline."
    case emailMissing               = "Please enter email address"
    case phoneMissing               = "Please enter phone number"
    case passMissing                = "Please enter password"
    case oldPassMissing             = "Please enter old password"
    case conPassMissing             = "Please enter password again"
    case invalidEmailorPhone        = "Please enter valid email or phone number"
    case invalidEmail               = "Please enter valid email"
    case invalidPhone               = "Please enter valid phone number"
    case failService                = "Something went wrong. Please try again later !!"
    case missingValue               = "Please enter email or phone number"
    case passNotMatch               = "Passwords don't match"
    case oldPassNotMatch            = "Old password don't match"
    case passChanged                = "Password changed successfully"
    //MARK: Address error messages
    
    case addressMissing             = "Please enter an address"
    case dateMissing                = "Please select a date"
    case nameMissing                = "Please enter full name"
    case addressLine1Missing        = "Please enter address in address line 1"
    case landmarkMissing            = "Please enter landmark"
    case cityMissing                = "Please enter city name"
    case stateMissing               = "Please enter state name"
    case countryMissing             = "Please enter country name"
    case countryCodeMissing         = "Please enter country code"
    case zipCodeMissing             = "Please enter zipcode"
    case invalidZipCode             = "Please enter valid zip code"
    
    //MARK: Dashboard error messages
    
    case noProducts                 = "No products found"
    
    //MARK: Speech recogition errors
    
    case audioEngineError           = "Audio engine error"
    case notSupported               = "Speech recognition not supported for current locale"
    case notAvailable               = "Speech recognition not available right now"
    case recognitionError           = "Speech recognition error"
    case speechPermissionDenied     = "Please allow microphone access from settings"
    
    //MARK: Details error messages
    
    case firstNameMissing           = "Please enter first name"
    case lastNameMissing            = "Please enter last name"
    case dobMissing                 = "Please select date of birth"
    case genderMissing              = "Please select gender"
    case termsNotAgree              = "Please agree to terms and conditions"
    case ageLess                    = "Age is less than 18"
    case otpMissing                 = "Please enter otp"
    case incorrectOtp               = "Incorrect otp, please enter the correct otp"
    case profileUpdated             = "Profile updated"
    case ratingMissing              = "Please give rating"
    
    //MARK: Default error messages
    case error                      = "Error"
    case tryAgainLater              = "Try again later"
    case appNotStart                = "App can't be started"
    case appNotLoad                 = "App can't be loaded, Try again later"
    case somethingWrong             = "Something went wrong. Try again later"
}

extension UIImage {
    enum AssetIdentifier: String {
        case logo = "logo"
        case HomeLogo = "HomeLogo"
    }
    convenience init?(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
    func createSelectionIndicator(color: UIColor, size: CGSize, lineWidth: CGFloat) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setFill()
            UIRectFill(CGRectMake(0, size.height - lineWidth, size.width, lineWidth))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image ?? UIImage()
        }
}


//===================================================================
// MARK: - VIEW CONTROLLER =====> FUNCTION
//===================================================================
extension UIViewController: UIPopoverPresentationControllerDelegate,MFMailComposeViewControllerDelegate{
    //===================================================================
    // MARK: - ALERTVIEW METHOD - POPUP ALERTVIEW
    //===================================================================
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func showToastAlert(strmsg : String?, preferredStyle: UIAlertController.Style) {
        let message = strmsg
        let alert = UIAlertController(title: nil, message: message, preferredStyle: preferredStyle
        )
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        
        // duration in seconds
        let duration: Double = 1.5
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
    }
    
    //===================================================================
    // MARK: - ALERTVIEW  METHOD - CUSTOM ALERTVIEW
    //===================================================================
    
    func showAlert(_ title: String? = "", message msg: String?, inViewController vc: UIViewController?, forCancel cancelString: String?, forOther otherString: String?, isSingle isSingleButton:Bool=false, isDissmiss isDissmissOutside:Bool=false, textAlignment alignment: NSTextAlignment = .left, alertImage image: String? = "eraser.fill",backColor color:UIColor? = .white,otherButtonColor otherColor: UIColor? = .systemTeal,cancelButtonColor cancelColor: UIColor? = .red,completionHandler: @escaping (_ btnString: String?) -> Void) {

        let Story = UIStoryboard(name: "Main", bundle: nil)
        let myVC = Story.instantiateViewController(withIdentifier: "AlertStory") as? AlertVC
        myVC?.providesPresentationContextTransitionStyle = true
        myVC?.definesPresentationContext = true
        myVC?.isSingleBtn = isSingleButton  // for single button option
        myVC?.isDissmissView = isDissmissOutside // for dissmiss view on click outside popup
        myVC?.stralerttitle = title ?? ""
        myVC?.stralertmsg = msg ?? ""
        myVC?.btncanceltitle = cancelString ?? "Cancel"
        myVC?.btnothertitle = otherString ?? "OK"
        myVC?.textAlignment = alignment
        myVC?.image = image ?? "eraser.fill"
        myVC?.backgroundColor = color ?? .white
        myVC?.otherButtonColor = otherColor ?? .systemTeal
        myVC?.cancelButtonColor = cancelColor ?? .red
        myVC?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen

        myVC?.onCompletionClose = { [self] in
            print(self)
            completionHandler(cancelString)
            self.dismiss(animated: true)
        }

        myVC?.onCompletionDone = { [self] in
            print(self)
            completionHandler(otherString)
            self.dismiss(animated: true)
        }

        if let myVC = myVC {
            present(myVC, animated: true)
        }

    }
    
    
    //===================================================================
    // MARK: - UIPOPOVERCONTROLLER DELEGATE METHOD
    //===================================================================
    // MARK: - DROPDOWN LIST POPUP
//    func dropDownList(on sender: UIView?, array1: [AnyObject]?, arrowDirection direction: UIPopoverArrowDirection, searchView issearchView: Bool = false, title titletext: String? = "Select Item",arrKeyName keyName:String?="",multipleSelect isMultiple: Bool = false ,completion: @escaping (Any?) -> Void) {
//            let Story = UIStoryboard(name: "Main", bundle: nil)
//            let myVC = Story.instantiateViewController(withIdentifier: "ListTable") as? ListTableVC
//            myVC?.modalPresentationStyle = .popover
//            if isMultiple{
//                myVC?.preferredContentSize   = issearchView == true ? CGSizeMake(view.frame.size.width , Double(44 * (array1?.count ?? 0) + 157)) : CGSizeMake(view.frame.size.width , Double(44 * (array1?.count ?? 0) + 100))
//            }
//            else{
//                myVC?.preferredContentSize   = issearchView == true ? CGSizeMake(view.frame.size.width , Double(44 * (array1?.count ?? 0) + 110)) : CGSizeMake(view.frame.size.width , Double(44 * (array1?.count ?? 0) + 60))
//            }
////            myVC?.preferredContentSize   = issearchView == true ? CGSizeMake(view.frame.size.width , Double(44 * (array1?.count ?? 0) + 142)) : CGSizeMake(view.frame.size.width , Double(44 * (array1?.count ?? 0) + 85))
//            myVC?.arrList1 = array1 ?? []
//
//            myVC?.titleLabel = titletext ?? "Select Item"
//            myVC?.isSearchView = issearchView
//            myVC?.keyName=keyName ?? ""
//            myVC?.isMultiple = isMultiple
//            let popoverVC = myVC?.popoverPresentationController
//            popoverVC?.delegate=self
//
//            popoverVC?.permittedArrowDirections = direction
//            popoverVC?.sourceView = sender
//            popoverVC?.sourceRect = CGRectMake((sender?.frame.width ?? 0) / 2, sender?.frame.height ?? 0,0,0)
//
//            if let myVC = myVC {
//                present(myVC, animated: true)
//            }
//
//            myVC?.onCompletionDone = { dictSelected in
//                completion(dictSelected)
//                self.dismiss(animated: true)
//            }
//            myVC?.onMultipleCompletionDone = {dictSelected in
//                completion(dictSelected)
//                self.dismiss(animated: true)
//            }
//        }
//    
    
    // MARK: - DROPDOWN DATEPICKER POPUP
    func ShowDatePicker(on sender: UIView?, arrowDirection direction: UIPopoverArrowDirection, title titletext: String? = "DateTime",DateTime showDateTime: String? = "",minDate minimumDate:Date?=Date(),maxDate maximumDate:Date?=Date(),NoOfDays noOfDays:Int?=0,isTime isTimePicker:Bool?=false ,completion: @escaping (_ btnString: String?) -> Void) {
            let Story = UIStoryboard(name: "Main", bundle: nil)
            let myVC = Story.instantiateViewController(withIdentifier: "popup") as? DatePickerVC
            myVC?.modalPresentationStyle = .popover
            myVC?.preferredContentSize   = CGSizeMake(280, 400)
            myVC?.titleLabel = titletext ?? "DateTime"
            myVC?.showDateTime = showDateTime ?? ""
            myVC?.minDate=minimumDate ?? Date()
            myVC?.noOfDays=noOfDays ?? 0
            myVC?.maxDate=maximumDate ?? Date()
            myVC?.isTimePicker=isTimePicker ?? false
            let popoverVC = myVC?.popoverPresentationController
            popoverVC?.permittedArrowDirections = direction
            popoverVC?.sourceView = sender
            popoverVC?.sourceRect = CGRectMake((sender?.frame.width ?? 0) / 2, sender?.frame.height ?? 0,0,0)
            popoverVC?.delegate=self
            if let myVC = myVC {
                present(myVC, animated: true)
            }
    
            myVC?.onCompletionDone = { dictSelected in
                completion(dictSelected)
                self.dismiss(animated: true)
            }
        }
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    // MARK: - CONVERT CURRENCY TO STRING
    func convertCurrencyToString(Str currencyStr: String?) -> String? {
        var currencyStr = currencyStr
        
        currencyStr = currencyStr?.replacingOccurrences(of: ",", with: "")
        
        var isNegative = false
        if (currencyStr as NSString?)?.range(of: "(").location != NSNotFound {
            currencyStr = currencyStr?.replacingOccurrences(of: "(", with: "")
            currencyStr = currencyStr?.replacingOccurrences(of: ")", with: "")
            isNegative = true
        }
        let formatter = NumberFormatter()
        formatter.locale = NSLocale.current
        formatter.numberStyle = .currency //also tested with NSNumberFormatterDecimalStyle
        let currency = formatter.number(from: currencyStr ?? "")
        var numberStr: String?
        if isNegative {
            numberStr = String(format: "%.2f", currency?.doubleValue ?? 0.0 * -1)
        } else {
            numberStr = String(format: "%.2f", currency?.doubleValue ?? 0.0)
        }
        
        if currency == nil {
            numberStr = currencyStr
        }
        return numberStr
    }
    
    // MARK: - CONVERT STRING TO CURRENCY
    func convertStringToCurrency(_ valueStr: String?) -> String? {
        
        var valueStr = valueStr
        valueStr = valueStr?.replacingOccurrences(of: ",", with: "")
        
        var isNegative = false
        if (valueStr as NSString?)?.range(of: "(").location != NSNotFound {
            valueStr = valueStr?.replacingOccurrences(of: "(", with: "")
            valueStr = valueStr?.replacingOccurrences(of: ")", with: "")
            isNegative = true
        }
        
        if valueStr?.contains("$") ?? false {
            valueStr = valueStr?.replacingOccurrences(of: "$", with: "")
        }
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        var currencyStr: String?
        if Double(valueStr ?? "") ?? 0.0 > 0 && !isNegative {
            currencyStr = "\(currencyFormatter.string(from: NSNumber(value: valueStr?.toDouble() ?? 0.0)) ?? "")"
        } else {
            currencyStr = "(\(currencyFormatter.string(from: NSNumber(value: (valueStr?.replacingOccurrences(of: "-", with: ""))?.toDouble() ?? 0.0)) ?? ""))"
        }
        if (currencyStr == "($0.00)") {
            currencyStr = "$0.00"
        }
        return currencyStr
    }
    
    // MARK: - VALIDATION ONLY TWO DECIMAL
    func onlyNumberWith2Decimal(_ textField: UITextField?, replacementString string: String?) -> Bool {
        if (string?.count ?? 0) != 0 {
            
            var centValue: Int
            var formatedValue: NSNumber?
            var isNegative = false
            if (textField?.text?.contains("(") ?? false) || textField?.text?.contains("-") ?? false {
                isNegative = true
            }
            
            var cleanCentString = textField?.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            var prefixStr = ""
            if (cleanCentString?.count ?? 0) > 5 {
                prefixStr = (cleanCentString as NSString?)?.substring(to: (cleanCentString?.count ?? 0) - 4) ?? ""
                cleanCentString = (cleanCentString as NSString?)?.substring(from: (cleanCentString?.count ?? 0) - 4)
                
                centValue = Int(cleanCentString ?? "") ?? 0
                if centValue != 0 {
                    if centValue / 1000 != 0 {
                        if (string?.count ?? 0) > 0 {
                            centValue = centValue * 10 + (Int(string ?? "") ?? 0)
                        } else {
                            centValue = centValue / 10
                        }
                        formatedValue = NSNumber(value: Float(centValue) / 100.0)
                        prefixStr = "\(prefixStr)\(formatedValue?.stringValue ?? "")"
                    } else if centValue / 100 != 0 {
                        if (string?.count ?? 0) > 0 {
                            centValue = centValue * 10 + (Int(string ?? "") ?? 0)
                            formatedValue = NSNumber(value: Float(centValue) / 100.0)
                            prefixStr = "\(prefixStr)0\(formatedValue?.stringValue ?? "")"
                        } else {
                            centValue = centValue / 10
                            formatedValue = NSNumber(value: Float(centValue) / 100.0)
                            prefixStr = "\(prefixStr)0\(formatedValue?.stringValue ?? "")"
                        }
                    } else if centValue / 10 != 0 {
                        if (string?.count ?? 0) > 0 {
                            centValue = centValue * 10 + (Int(string ?? "") ?? 0)
                            formatedValue = NSNumber(value: Float(centValue) / 100.0)
                            prefixStr = "\(prefixStr)00\(formatedValue ?? 0.00)"
                        } else {
                            centValue = centValue / 10
                            formatedValue = NSNumber(value: Float(centValue) / 100.0)
                            prefixStr = "\(prefixStr)\(formatedValue ?? 0.00)"
                        }
                    } else {
                        if (string?.count ?? 0) > 0 {
                            centValue = centValue * 10 + (Int(string ?? "") ?? 0)
                            formatedValue = NSNumber(value: Float(centValue) / 100.0)
                            prefixStr = "\(prefixStr)00\(formatedValue ?? 0.0)"
                        } else {
                            centValue = centValue / 10
                            formatedValue = NSNumber(value: Float(centValue) / 100.0)
                            prefixStr = "\(prefixStr)\(formatedValue ?? 0.0)"
                        }
                    }
                } else {
                    if (string?.count ?? 0) > 0 {
                        prefixStr = "\(prefixStr)000.0\(string ?? "")"
                    } else {
                        prefixStr = "\(prefixStr)0.00"
                    }
                }
            } else {
                centValue = Int(cleanCentString ?? "") ?? 0
                
                if (string?.count ?? 0 > 0) {
                    centValue = centValue * 10 + (Int(string ?? "") ?? 0)
                } else {
                    centValue = centValue / 10
                }
                formatedValue = NSNumber(value: Float(centValue) / 100.0)
                prefixStr = "\(prefixStr)\(formatedValue ?? 0.00)"
            }
            let f = NumberFormatter()
            f.numberStyle = .decimal
            formatedValue = f.number(from: prefixStr)
            let _currencyFormatter = NumberFormatter()
            _currencyFormatter.numberStyle = .currency
            
            if isNegative {
                textField?.text = "(\(_currencyFormatter.string(from: formatedValue ?? 0) ?? ""))"
            } else {
                textField?.text = _currencyFormatter.string(from: formatedValue ?? 0)
            }
            return false
        } else {
            var f = NSNumber()
            f = 0.00
            let _currencyFormatter = NumberFormatter()
            _currencyFormatter.numberStyle = .currency
            
            textField?.text = _currencyFormatter.string(from: f)
            return false
        }
    }
    
    // MARK: - VALIDATION ONLY NUMARIC CHARACTER
    func getNumaricCharOnly(string:String?="")-> Bool {
        let allowingChars = "0123456789"
        let numberOnly = NSCharacterSet.init(charactersIn: allowingChars).inverted
        let validString = string?.rangeOfCharacter(from: numberOnly) == nil
        return validString
    }
    //MARK: VALIDATION ONLY Alphabet and Space CHARACTER
    func getAlphabetandSpaceOnly(string:String?="")-> Bool {
        let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: string!)
        let alphabet = allowedCharacterSet.isSuperset(of: typedCharacterSet)
        return alphabet
    }
    // MARK: - VALIDATION IP ADDRESS CHECK
    func ipCheck(_ textField: UITextField?, shouldChangeCharactersIn range: NSRange, replacementString string: String?) -> Bool {
        var ipEntered: String?
        if string != "" {
            
            ipEntered = "\((textField?.text as NSString?)?.substring(to: range.location) ?? "")\(string ?? "")"
        }
        
        let validIPRegEx = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])[.]){0,3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])?$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", validIPRegEx)
        if string == "" {
            
            return true
        } else if emailTest.evaluate(with: ipEntered) {
            
            return true
        } else {
            
            return false
        }
    }
    
    // MARK: - VALIDATION IP ADDRESS VALID OR NOT
    func isValidIPAdress(_ testStr:String) -> Bool {
        let ipAddressRegex = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
        
        let ipAddTest = NSPredicate(format:"SELF MATCHES %@", ipAddressRegex)
        print("ipAddTest.evaluateWithObject(testStr) = \(ipAddTest.evaluate(with: testStr))")
        return ipAddTest.evaluate(with: testStr)
    }
    
    
    
    // MARK: - DATES (CONVERT DATE FORMAT :-)
    func getDateFormattedFromStringDate(strDate: String, withInputFormat inputFormat: String, andOutputFormat outputFormat: String, isTypeOfString isString: Bool) -> Any {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = inputFormat
        
        let dte = dateFormatter.date(from: strDate)
        dateFormatter.dateFormat = outputFormat
        
        if isString {
            let strFormattedDate = dateFormatter.string(from: dte ?? Date())
            return strFormattedDate as Any
        }
        else {
            let strFormattedDate = dateFormatter.string(from: dte ?? Date())
            let formattedDate = dateFormatter.date(from: strFormattedDate)
            return formattedDate as Any
        }
    }
    
    func getserverToLocalDate(date selecteddate: Date, output outputFormate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = outputFormate
        let strdate = dateFormatter.string(from: selecteddate)
        
        return strdate
    }
    
    func getlocalToserverDate(date strDate: String, input inputFormate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = inputFormate
        let date = dateFormatter.date(from: strDate)
        
        return date
    }
    func getHrsMininDate(date selecteddate: Date, output outputFormate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = outputFormate
        let strdate = dateFormatter.string(from: selecteddate)
        
        return strdate
    }
    func getDateinHrsMin(date strDate: String, input inputFormate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = inputFormate
        let date = dateFormatter.date(from: strDate)
        
        return date
    }
    func getFormattedTime(_ strTime: String?, withInputFormat inputFormat: String?, andOutputFormat outputFormat: String?) -> String? {
        let dateFormat = DateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormat.locale = locale as Locale
        dateFormat.dateFormat = inputFormat
        let dte = dateFormat.date(from: strTime ?? "")
        dateFormat.dateFormat = outputFormat
        var strFormattedDate: String? = nil
        if let dte = dte {
            strFormattedDate = dateFormat.string(from: dte)
        }
        return strFormattedDate
    }
    func imageWith(fName: String?="abc",lName: String?="abc",width imgWidth: CGFloat?=75,height imgHeight: CGFloat?=75) -> UIImage? {
         let frame = CGRect(x: 0, y: 0, width: imgWidth!, height: imgHeight!)
         let nameLabel = UILabel(frame: frame)
         nameLabel.textAlignment = .center
         nameLabel.backgroundColor = .lightGray
         nameLabel.textColor = .white
         nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        let first=fName?.first?.description
        let last=lName?.first?.description
        
        nameLabel.text = (first ?? "").capitalized + (last ?? "").capitalized
        UIGraphicsBeginImageContext(frame.size)
          if let currentContext = UIGraphicsGetCurrentContext() {
             nameLabel.layer.render(in: currentContext)
             let nameImage = UIGraphicsGetImageFromCurrentImageContext()
             return nameImage
          }
          return nil
    }
    // MARK: - Contact Functions
    func sendEmail(_ email:String?){
        if MFMailComposeViewController.canSendMail(){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email ?? ""])
            present(mail, animated: true)
        }
        else{
            
        }
    }
    func callNumber(_ number:String?){
        let url = URL(string: "tel://"+(number ?? ""))!
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        }
    }
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
func weatherSymbolImageSet(conditions: Conditions,tintColor: String) -> UIImage{
    switch(conditions){
    case .clear: return (UIImage(systemName: "sun.max.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
        
    case .dry: return (UIImage(systemName: "humidity.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
       
    case .fog: return (UIImage(systemName: "cloud.fog.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
       
    case .haze: return (UIImage(systemName: "sun.haze.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
        
    case .overcast: return (UIImage(systemName: "smoke.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
        
    case .partiallyCloudy: return (UIImage(systemName: "cloud.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
       
    case .rain: return (UIImage(systemName: "cloud.rain.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
     
    case .rainOvercast: return (UIImage(systemName: "cloud.heavyrain.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
       
    case .rainPartiallyCloudy: return (UIImage(systemName: "cloud.sun.rain.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
     
    case .snowy: return (UIImage(systemName: "cloud.snow.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
    case .storm: return (UIImage(systemName: "cloud.bolt.rain.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
    
    case .windy: return (UIImage(systemName: "wind")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
     
    default: return (UIImage(systemName: "sun.max.fill")?.withTintColor(UIColor(named: tintColor)!,renderingMode: .alwaysOriginal))!
  
    }
    
}
//MARK: Morning Video URL
func setVideoURLMorning(conditions: Conditions) -> URL{
    var url: URL?
    switch(conditions){
    case .clear: url = Bundle.main.url(forResource: "clearMorning", withExtension: "mp4")!
        break
    case .overcast: url = Bundle.main.url(forResource: "overcastMorning", withExtension: "mp4")!
        break
    case .partiallyCloudy: url = Bundle.main.url(forResource: "cloudyMorning", withExtension: "mp4")!
        break
    case .rainOvercast: url = Bundle.main.url(forResource: "rainOvercast", withExtension: "mp4")!
        break
    case .snowOvercast: url = Bundle.main.url(forResource: "snowOvercast", withExtension: "mp4")!
        break
    case .rainPartiallyCloudy: url = Bundle.main.url(forResource: "rainPartiallyCloudy", withExtension: "mp4")!
        break
    case .snowPartiallyCloudy: url = Bundle.main.url(forResource: "cloudyMorning", withExtension: "mp4")!
        break
    case .rain: url = Bundle.main.url(forResource: "rain", withExtension: "mp4")!
        break
    case .snowy: url = Bundle.main.url(forResource: "Snowy", withExtension: "mp4")!
        break
    case .storm: url = Bundle.main.url(forResource: "Storm", withExtension: "mp4")!
        break
    case .windy: url = Bundle.main.url(forResource: "Windy", withExtension: "mp4")!
        break
    case .dry: url = Bundle.main.url(forResource: "dryMorning", withExtension: "mp4")!
        break
    case .fog: url = Bundle.main.url(forResource: "fogMorning", withExtension: "mp4")!
        break
    case .haze: url = Bundle.main.url(forResource: "hazeMorning", withExtension: "mp4")!
        break
    case .snowRainOvercast: url =  Bundle.main.url(forResource: "Snowy", withExtension: "mp4")!
        break
    case .snowRainPartiallyCloudy:
        url =  Bundle.main.url(forResource: "snowRainPartiallyCloudy", withExtension: "mp4")!
            break
    }
    
    return url ?? URL(string: "https://youtu.be/1VMI7nffU-Q")!
}
//MARK: Noon Video URL
func setVideoURLAfternoon(conditions: Conditions) -> URL{
    var url: URL?
    switch(conditions){
    case .clear: url = Bundle.main.url(forResource: "clearNoon", withExtension: "mp4")!
        break
    case .overcast: url = Bundle.main.url(forResource: "overcastNoon", withExtension: "mp4")!
        break
    case .partiallyCloudy: url = Bundle.main.url(forResource: "cloudyNoon", withExtension: "mp4")!
        break
    case .rainOvercast: url = Bundle.main.url(forResource: "rainOvercast", withExtension: "mp4")!
        break
    case .snowOvercast: url = Bundle.main.url(forResource: "snowOvercast", withExtension: "mp4")!
        break
    case .rainPartiallyCloudy: url = Bundle.main.url(forResource: "rainPartiallyCloudy", withExtension: "mp4")!
        break
    case .snowPartiallyCloudy: url = Bundle.main.url(forResource: "cloudyNoon", withExtension: "mp4")!
        break
    case .rain: url = Bundle.main.url(forResource: "rain", withExtension: "mp4")!
        break
    case .snowy: url = Bundle.main.url(forResource: "Snowy", withExtension: "mp4")!
        break
    case .storm: url = Bundle.main.url(forResource: "Storm", withExtension: "mp4")!
        break
    case .windy: url = Bundle.main.url(forResource: "Windy", withExtension: "mp4")!
        break
    case .dry: url = Bundle.main.url(forResource: "dryNoon", withExtension: "mp4")!
        break
    case .fog: url = Bundle.main.url(forResource: "fogNoon", withExtension: "mp4")!
        break
    case .haze: url = Bundle.main.url(forResource: "hazeNoon", withExtension: "mp4")!
        break
    case .snowRainOvercast:
        url =  Bundle.main.url(forResource: "Snowy", withExtension: "mp4")!
            break
    case .snowRainPartiallyCloudy:
        url =  Bundle.main.url(forResource: "snowRainPartiallyCloudy", withExtension: "mp4")!
            break
    }
    
    return url ?? URL(string: "https://youtu.be/1VMI7nffU-Q")!
}
//MARK: Evening Video URL
func setVideoURLEvening(conditions: Conditions) -> URL{
    var url: URL?
    switch(conditions){
    case .clear: url = Bundle.main.url(forResource: "clearEvening", withExtension: "mp4")!
        break
    case .overcast: url = Bundle.main.url(forResource: "overcastEvening", withExtension: "mp4")!
        break
    case .partiallyCloudy: url = Bundle.main.url(forResource: "cloudyEvening", withExtension: "mp4")!
        break
    case .rainOvercast: url = Bundle.main.url(forResource: "rainOvercast", withExtension: "mp4")!
        break
    case .snowOvercast: url = Bundle.main.url(forResource: "snowOvercast", withExtension: "mp4")!
        break
    case .rainPartiallyCloudy: url = Bundle.main.url(forResource: "rainPartiallyCloudy", withExtension: "mp4")!
        break
    case .snowPartiallyCloudy: url = Bundle.main.url(forResource: "cloudyEvening", withExtension: "mp4")!
        break
    case .rain: url = Bundle.main.url(forResource: "rain", withExtension: "mp4")!
        break
    case .snowy: url = Bundle.main.url(forResource: "Snowy", withExtension: "mp4")!
        break
    case .storm: url = Bundle.main.url(forResource: "Storm", withExtension: "mp4")!
        break
    case .windy: url = Bundle.main.url(forResource: "Windy", withExtension: "mp4")!
        break
    case .dry: url = Bundle.main.url(forResource: "dryEvening", withExtension: "mp4")!
        break
    case .fog: url = Bundle.main.url(forResource: "fogEvening", withExtension: "mp4")!
        break
    case .haze: url = Bundle.main.url(forResource: "hazeEvening", withExtension: "mp4")!
        break
    case .snowRainOvercast: url =  Bundle.main.url(forResource: "Snowy", withExtension: "mp4")!
            break
    case .snowRainPartiallyCloudy:
        url =  Bundle.main.url(forResource: "snowRainPartiallyCloudy", withExtension: "mp4")!
            break
    }
    
    return url ?? URL(string: "https://youtu.be/1VMI7nffU-Q")!
}
//MARK: Night Video URL
func setVideoURLNight(conditions: Conditions) -> URL{
    var url: URL?
    switch(conditions){
    case .clear: url = Bundle.main.url(forResource: "clearNight", withExtension: "mp4")!
        break
    case .overcast: url = Bundle.main.url(forResource: "overcastNight", withExtension: "mp4")!
        break
    case .partiallyCloudy: url = Bundle.main.url(forResource: "cloudyNight", withExtension: "mp4")!
        break
    case .rainOvercast: url = Bundle.main.url(forResource: "rainOvercast", withExtension: "mp4")!
        break
    case .snowOvercast: url = Bundle.main.url(forResource: "snowOvercast", withExtension: "mp4")!
        break
    case .rainPartiallyCloudy: url = Bundle.main.url(forResource: "rainPartiallyCloudy", withExtension: "mp4")!
        break
    case .snowPartiallyCloudy: url = Bundle.main.url(forResource: "cloudyNight", withExtension: "mp4")!
        break
    case .rain: url = Bundle.main.url(forResource: "rain", withExtension: "mp4")!
        break
    case .snowy: url = Bundle.main.url(forResource: "Snowy", withExtension: "mp4")!
        break
    case .storm: url = Bundle.main.url(forResource: "Storm", withExtension: "mp4")!
        break
    case .windy: url = Bundle.main.url(forResource: "Windy", withExtension: "mp4")!
        break
    case .dry: url = Bundle.main.url(forResource: "dryNight", withExtension: "mp4")!
        break
    case .fog: url = Bundle.main.url(forResource: "fogNight", withExtension: "mp4")!
        break
    case .haze: url = Bundle.main.url(forResource: "hazeNight", withExtension: "mp4")!
        break
    case .snowRainOvercast:
        url =  Bundle.main.url(forResource: "Snowy", withExtension: "mp4")!
            break
    case .snowRainPartiallyCloudy:
        url =  Bundle.main.url(forResource: "snowRainPartiallyCloudy", withExtension: "mp4")!
            break
    }
    
    return url ?? URL(string: "https://youtu.be/1VMI7nffU-Q")!
}
//func MorningTime() -> Bool {
//    guard let start = Formatter.today.date(from: "6:00:00"),
//          let end = Formatter.today.date(from: "11:59:59") else {
//        return false
//    }
//    return DateInterval(start: start, end: end).contains(Date())
//}
//func AfternoonTime() -> Bool {
//    guard let start = Formatter.today.date(from: "12:00:00"),
//          let end = Formatter.today.date(from: "16:59:00") else {
//        return false
//    }
//    return DateInterval(start: start, end: end).contains(Date())
//}
//func EveningTime() -> Bool {
//    guard let start = Formatter.today.date(from: "17:00:00"),
//          let end = Formatter.today.date(from: "22:59:59") else {
//        return false
//    }
//    return DateInterval(start: start, end: end).contains(Date())
//}
//func NightTime(dateTime: String) -> Bool {
//    guard let start = Formatter.today.date(from: "23:00:00"),
//          let end = Formatter.today.date(from: "5:59:00") else {
//        return false
//    }
//   
//    let todayDate = Formatter.today.date(from: dateTime)
//    return DateInterval(start: start, end: end).contains(todayDate ?? Date())
//    
//}

//===================================================================
// MARK: - STRING ====> UIDESIGN
//===================================================================

extension String {
    //Check String Length
//    var length: Int { return self.count }
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    func toInt() -> Int? {
        return NumberFormatter().number(from: self)?.intValue
    }
    var isValidEmail: Bool {
           NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
       }
    var isValidPhone: Bool {
           NSPredicate(format: "SELF MATCHES %@", "^[0-9]{10}$").evaluate(with: self)
       }
}
//===================================================================
// MARK: - DATE ====> UIDESIGN
//===================================================================
extension Date{
    func startOfMonth() -> Date {
        let interval = Calendar.current.dateInterval(of: .month, for: self)
        return (interval?.start.toLocalTime())! // Without toLocalTime it give last months last date
    }

    func endOfMonth() -> Date {
        let interval = Calendar.current.dateInterval(of: .month, for: self)
        return interval!.end
    }

    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone    = TimeZone.current
        let seconds     = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}
//===================================================================
// MARK: - UITapGestureRecognizer ====> UIDESIGN
//===================================================================
extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        var indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        indexOfCharacter = indexOfCharacter + 4
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
//===================================================================
// MARK: - BUTTON ====> UIDESIGN
//===================================================================
extension UIButton {

    //MARK: BUTTON CURVE :-
    func makeButtonCurve(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
    //MARK: BUTTON ROUNDED :-
    func makeButtonRounded() {
        self.layer.cornerRadius = self.layer.frame.height / 2
        self.layer.masksToBounds = true
       
    }
    func btnShadows(){
        self.layer.cornerRadius=0.5*self.layer.frame.height
        self.layer.shadowColor=UIColor.black.cgColor
        self.layer.shadowOpacity=0.5
        self.layer.shadowRadius=20
        self.layer.shadowOffset=CGSize.zero
        
     
        
    }
}

//===================================================================
// MARK: - VIEW ====> UIDESIGN
//===================================================================

extension UIView {
    
    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }

    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }

    func makeViewCurve(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
    func makeViewBorderWithCurve(radius: CGFloat, bcolor: UIColor = .black, bwidth: CGFloat = 1) {
        
        self.layer.cornerRadius = radius
        self.layer.borderWidth = bwidth
        self.layer.borderColor = bcolor.cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
   
    func viewShadow(){
        self.layer.cornerRadius = 15
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 5
        self.layer.shadowOffset  = CGSize(width: 1, height: 2)
        self.layer.masksToBounds = false
    }
}

extension UIColor {
    // Press Cmd + Shift + L to open library and then select Color tab.
    static let transparent         = UIColor(named: "transparent")        // #000000 50%
//    static let office_background          = UIColor(named: "office_background")         // #EFEFF7
//    static let office_main                = UIColor(named: "office_main")               // #1F56BE
    static let vwbackground        = UIColor(named: "vwbackground")       // #01467C
//    static let office_cellbackground      = UIColor(named: "ecom_cellbackground")     // #5CA0FF 10%
//    static let office_buttonColor         = UIColor(named: "buttonColor")             // #103961
//    static let labelColor                 = UIColor(named: "labelColor")              // #165E97
    static let whiteTransparent = UIColor(named: "white_transparent")
}
extension UILabel{
    func addUnderLineToLabel() {
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0.0, y: self.bounds.height, width: self.bounds.width, height: 3.0)
        bottomLine.backgroundColor = UIColor.black.cgColor
        
        
        self.layer.addSublayer(bottomLine)
    }
    func textDropShadow() {
            self.layer.masksToBounds = false
            self.layer.shadowRadius = 5.0
            self.layer.shadowOpacity = 0.4
            self.layer.shadowOffset = CGSize(width: 1, height: 2)
        }
}
extension UITextField {
    func makeTextViewBorderWithCurve(radius: CGFloat, bcolor: UIColor = .black, bwidth: CGFloat = 1,leftPadding:CGFloat?=10) {
        self.leftViewMode = .always
        let view=UIView(frame: CGRect(x: 0, y: 0, width: leftPadding!, height: 40))
        self.leftView=view
        self.layer.cornerRadius = radius
        self.layer.borderWidth = bwidth
        self.layer.borderColor = bcolor.cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    func addUnderLine () {
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0.0, y: self.bounds.height + 3, width: self.bounds.width, height: 1.5)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
    //To insert Image in TextField left
    func setLeftImageToTextField(imgName: String,imgWidth: CGFloat?=24,imgHight: CGFloat?=24,padding: CGFloat?=10)
    {
        let view=UIView(frame: CGRect(x: 0, y: 0, width: imgWidth! + padding!, height: imgHight!))
        let disUser: UIImageView = UIImageView(image:UIImage(named: imgName))
        disUser.frame = CGRect(x: 0, y: 0, width: imgWidth!, height: imgHight!)
        disUser.backgroundColor = UIColor .clear
        disUser.clipsToBounds = true
        self.leftViewMode = .always
        disUser.isUserInteractionEnabled = true
        view.addSubview(disUser)
        self.leftView = view
    }
    func setEyeImagetoPasswordFields(imgname: String,imgWidth:CGFloat?=24,imgHeight:CGFloat?=24){
        self.rightViewMode = .always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imgWidth!, height: imgHeight!))
        
        let image = UIImage(systemName: imgname)
        
        imageView.image = image
        imageView.tintColor=UIColor.black
        let tap=UITapGestureRecognizer(target: self, action: #selector(self.tapbutton))
        imageView.isUserInteractionEnabled=true
        imageView.addGestureRecognizer(tap)
        imageView.tag=1
        
        self.rightView = imageView

    }
    
    //Set image on right of textfield
    func rightImage(name: String){
        
        self.rightViewMode = .always
    
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        let image = UIImage(systemName: name)
        
        imageView.image = image
        imageView.tintColor=UIColor.black
        self.rightView = imageView
        
    }
    
    
    @objc func tapbutton(){
        if self.isSecureTextEntry==true{
            self.isSecureTextEntry=false
            self.setEyeImagetoPasswordFields(imgname: "eye")
        }
        else{
            self.isSecureTextEntry=true
            self.setEyeImagetoPasswordFields(imgname: "eye.slash")
        }
        
    }
    
    

}
extension DateFormatter {
    static let today: DateFormatter = {
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
        
    }()
}
