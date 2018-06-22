//
//  LandingViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 6/21/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit


class LandingViewController: UIViewController {
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // on initial load, prompt user to setup secure entry to app
        
        if GluuUserDefaults.hasSeenSecurityPrompt() == false {
            showSecurityPrompt()
        } else if GluuUserDefaults.hasTouchAuthEnabled() == true || GluuUserDefaults.userPin() != nil {
            showSecureEntry()
        } else {
            showMainScreen()
        }

    }
    
    // MARK: - Action Handling
    
    @IBAction func unwindFromSecurityPrompt(sender: UIStoryboardSegue) {
        showMainScreen()
    }
    
    @IBAction func unwindFromSecureEntry(sender: UIStoryboardSegue) {
        showMainScreen()
    }
    
    
    // MARK: - Navigation
    
    func showSecurityPrompt() {
        performSegue(withIdentifier: "segueToSecurityPrompt", sender: nil)
    }
    
    func showSecureEntry() {
        performSegue(withIdentifier: "segueToSecureEntry", sender: nil)
    }
    
    func showMainScreen() {
        let mainNavVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = mainNavVC
    }
}

