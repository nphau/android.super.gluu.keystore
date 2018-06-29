//
//  SecurityPromptViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/14/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit

@objc class GluuUserDefaults: NSObject {
    
    class func userPin() -> String? {
        return UserDefaults.standard.string(forKey: GluuConstants.PIN_CODE)
    }
    
    class func setUserPin(newPin: String) {
        UserDefaults.standard.set(newPin, forKey: GluuConstants.PIN_CODE)
        UserDefaults.standard.set(true, forKey: GluuConstants.PIN_ENABLED)
    }
    
    class func removeUserPin() {
        UserDefaults.standard.removeObject(forKey: GluuConstants.PIN_CODE)
        UserDefaults.standard.set(false, forKey: GluuConstants.PIN_ENABLED)
    }
    
    class func setTouchAuth(isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: GluuConstants.TOUCH_ID_ENABLED)
    }
    
    class func hasTouchAuthEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: GluuConstants.TOUCH_ID_ENABLED)
    }
    
    class func isFirstLoad() -> Bool {
        return UserDefaults.standard.bool(forKey: GluuConstants.IS_FIRST_LOAD)
    }
    
    class func setFirstLoad() {
        UserDefaults.standard.set(true, forKey: GluuConstants.IS_FIRST_LOAD)
    }
    
    class func hasSeenSecurityPrompt() -> Bool {
        return UserDefaults.standard.bool(forKey: GluuConstants.SECURITY_PROMPT_SHOWN)
    }
    
    class func setSecurityPromptShown() {
        UserDefaults.standard.set(true, forKey: GluuConstants.SECURITY_PROMPT_SHOWN)
    }
    
    class func setSubscriptionExpiration(date: Date?) {
        UserDefaults.standard.set(date, forKey: GluuConstants.SUBSCRIPTION_EXPIRY_DATE)
    }
    
    class func subscriptionExpirationDate() -> Date? {
        return UserDefaults.standard.value(forKey: GluuConstants.SUBSCRIPTION_EXPIRY_DATE) as? Date
    }
    
    class func licensedKeys() -> [String]? {
        return UserDefaults.standard.array(forKey: GluuConstants.LICENSED_KEYS) as? [String]
    }
    
    class func saveLicensedKey(_ key: String) {
        var newKeyArray: [String]?
        if var licensedKeys = GluuUserDefaults.licensedKeys() {
            if licensedKeys.contains(key) == false {
                licensedKeys.append(key)
            }
            newKeyArray = licensedKeys
        } else {
            newKeyArray = [key]
        }
        
        UserDefaults.standard.set(newKeyArray, forKey: GluuConstants.LICENSED_KEYS)
        
        AdHandler.shared.refreshAdStatus()
    }
    
    class func removeLicensedKey(_ key: String) {
        
        guard let licensedKeys = GluuUserDefaults.licensedKeys(), licensedKeys.contains(key) else {
            return
        }
        
        let cleanedKeys = licensedKeys.filter({ $0 != key })
        
        UserDefaults.standard.set(cleanedKeys, forKey: GluuConstants.LICENSED_KEYS)
        
        AdHandler.shared.refreshAdStatus()

    }
}


class SecurityPromptViewController: UIViewController {
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var touchStackView: UIStackView?
    @IBOutlet weak var touchButton: UIButton?
    @IBOutlet weak var separatorView: UIView?
    
    let touchAuth = TouchIDAuth()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Add Secure Entry"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.title = " "
    }
    
    func setupDisplay() {
        
        view.backgroundColor = UIColor.Gluu.tableBackground
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white //UIColor.Gluu.green
        navigationController?.navigationBar.barTintColor = UIColor.Gluu.green
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        separatorView?.backgroundColor = UIColor.Gluu.tableBackground
        
        buttonsStackView.superview?.backgroundColor = UIColor.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(dismissVC))
        
        if touchAuth.canEvaluatePolicy() == false {
            touchStackView?.arrangedSubviews.forEach({$0.removeFromSuperview()})
            touchStackView?.removeFromSuperview()
            touchButton?.removeFromSuperview()
            separatorView?.removeFromSuperview()
        }
    }
    
    @IBAction func pinTapped() {
        goToPinEntry()
    }
    
    @IBAction func touchTapped() {
        touchAuth.authenticateUser { (success, errorMessage) in

            GluuUserDefaults.setTouchAuth(isOn: success)
            
            self.dismissVC()
            
        }
    }
    
    func goToPinEntry() {
        guard let passcodeVC = PAPasscodeViewController.init(for: PasscodeActionSet) else {
            return
        }
        
        passcodeVC.delegate = self
        passcodeVC.simple = true
        passcodeVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        
        navigationController?.pushViewController(passcodeVC, animated: true)
        
    }
    
    func dismissVC() {
        
        GluuUserDefaults.setSecurityPromptShown()
        
        performSegue(withIdentifier: "segueUnwindSecurityPromptToLanding", sender: nil)
    }
}

// MARK: - PAPasscodeViewController Delegate

extension SecurityPromptViewController: PAPasscodeViewControllerDelegate {
    
    func paPasscodeViewControllerDidSetPasscode(_ controller: PAPasscodeViewController!) {
        
        GluuUserDefaults.setUserPin(newPin: controller.passcode)
        
        self.dismissVC()
        
    }
    
    
    
}
