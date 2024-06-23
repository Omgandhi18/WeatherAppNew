//
//  HelperClass.swift
//  WeatherApp
//
//
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
    //MARK: Default error messages
    case internetConnection         = "The Internet connection appears to be offline."
    case failService                = "Something went wrong. Please try again later !!"
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
    func neumorphicButton(bgColor: UIColor, tintColor: UIColor) {
//        layer.cornerRadius = frame.height / 2
//        layer.shadowColor = UIColor.darkGray.cgColor
//        layer.shadowOffset = CGSize(width: 5, height: 5)
//        layer.shadowOpacity = 0.7
//        layer.shadowRadius = 5
        self.tintColor = tintColor
        layer.backgroundColor = bgColor.cgColor
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
extension Double{
    func celsiusToFahrenheit() -> Self {
       return (self * 9/5) + 32
    }
    func kmToMiles() -> Self{
        return (self * 0.621371)
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
extension UserDefaults {
    static func contains(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
