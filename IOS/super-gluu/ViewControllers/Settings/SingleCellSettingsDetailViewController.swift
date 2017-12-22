//
//  SingleCellSettingsDetailViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/7/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import LocalAuthentication

@objc class TouchIDAuth: NSObject {
    
    let context = LAContext()
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticateUser(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard canEvaluatePolicy() else {
            return
        }
        
        let reason = "Identify yourself!"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
            [unowned self] success, authenticationError in
            
            DispatchQueue.main.async {
                if success {
                    completion(success, nil)
                    //                    self.runSecretCode()
                } else {
                    
                    let message: String
                    
                    switch authenticationError {
                        
                    case LAError.authenticationFailed?:
                        message = "There was a problem verifying your identity."
                    case LAError.userCancel?:
                        message = "You pressed cancel."
                    case LAError.userFallback?:
                        message = "You pressed password."
                    default:
                        message = "Touch ID may not be configured"
                    }
                    
                    completion(false, message)
                    
                }
            }
        }
    }
}

class SingleCellSettingsDetailViewController: UITableViewController {

    enum Display {
        case touchId
        case ssl
        
        var titleAndIcon: (String, UIImage?) {
            switch self {
            case .touchId: return ("Touch ID", #imageLiteral(resourceName: "icon_settings_touchid"))
            case .ssl:     return ("Trust all SSL", #imageLiteral(resourceName: "icon_settings_ssl"))
            }
        }
        
        var footerText: String {
            switch self {
            case .touchId:
                return "When enabled, access to your Super Gluu app will be protected by touch ID."
            case .ssl:
                return "Enable this option only during devlopment. When enabled, Super Gluu will trust self-signed certificates. \n\n If the certificate is signed by a certificate authority (CA) trust all should be disabled."
            }
        }
        
    }
    
    @IBOutlet weak var cell: SettingsTableViewCell!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var authSwitch: UISwitch!
    
    var display: Display = .touchId
    
    let touchAuth = TouchIDAuth()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sizeFooterToFit()
    }
    
    func setupDisplay() {
        
        view.backgroundColor = UIColor.Gluu.tableBackground
        
//        cellTitleLabel.font = UIFont.regular(17)
        cell.titleLabel.text = display.titleAndIcon.0
        
        
        cell.iconImageView?.image = display.titleAndIcon.1
        
        tableView.separatorStyle = .singleLine
        
        footerLabel.font = UIFont.regular(13)
        footerLabel.textColor = UIColor.Gluu.darkGreyText
        footerLabel.text = display.footerText
        
    }
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        switch display {
        case .ssl:
            return
            
        case .touchId:
            
            UserDefaults.standard.set(sender.isOn, forKey: GluuConstants.TOUCH_ID_ENABLED)
            
            
            
            /*
            
            touchAuth.authenticateUser() { [weak self] message in
                
                guard let weakself = self else { return }
                
                if let message = message {
                    // if the completion is not nil show an alert
                    let alertView = UIAlertController(title: "Error",
                                                      message: message,
                                                      preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Darn!", style: .default)
                    alertView.addAction(okAction)
                    weakself.present(alertView, animated: true)
                    
                } else {
                    // User authenticated successfully, take appropriate action
                    print("User authenticated successfully, take appropriate action")
                    UserDefaults.standard.set(true, forKey: GluuConstants.TOUCH_ID_ENABLED)
                    weakself.authSwitch.setOn(true, animated: true)
                    
//                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PIN_PROTECTION_ID];
                    
//                    self.performSegue(withIdentifier: "dismissLogin", sender: self)
                }
            }
 */
        }
    }
    
    func sizeFooterToFit() {
        
        guard let footerView = footerLabel.superview else { return }
        
        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()
        
        let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = footerView.frame
        frame.size.height = height
        footerView.frame = frame
        
        tableView.tableFooterView = footerView
        
    }
    
    
}


// extension

/*
 
 //For TouchID
 -(void)onTouchIDSelected:(id)sender{
 JTMaterialSwitch *sw = sender;
 [self initSwitchTurnOnOff:sw];
 if (sw.isOn){
 LAContext *myContext = [[LAContext alloc] init];
 NSError *authError = nil;
 NSString *myLocalizedReasonString = @"Please authenticate with your fingerprint to continue.";
 
 if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
 [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
 localizedReason:myLocalizedReasonString
 reply:^(BOOL success, NSError *error) {
 dispatch_async(dispatch_get_main_queue(), ^{
 if (success) {
 // User authenticated successfully, take appropriate action
 NSLog(@"User authenticated successfully, take appropriate action");
 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TOUCH_ID_ENABLED];
 [sw setOn:YES animated:YES];
 [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PIN_PROTECTION_ID];
 } else {
 switch (error.code) {
 case LAErrorAuthenticationFailed:
 NSLog(@"Authentication Failed");
 [self showWrongTouchID];
 break;
 
 case LAErrorUserCancel:
 NSLog(@"User pressed Cancel button");
 [self touchIDInfoMessage:@"User pressed Cancel button"];
 break;
 
 case LAErrorUserFallback:
 NSLog(@"User pressed \"Enter Password\"");
 break;
 
 default:
 NSLog(@"Touch ID is not configured");
 [self touchIDInfoMessage:@"Touch ID is not configured"];
 break;
 }
 // User did not authenticate successfully, look at error and take appropriate action
 [sw setOn:YES animated:YES];
 
 }
 });
 }];
 } else {
 // Could not evaluate policy; look at authError and present an appropriate message to user
 [self touchIDErrorMessage:authError];
 [sw setOn:NO animated:YES];
 [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TOUCH_ID_ENABLED];
 }
 } else {
 [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:TOUCH_ID_ENABLED];
 }
 }
 
 -(void)showWrongTouchID{
 SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
 [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:@"Wrong fingerprint, if biometric locked go to TouchID&Passcode settings and reactive it" closeButtonTitle:@"OK" duration:0.0f];
 }
 
 -(void)touchIDErrorMessage:(NSError*)authError{
 SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
 [alert addButton:@"Ok" actionBlock:^(void) {
 //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
 }];
 [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:@"TouchID verification is not available on this device." closeButtonTitle:nil duration:0.0f];//[authError.userInfo valueForKey:@"NSLocalizedDescription"]
 }
 
 -(void)touchIDInfoMessage:(NSString*)message{
 SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
 [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:message closeButtonTitle:@"Ok" duration:0.0f];
 }
 
 */

