//
//  LaunchSetupViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/19/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit

class LaunchSetupViewController: UIViewController {

    // MARK: - Variables
    
    @IBOutlet weak var photoB: UIButton!
    
    let touchAuth = TouchIDAuth()
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // View Setup
    
    func setupDisplay() {
        
    }
    
    func checkSecurity() {
        if GluuUserDefaults.hasTouchAuthEnabled() && touchAuth.canEvaluatePolicy() == true {
            touchAuth.authenticateUser { (success, errorMessage) in
                
//                GluuUserDefaults.setTouchAuth(isOn: success)
                
            }
        } else if GluuUserDefaults.userPin() != nil {
            
        } else {
            // go to main view controller
        }
    }
    
    
    // MARK: - Action Handling
    
    @IBAction func buttonPresses(sender: UIButton) {
    }
    
    
    // MARK: - Navigation
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
}

extension LaunchSetupViewController: PAPasscodeViewControllerDelegate {

    func paPasscodeViewControllerDidCancel(_ controller: PAPasscodeViewController!) {
        <#code#>
    }
    
    func paPasscodeViewControllerDidEnterPasscode(_ controller: PAPasscodeViewController!) {
        <#code#>
    }
}

