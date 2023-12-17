//
//  DayWiseCell.swift
//  WeatherApp
//
//  Created by Athulya Tech on 7/18/23.
//

import UIKit

class DayWiseCell: UICollectionViewCell {
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblHigh: UILabel!
    @IBOutlet weak var lblLow: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() {

            self.backgroundColor = .clear
            
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.translatesAutoresizingMaskIntoConstraints = false
            self.insertSubview(blurEffectView, at: 0)
            
            blurEffectView.layer.cornerRadius = 20
            blurEffectView.clipsToBounds = true
            
            
            let g = self.layoutMarginsGuide
            NSLayoutConstraint.activate([
                // constrain blur view to all 4 sides of contentView
                blurEffectView.topAnchor.constraint(equalTo: g.topAnchor, constant: 0.0),
                blurEffectView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 0.0),
                blurEffectView.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: 0.0),
                blurEffectView.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: 0.0),

            ])
            
        }
}
