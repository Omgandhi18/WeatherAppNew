//
//  Fonts.swift
//  JMSCPOS CORPORATE iPAD
//
// 
//

import Foundation
import UIKit

struct AppFontName {
    
    static let Regular          = "Poppins-Regular"
    static let Medium           = "Poppins-Medium"
    static let MediumItalic     = "Poppins-MediumItalic"
    static let Light            = "Poppins-Light"
    static let LightItalic      = "Poppins-LightItalic"
    static let ExtraLight       = "Poppins-ExtraLight"
    static let ExtraLightItalic = "Poppins-ExtraLightItalic"
    static let Bold             = "Poppins-Bold"
    static let BoldItalic       = "Poppins-BoldItalic"
    static let ExtraBold        = "Poppins-ExtraBold"
    static let ExtraBoldItalic  = "Poppins-ExtraBoldItalic"
    static let Italic           = "Poppins-Italic"
    static let Thin             = "Poppins-Thin"
    static let ThinItalic       = "Poppins-ThinItalic"
    static let SemiBold         = "Poppins-SemiBold"
    static let SemiBoldItalic   = "Poppins-SemiBoldItalic"
    static let Black            = "Poppins-Black"
    static let BlackItalic      = "Poppins-BlackItalic"
}

extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {
    static var isOverrided: Bool = false

    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.Regular, size: size)!
    }
    
    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.Bold, size: size)!
    }

    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.Italic, size: size)!
    }

    @objc convenience init(myCoder aDecoder: NSCoder) {
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
                self.init(myCoder: aDecoder)
                return
        }
        var fontName = ""
        switch fontAttribute {
        case "CTFontRegularUsage":
            fontName = AppFontName.Regular
        case "CTFontEmphasizedUsage", "CTFontBoldUsage":
            fontName = AppFontName.Bold
        case "CTFontObliqueUsage":
            fontName = AppFontName.Italic
        case "CTFontUltraLightUsage":
            fontName = AppFontName.ExtraLight
        case "CTFontThinUsage":
            fontName = AppFontName.Thin
        case "CTFontDemiUsage":
            fontName = AppFontName.SemiBold
        case "CTFontLightUsage":
            fontName = AppFontName.Light
        case "CTFontMediumUsage":
            fontName = AppFontName.Medium
        case "CTFontHeavyUsage","CTFontBlackUsage":
            fontName = AppFontName.Black
        default:
            fontName = AppFontName.Regular
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)!
    }

    class func overrideInitialize() {
        guard self == UIFont.self, !isOverrided else { return }

        // Avoid method swizzling run twice and revert to original initialize function
        isOverrided = true

        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }

        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }

        if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:))) {
            method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
        }

        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}


