//
//  SettingsDetailsViewController.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/20/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsDetailsViewController : UIViewController

//Settings title
@property (nonatomic, retain) IBOutlet UILabel *settingsTitleLabel;
//Settings switch
@property (nonatomic, retain) IBOutlet UISwitch *settingSwitch;

@property (nonatomic, assign) NSString *settingTitle;
@property (nonatomic, assign) NSString *settingKey;


//For SSL Settings
@property (nonatomic, retain) IBOutlet UILabel *sslWarningLabel;

//Pin code additional views
@property (nonatomic, retain) IBOutlet UIView* pinCodeView;
@property (nonatomic, retain) IBOutlet UIButton* setChangePinCode;
@property (nonatomic, retain) IBOutlet UILabel* attemptsLabel;
@property (nonatomic, retain) IBOutlet UIStepper* attemptsStepper;

@end
