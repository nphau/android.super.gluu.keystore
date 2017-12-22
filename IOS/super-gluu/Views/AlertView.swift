//
//  AlertView.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/19/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit

class AlertView: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    // MARK: – Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //        button.tintColor = UIColor.ApartmentButler.orange
        
        textLabel.font = UIFont.bold(13.0)
        
    }

}
