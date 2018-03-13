//
//  SwiftMessages+Extension.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/19/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import Foundation
import SwiftMessages

enum MessageType {
    case success
    case error
}

enum MessageDuration: TimeInterval {
    case short  = 5.0
    case medium = 7.5
    case long   = 10.0
}

extension SwiftMessages {
    
    class func show(_ type: MessageType, message: String) {
        
        do {
            
            let view: AlertView          = try SwiftMessages.viewFromNib()
            view.textLabel.text            = message
            
//            view.button.touched = {
//                SwiftMessages.hideAll()
//            }
            
            var config                     = SwiftMessages.Config()
            config.presentationStyle       = .top
            config.presentationContext     = .window(windowLevel: UIWindowLevelNormal)
            config.interactiveHide         = true
            config.preferredStatusBarStyle = .`default`
            
            SwiftMessages.show(config: config, view: view)
            
        } catch {
            
        }
        
        
    }
    
//    class func show(error: Error = APIError.message("There was an error. Please try again.")) {
//        
//        if let error = error as? APIError {
//            
//            switch error {
//            case .message(let string):
//                show(.error, message: string)
//                
//            case .paymentMethodRequired:
//                show(.error, message: "There was an error. Please try again.")
//            }
//            
//        } else {
//            
//            show(.error, message: "There was an error. Please try again.")
//            
//        }
//        
//    }
    
    class func show(_ type: MessageType, presentationStyle: PresentationStyle = .top, duration: MessageDuration = .short, message: String, dismissed: (() -> Void)?) {
        
        do {
            
            let view: AlertView          = try SwiftMessages.viewFromNib()
            view.textLabel.text            = message
            
//            view.button.touched = {
//                SwiftMessages.hideAll()
//            }
            
            var config                     = SwiftMessages.Config()
            config.presentationStyle       = presentationStyle
            config.presentationContext     = .window(windowLevel: UIWindowLevelNormal)
            config.interactiveHide         = true
            config.preferredStatusBarStyle = .default
            config.duration                = Duration.seconds(seconds: duration.rawValue)
            
            config.eventListeners.append() { event in
                if case .willHide = event {
                    dismissed?()
                }
            }
            
            SwiftMessages.show(config: config, view: view)
            
        } catch {
            
        }
        
    }
    
}

