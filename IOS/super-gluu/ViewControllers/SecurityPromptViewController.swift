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
    
    class func hasSeenNotificationPrompt() -> Bool {
        return UserDefaults.standard.bool(forKey: GluuConstants.NOTIFICATION_PROMPT)
    }
    
    class func setNotificationPrompt() {
        UserDefaults.standard.set(true, forKey: GluuConstants.NOTIFICATION_PROMPT)
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
    
    func setupDisplay() {
        
        title = "Add Secure Entry"
        
        view.backgroundColor = UIColor.Gluu.tableBackground
        
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
        
        navigationController?.pushViewController(passcodeVC, animated: true)
        
    }
    
    func dismissVC() {
        
        GluuUserDefaults.setSecurityPromptShown()
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - PAPasscodeViewController Delegate

extension SecurityPromptViewController: PAPasscodeViewControllerDelegate {
    
    func paPasscodeViewControllerDidSetPasscode(_ controller: PAPasscodeViewController!) {
        
        GluuUserDefaults.setUserPin(newPin: controller.passcode)
        
        self.dismissVC()
        
    }
    
    
    
}
