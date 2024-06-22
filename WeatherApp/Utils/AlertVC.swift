//
//  AlertVC.swift
//  WeatherApp
//
//

import UIKit

class AlertVC: UIViewController, UIGestureRecognizerDelegate {

    // CREATED BLOCK FOR SELECTED OBJ
    var onCompletionDone: (() -> Void)?
    var onCompletionClose: (() -> Void)?
    
    
    @IBOutlet weak var vwpopup: UIView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var imgAlert: UIImageView!
    @IBOutlet weak var lblalerttitle: UILabel!
    @IBOutlet weak var lblalertmsg: UILabel!
    @IBOutlet weak var stackvc: UIStackView!
    @IBOutlet weak var btnOther: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var titlehight: NSLayoutConstraint!
    
    
    // MARK: - VARIABLES 
    var isSingleBtn : Bool = false
    var isDissmissView : Bool = false
    var stralerttitle = ""
    var stralertmsg = ""
    var btncanceltitle = ""
    var btnothertitle = ""
    var textAlignment : NSTextAlignment = .left
    var image =  ""
    var backgroundColor = UIColor()
    var otherButtonColor = UIColor()
    var cancelButtonColor = UIColor()
    //===================================================================
    // MARK: - VIEW CONTROLLER LIFE CYCLE
    //===================================================================
    override func viewDidLoad() {
        super.viewDidLoad()

        // For Transference Background
        self.view.backgroundColor = .clear
        
        // SET FONT
      
        
        // SET LOGO
        imgAlert.image = UIImage(systemName: image)


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.lblalerttitle.text = stralerttitle
        self.lblalerttitle.textAlignment = textAlignment
        self.lblalertmsg.text = stralertmsg
        
        btnCancel.setTitle(btncanceltitle, for: .normal)
        btnOther.setTitle(btnothertitle, for: .normal)
        //SET BUTTO COLORS
        btnOther.backgroundColor = otherButtonColor
        btnCancel.backgroundColor = cancelButtonColor
        
        if stralerttitle == "" {
            titlehight.constant = 0
        } else {
            titlehight.constant = 40
        }
        
        if isSingleBtn == true {
            btnCancel.isHidden = true
        } else {
            btnCancel.isHidden = false
        }
        
        if isDissmissView == true {
            tapGestureVW()
        }
        viewBack.layer.cornerRadius=10
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // SET BACKGROUND COLOR
        self.vwpopup.backgroundColor = backgroundColor
    }
    
    //===================================================================
    // MARK: - TAPGESTURE METHODS
    //===================================================================
    func tapGestureVW() {
        // tap gesture view
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    //===================================================================
    // MARK: - UIBUTTON ACTIONS METHODS
    //===================================================================
    @objc func handleTap(_ sender: UITapGestureRecognizer?) {
        dismiss(animated: true)
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        if (onCompletionClose != nil) {
            onCompletionClose!()
        }

    }
    
    @IBAction func btnOtherClicked(_ sender: Any) {
        if (onCompletionDone != nil) {
            onCompletionDone!()
        }
    }
    
}
