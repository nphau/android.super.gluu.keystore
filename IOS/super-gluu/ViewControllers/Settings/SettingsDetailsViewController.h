//
//  SettingsDetailsViewController.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/20/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsDetailsViewController : UIViewController{
    
    IBOutlet UIView* topView;
    IBOutlet UIImageView* topIconView;
}

//Settings title
@property (nonatomic, retain) IBOutlet UILabel *settingsTitleLabel;
//Settings switch
@property (nonatomic, retain) IBOutlet UISwitch *settingSwitch;

@property (nonatomic, assign) NSString *settingTitle;
@property (nonatomic, assign) NSString *settingKey;


//Info Settings
@property (nonatomic, retain) IBOutlet UILabel *infoLabel;

//Pin code additional views
@property (nonatomic, retain) IBOutlet UIView* pinCodeMainView;
@property (nonatomic, retain) IBOutlet UIView* pinCodeView;
@property (nonatomic, retain) IBOutlet UIButton* setChangePinCode;
@property (nonatomic, retain) IBOutlet UILabel* attemptsLabel;
@property (nonatomic, retain) IBOutlet UIStepper* attemptsStepper;

@end
