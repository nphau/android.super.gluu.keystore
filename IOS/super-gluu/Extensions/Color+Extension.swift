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
        static let lightGreyText   = UIColor(red: 180, green: 180, blue: 180)
        static let separator       = UIColor(red: 210, green: 210, blue: 210)
        static let tableBackground = UIColor(red: 247, green: 247, blue: 247)

    }
}

struct GluuConstants {
    
    static let PIN_PROTECTION_ID = "enabledPinCode"
    static let PIN_SIMPLE_ID = "simplePinCode"
    static let PIN_CODE = "PinCode"
    static let PIN_ENABLED = "PinCodeEnabled"
    static let PIN_TYPE_IS_4_DIGIT = "is_4_digit"
    static let SSL_ENABLED = "is_ssl_enabled"
    static let TOUCH_ID_ENABLED = "is_touchID_enabled"
    static let SECURE_CLICK_ENABLED = "secure_click_enabled"
    static let IS_FIRST_LOAD = "firstLoad"
    static let SECURITY_PROMPT_SHOWN = "securityPromptyShown"
    static let NOTIFICATION_PROMPT = "notificationPrompt"
    
}


@objc class Constant: NSObject {
    private override init() {}
    
    class func regularFont(size: Float) -> UIFont { return UIFont.regular(size) }
    class func boldFont()               -> UIFont { return UIFont.bold(16.0) }
    class func mediumFont(size: Float)  -> UIFont { return UIFont.medium(size) }
    
    class func appBlueColor()         -> UIColor { return UIColor.Gluu.green }
    class func appGreenColor()        -> UIColor { return UIColor.Gluu.green }
    class func tableBackgroundColor() -> UIColor { return UIColor.Gluu.tableBackground }
    class func cellSeparatorColor()   -> UIColor { return UIColor.Gluu.separator }
    class func lightGreyTextColor()   -> UIColor { return UIColor.Gluu.lightGreyText }
    class func darkGreyTextColor()    -> UIColor { return UIColor.Gluu.darkGreyText }
    
    class func pinProtectionId()      -> String { return GluuConstants.PIN_PROTECTION_ID }
    class func pinSimpleId()          -> String { return GluuConstants.PIN_SIMPLE_ID }
    class func pinCode()              -> String { return GluuConstants.PIN_CODE }
    class func isPinEnabled()         -> String { return GluuConstants.PIN_ENABLED }
    class func isPinType4Digit()      -> String { return GluuConstants.PIN_TYPE_IS_4_DIGIT }
    class func isSSLEnabled()         -> String { return GluuConstants.SSL_ENABLED }
    class func isTouchIdEnabled()     -> String { return GluuConstants.TOUCH_ID_ENABLED }
    class func isSecureClickEnabled() -> String { return GluuConstants.SECURE_CLICK_ENABLED }
    class func isFirstLoad()          -> String { return GluuConstants.IS_FIRST_LOAD }
    class func securityPromptShown()  -> String { return GluuConstants.SECURITY_PROMPT_SHOWN }
    class func notificationPrompt()   -> String { return GluuConstants.NOTIFICATION_PROMPT }
    
}

@objc class AlertV: NSObject {
    
    private override init() {}
    
    
//    class func alertViewWithCloseButton(yesOrNo: Bool) -> SCLAlertView {
//
//        let appearance = SCLAlertView.SCLAppearance(
//            showCloseButton: yesOrNo
//        )
//
//        let alert = SCLAlertView(appearance: appearance)
//
//        return alert
//
//    }
    
//    - (void)showAlertViewWithTitle:(NSString*)title andMessage:(NSString*)message {
//
//    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//
//
//    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:title subTitle:message closeButtonTitle:@"Close" duration:2.0f];
//
//    }
    
}
