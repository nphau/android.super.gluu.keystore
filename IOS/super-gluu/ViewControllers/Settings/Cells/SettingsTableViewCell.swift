//
//  SettingsTableViewCell.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/4/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import Foundation
import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        titleLabel.text = nil
        iconImageView.image = nil
        
    }

    override func prepareForReuse() {
        
        titleLabel.text = nil
        iconImageView.image = nil
        
    }


}
