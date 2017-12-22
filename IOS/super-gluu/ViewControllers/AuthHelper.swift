//
//  AuthHelper.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/19/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import Foundation
import ox_push3

@objc class AuthHelper: NSObject {
    
    static let shared = AuthHelper()
    let oxPushManager = OXPushManager()
    
    var requestDictionary: [AnyHashable : Any]?
    
    private override init() {
        //This prevents others from using the default '()' initializer for this class.
    }
    
    class func sharedInstance() -> AuthHelper {
        return AuthHelper.shared
    }
    
    func approveRequest(completion: @escaping (Bool, String?) -> Void) {
        
        guard let requestDictionary = self.requestDictionary else {
            completion(false, "Missing request info")
            return
        }
        
        oxPushManager.onOxPushApproveRequest(requestDictionary, isDecline: false) { (result, error) in
            if error == nil {
                completion(true, "Success!")
            } else {
                completion(false, error?.localizedDescription)
            }
        }
    }
}
