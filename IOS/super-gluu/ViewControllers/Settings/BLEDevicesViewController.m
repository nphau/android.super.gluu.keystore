//
//  BLEDevicesViewController.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/22/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "BLEDevicesViewController.h"
#import "JTMaterialSwitch.h"
#import "SCLAlertView.h"
#import "Super_Gluu-Swift.h"

@interface BLEDevicesViewController (){

    JTMaterialSwitch *customSwitch;
    PeripheralScanner* scanner;
}

@end

@implementation BLEDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWidget];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidPairPeritheral:) name:DID_UPDATE_VALUE_FOR_PAIRING object:nil];
}

- (void)initWidget{
    //Init custom uiSwitch
    BOOL settingStatus = [[NSUserDefaults standardUserDefaults] boolForKey:SECURE_CLICK_ENABLED];
    customSwitch = [[JTMaterialSwitch alloc] init];
    customSwitch.center = CGPointMake(_settingsSwitch.center.x, _settingsSwitch.center.y + _settingsTitleLabel.center.y + _settingsTitleLabel.center.y/2 + 5);
    [customSwitch setOn:settingStatus animated:YES];
    _infoView.hidden = false;
    [customSwitch addTarget:self action:@selector(onSecureClickSelected:) forControlEvents:UIControlEventValueChanged];
    _settingsSwitch.hidden = YES;
    if (!settingStatus){
        customSwitch.thumbOnTintColor = [UIColor grayColor];
        customSwitch.thumbOffTintColor = [UIColor grayColor];
        customSwitch.trackOnTintColor = [UIColor grayColor];
        customSwitch.trackOffTintColor = [UIColor grayColor];
    } else {
        [self initSwitchTurnOnOff:customSwitch];
    }
    [self.view addSubview:customSwitch];
}

- (void) initSwitchTurnOnOff:(JTMaterialSwitch*) jtSwitch {
    jtSwitch.thumbOnTintColor = CUSTOM_GREEN_COLOR;
    jtSwitch.thumbOffTintColor = [UIColor grayColor];
    jtSwitch.trackOnTintColor = [UIColor greenColor];
    jtSwitch.trackOffTintColor = [UIColor grayColor];
}

-(void)onSecureClickSelected:(id)sender{
    JTMaterialSwitch *sw = sender;
    [self initSwitchTurnOnOff:sw];
    [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:SECURE_CLICK_ENABLED];
//    [self updateUI];
    
    if (sw.isOn){
        scanner = [[PeripheralScanner alloc] init];
        scanner.isPairing = YES;
        [scanner start];
    }
//    _infoView.hidden = !sw.isOn;
}

-(void)notificationDidPairPeritheral:(NSNotification*)notification{
    [self showAlertViewWithTitle:@"BLE device" andText:@"You've succefully paired"];
}

-(void)showAlertViewWithTitle:(NSString*)title andText:(NSString*)text{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:@"Close" actionBlock:^(void) {
        NSLog(@"Closed alert");
    }];
    [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:NSLocalizedString(@"Info", @"Info") subTitle:text closeButtonTitle:nil duration:0.0f];
}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
