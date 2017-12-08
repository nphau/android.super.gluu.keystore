//
//  Color+Extension.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/1/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat? = 1.0) {
        
        let newRed   = CGFloat(Double(red)   / 255.0)
        let newGreen = CGFloat(Double(green) / 255.0)
        let newBlue  = CGFloat(Double(blue)  / 255.0)
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha:alpha ?? 1.0)
        
    }

    struct Gluu {
        
        static let green           = UIColor(red: 0, green: 161, blue: 97)
        static let darkGreyText    = UIColor(red: 123, green: 123, blue: 123)
        static let lightGreyText    = UIColor(red: 180, green: 180, blue: 180)
        static let tableBackground = UIColor(red: 247, green: 247, blue: 247)

    }
}


@objc class Constant: NSObject {
    private override init() {}
    
    class func regularFont(size: Float) -> UIFont { return UIFont.regular(size) }
    class func boldFont()               -> UIFont { return UIFont.bold(16.0) }
    class func mediumFont(size: Float)  -> UIFont { return UIFont.medium(size) }
    
    class func appBlueColor()         -> UIColor { return UIColor.Gluu.green }
    class func appGreenColor()        -> UIColor { return UIColor.Gluu.green }
    class func tableBackgroundColor() -> UIColor { return UIColor.Gluu.tableBackground }
    class func lightGreyTextColor()   -> UIColor { return UIColor.Gluu.lightGreyText }
    class func darkGreyTextColor()    -> UIColor { return UIColor.Gluu.darkGreyText }
    

}
