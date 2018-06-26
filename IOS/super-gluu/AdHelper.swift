//
//  AdHelper.swift
//  Super Gluu
//
//  Created by Eric Webb on 6/25/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import Foundation
import UIKit

@objc class AdHandler: NSObject {
    
    static var shared = AdHandler()
    
    func refreshAdStatus() {
        // if the user has a licensed key, don't show ads
        if GluuUserDefaults.licensedKeys()?.first != nil {
            NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_AD_FREE), object: nil)
        } else {
            if ADSubsriber.sharedInstance().hasValidSubscription() == true {
                NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_AD_FREE), object: nil)
            } else {
                NotificationCenter.default.post(name: Notification.Name(GluuConstants.NOTIFICATION_AD_NOT_FREE), object: nil)
            }
            //        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LICENSED_AD_FREE];
        }
    }
}

