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

@property (nonatomic, assign) NSString *settingKey;


@end
