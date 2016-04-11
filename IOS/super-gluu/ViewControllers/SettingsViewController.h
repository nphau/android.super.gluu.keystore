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
#import "CustomIOSAlertView.h"

@interface SettingsViewController : UIViewController <PAPasscodeViewControllerDelegate, CustomIOSAlertViewDelegate, UIScrollViewDelegate>{

    IBOutlet UIScrollView* scrollView;
    IBOutlet UISwitch* pinCodeType;
    IBOutlet UISwitch* pinCodeTurnOnOff;
    IBOutlet UIView* pinCodeTurnOnOffView;
    IBOutlet UIView* pinCodeTypeView;
    IBOutlet UIButton* setChangePinCode;
    IBOutlet UIView* attemptsView;
    IBOutlet UILabel* attemptsLabel;
    IBOutlet UIStepper* attemptsStepper;
    IBOutlet UILabel* attemptsTextLabel;
    
    JTMaterialSwitch *jswTurnOnOff;
    
    NSString* code;
    
    BOOL isPin;
    BOOL isSimple;
    BOOL isLandScape;
    
    int countFailedPin;
    
}

@end
