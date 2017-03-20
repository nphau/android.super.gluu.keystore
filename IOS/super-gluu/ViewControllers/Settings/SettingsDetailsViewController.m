//
//  SettingsDetailsViewController.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/20/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "SettingsDetailsViewController.h"
#import "JTMaterialSwitch.h"

@interface SettingsDetailsViewController (){

    JTMaterialSwitch *customSwitch;
}

@end

@implementation SettingsDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkSetting];
}

- (void)checkSetting{
    BOOL settingStatus = [[NSUserDefaults standardUserDefaults] boolForKey:_settingKey];
    [_settingSwitch setOn:settingStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