////////////**********************************************************//////////////////////
/*enum FontName: String {
    case Medium         = "Poppins-Medium"
    case Light          = "Poppins-Light"
    case Regular        = "Poppins-Regular"
    case MediumItalic   = "Poppins-MediumItalic"
    case ThinItalic     = "Poppins-ThinItalic"
    case BoldItalic     = "Poppins-BoldItalic"
    case LightItalic    = "Poppins-LightItalic"
    case Italic         = "Poppins-Italic"
    case BlackItalic    = "Poppins-BlackItalic"
    case Bold           = "Poppins-Bold"
    case Thin           = "Poppins-Thin"
    case Black          = "Poppins-Black"
}

func setFontFamilyForView(FontName fontFamily: String, view: UIView, andSubviews: Bool) {
    
    var fontFamily = FontName.Regular.rawValue
    
    if let label = view as? UILabel {
        //        print("------------------------------")
        //        print("Font Family Name = [\(label.font!.fontName)]")
        if label.font?.fontName == ".SFUI-Ultralight"  {
            //                print("true-Ultralight")
            fontFamily = FontName.Light.rawValue
        } else if label.font?.fontName == ".SFUI-Thin"  {
            //                print("true-Thin")
            fontFamily = FontName.Thin.rawValue
        } else if label.font?.fontName == ".SFUI-Light"  {
            //                print("true-Light")
            fontFamily = FontName.Light.rawValue
        } else if label.font?.fontName == ".SFUI-Regular"  {
            //                print("true-Regular")
            fontFamily = FontName.Regular.rawValue
        } else if label.font?.fontName == ".SFUI-Medium"  {
            //                print("true-Medium")
            fontFamily = FontName.Medium.rawValue
        } else if label.font?.fontName == ".SFUI-Semibold"  {
            //                print("true-Semibold")
            fontFamily = FontName.Medium.rawValue
        } else if label.font?.fontName == ".SFUI-Bold"  {
            //            print("true-bold")
            fontFamily = FontName.Bold.rawValue
        } else if label.font?.fontName == ".SFUI-Heavy"  {
            //                print("true-Heavy")
            fontFamily = FontName.Bold.rawValue
        } else if label.font?.fontName == ".SFUI-Black"  {
            //                print("true-Black")
            fontFamily = FontName.Black.rawValue
        } else {
            //                print("true-Regular")
            fontFamily = FontName.Regular.rawValue
        }
        
        label.font = UIFont(name: fontFamily, size: label.font.pointSize)
    }
    
    if let textView = view as? UITextView {
        //            print("------------------------------")
        //            print("Font Family Name = [\(textView.font?.fontName)]")
        if textView.font?.fontName == ".SFUI-Ultralight"  {
            //                print("true-Ultralight")
            fontFamily = FontName.Light.rawValue
        } else if textView.font?.fontName == ".SFUI-Thin"  {
            //                print("true-Thin")
            fontFamily = FontName.Thin.rawValue
        } else if textView.font?.fontName == ".SFUI-Light"  {
            //                print("true-Light")
            fontFamily = FontName.Light.rawValue
        } else if textView.font?.fontName == ".SFUI-Regular"  {
            //                print("true-Regular")
            fontFamily = FontName.Regular.rawValue
        } else if textView.font?.fontName == ".SFUI-Medium"  {
            //                print("true-Medium")
            fontFamily = FontName.Medium.rawValue
        } else if textView.font?.fontName == ".SFUI-Semibold"  {
            //                print("true-Semibold")
            fontFamily = FontName.Medium.rawValue
        } else if textView.font?.fontName == ".SFUI-Bold"  {
            //                print("true-bold")
            fontFamily = FontName.Bold.rawValue
        } else if textView.font?.fontName == ".SFUI-Heavy"  {
            //                print("true-Heavy")
            fontFamily = FontName.Bold.rawValue
        } else if textView.font?.fontName == ".SFUI-Black"  {
            //                print("true-Black")
            fontFamily = FontName.Black.rawValue
        } else {
            //                print("true-Regular")
            fontFamily = FontName.Regular.rawValue
        }
        
        textView.font = UIFont(name: fontFamily, size: textView.font!.pointSize)
    }
    
    if let textField = view as? UITextField {
        //            print("------------------------------")
        //            print("Font Family Name = [\(textField.font?.fontName)]")
        if textField.font?.fontName == ".SFUI-Ultralight"  {
            //                print("true-Ultralight")
            fontFamily = FontName.Light.rawValue
        } else if textField.font?.fontName == ".SFUI-Thin"  {
            //                print("true-Thin")
            fontFamily = FontName.Thin.rawValue
        } else if textField.font?.fontName == ".SFUI-Light"  {
            //                print("true-Light")
            fontFamily = FontName.Light.rawValue
        } else if textField.font?.fontName == ".SFUI-Regular"  {
            //                print("true-Regular")
            fontFamily = FontName.Regular.rawValue
        } else if textField.font?.fontName == ".SFUI-Medium"  {
            //                print("true-Medium")
            fontFamily = FontName.Medium.rawValue
        } else if textField.font?.fontName == ".SFUI-Semibold"  {
            //                print("true-Semibold")
            fontFamily = FontName.Medium.rawValue
        } else if textField.font?.fontName == ".SFUI-Bold"  {
            //                print("true-bold")
            fontFamily = FontName.Bold.rawValue
        } else if textField.font?.fontName == ".SFUI-Heavy"  {
            //                print("true-Heavy")
            fontFamily = FontName.Bold.rawValue
        } else if textField.font?.fontName == ".SFUI-Black"  {
            //                print("true-Black")
            fontFamily = FontName.Black.rawValue
        } else {
            //                print("true-Regular")
            fontFamily = FontName.Regular.rawValue
        }
        
        textField.font = UIFont(name: fontFamily, size: textField.font!.pointSize)
    }
    
    if andSubviews {
        for v in view.subviews {
            setFontFamilyForView(FontName: fontFamily, view: v, andSubviews: true)
        }
    }
} */
