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
#import <CoreBluetooth/CoreBluetooth.h>
#import "Super_Gluu-Swift.h"

@interface BLEDevicesViewController () <CBCentralManagerDelegate> {

    JTMaterialSwitch *customSwitch;
    PeripheralScanner* scanner;
    CBCentralManager *bluetoothManager;
}

@end

@implementation BLEDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWidget];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidPairPeritheral:) name:DID_UPDATE_VALUE_FOR_PAIRING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidPairPeritheral:) name:@"didConnectPeripheral" object:nil];

}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initWidget{
    //Init custom uiSwitch
    BOOL settingStatus = [[NSUserDefaults standardUserDefaults] boolForKey:SECURE_CLICK_ENABLED];
    customSwitch = [[JTMaterialSwitch alloc] init];
    customSwitch.center = CGPointMake(_settingsSwitch.center.x, _settingsSwitch.center.y + _settingsTitleLabel.center.y + _settingsTitleLabel.center.y/2 + 5);
    [customSwitch setOn:settingStatus animated:YES];
    _infoView.hidden = !settingStatus;
    [customSwitch addTarget:self action:@selector(onSecureClickSelected:) forControlEvents:UIControlEventValueChanged];
    _settingsSwitch.hidden = YES;
    topView.backgroundColor = [[AppConfiguration sharedInstance] systemColor];
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
    jtSwitch.thumbOnTintColor = [[AppConfiguration sharedInstance] systemColor];
    jtSwitch.thumbOffTintColor = [UIColor grayColor];
    jtSwitch.trackOnTintColor = [UIColor greenColor];
    jtSwitch.trackOffTintColor = [UIColor grayColor];
}

-(void)updateUI{
    _infoView.hidden = !customSwitch.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:customSwitch.isOn forKey:SECURE_CLICK_ENABLED];
}

-(void)onSecureClickSelected:(id)sender{
//    JTMaterialSwitch *sw = sender;
    [self initSwitchTurnOnOff:customSwitch];
    
    if (customSwitch.isOn){
        [self checkBluetooth];
    }
    [self updateUI];
}

-(void)checkBluetooth{
    bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self
                                                            queue:nil
                                                          options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                forKey:CBCentralManagerOptionShowPowerAlertKey]];
}

-(void)startBLEScanner{
    scanner = [[PeripheralScanner alloc] init];
    scanner.isPairing = YES;
    [scanner start];
    
    [self updateUI];
}

-(void)notificationDidPairPeritheral:(NSNotification*)notification{
    NSDictionary* notificationDic = [notification object];
    NSString* u2fDeviceName = [notificationDic valueForKey:@"peripheralName"];
    [self showAlertViewWithTitle:@"BLE u2f device" andText:[NSString stringWithFormat:@"%@ already added to BLE devices list", u2fDeviceName]];
}

-(void)showAlertViewWithTitle:(NSString*)title andText:(NSString*)text{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:@"Close" actionBlock:^(void) {
        NSLog(@"Closed alert");
    }];
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:text closeButtonTitle:nil duration:3.0f];
}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // This delegate method will monitor for any changes in bluetooth state and respond accordingly
    NSString *stateString = nil;
    switch(bluetoothManager.state)
    {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off. Please turn on in Settings."; break;
        case CBCentralManagerStatePoweredOn:
            [self startBLEScanner];
            [self updateUI];
            break;
        default: stateString = @"State unknown, update imminent."; break;
    }
    
    if (stateString == nil){return;}
    NSLog(@"Bluetooth State: %@",stateString);
    [self showAlertViewWithTitle:@"BLE manager" andText:stateString];
    [customSwitch setOn:NO animated:YES];
    [self updateUI];
}

@end
