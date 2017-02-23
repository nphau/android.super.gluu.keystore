//
//  SettingsViewController.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/17/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTMaterialSwitch.h"
#import "PAPasscodeViewController.h"

@interface SettingsViewController : UIViewController <PAPasscodeViewControllerDelegate, UIScrollViewDelegate>{

    IBOutlet UIScrollView* scrollView;
    IBOutlet UISwitch* pinCodeTurnOnOff;
    IBOutlet UISwitch* trustOnOff;
    IBOutlet UISwitch* touchIDSwitch;
    IBOutlet UILabel* trustTextLabel;
    IBOutlet UIView* pinCodeTurnOnOffView;
    IBOutlet UIView* trustOnOffView;
    IBOutlet UIView* pinCodeButtonView;
    IBOutlet UIView* touchIDView;
    IBOutlet UIButton* setChangePinCode;
    IBOutlet UIView* attemptsView;
    IBOutlet UILabel* attemptsLabel;
    IBOutlet UIStepper* attemptsStepper;
    IBOutlet UILabel* attemptsTextLabel;
    
    JTMaterialSwitch *jswTurnOnOff;
    JTMaterialSwitch *trustAllOnOff;
    JTMaterialSwitch *touchIDOnOff;
    
    NSString* code;
    
    BOOL isPin;
    BOOL isSSL;
    BOOL isTouchID;
    BOOL isLandScape;
    
    CGPoint sslViewCenter;
    
    int countFailedPin;
    
    PAPasscodeViewController *passcodeViewController;
    
}

@end
