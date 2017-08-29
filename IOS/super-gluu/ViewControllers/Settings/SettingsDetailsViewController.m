//
//  SettingsDetailsViewController.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/20/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "SettingsDetailsViewController.h"
#import "JTMaterialSwitch.h"
#import "SCLAlertView.h"
#import "PinCodeViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface SettingsDetailsViewController ()<PAPasscodeViewControllerDelegate>{
    
    JTMaterialSwitch *customSwitch;
    PAPasscodeViewController* passcodeViewController;
    int countFailedPin;
    NSString* code;
}

@end

@implementation SettingsDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkSetting];
}

- (void)checkSetting{
    _settingsTitleLabel.text = _settingTitle;
    
    BOOL settingStatus = [[NSUserDefaults standardUserDefaults] boolForKey:_settingKey];
    [_settingSwitch setOn:settingStatus];
    //Init custom uiSwitch
    customSwitch = [[JTMaterialSwitch alloc] init];
    customSwitch.center = CGPointMake(_settingSwitch.center.x, _settingSwitch.center.y + _settingsTitleLabel.center.y + _settingsTitleLabel.center.y/2 - 10);
    [customSwitch setOn:settingStatus animated:YES];
    if ([_settingKey isEqualToString:TOUCH_ID_ENABLED]){
        [customSwitch addTarget:self action:@selector(onTouchIDSelected:) forControlEvents:UIControlEventValueChanged];
    } else {
        [customSwitch addTarget:self action:@selector(onSwitchSelected:) forControlEvents:UIControlEventValueChanged];
    }
    [_setChangePinCode setTitleColor:[[AppConfiguration sharedInstance] systemColor] forState:UIControlStateNormal];
    [_attemptsStepper setTintColor:[[AppConfiguration sharedInstance] systemColor]];
    topView.backgroundColor = [[AppConfiguration sharedInstance] systemColor];
    topIconView.image = [[AppConfiguration sharedInstance] systemIcon];
    _settingSwitch.hidden = YES;
    if (!settingStatus){
        customSwitch.thumbOnTintColor = [UIColor grayColor];
        customSwitch.thumbOffTintColor = [UIColor grayColor];
        customSwitch.trackOnTintColor = [UIColor grayColor];
        customSwitch.trackOffTintColor = [UIColor grayColor];
    } else {
        [self initSwitchTurnOnOff:customSwitch];
    }
    [self.view addSubview:customSwitch];
    [self updateUI];
}

- (void) initSwitchTurnOnOff:(JTMaterialSwitch*) jtSwitch {
    jtSwitch.thumbOnTintColor = [[AppConfiguration sharedInstance] systemColor];
    jtSwitch.thumbOffTintColor = [UIColor grayColor];
    jtSwitch.trackOnTintColor = [UIColor greenColor];
    jtSwitch.trackOffTintColor = [UIColor grayColor];
}

-(void)onSwitchSelected:(id)sender{
    JTMaterialSwitch *sw = sender;
    [self initSwitchTurnOnOff:sw];
    [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:_settingKey];
    
    [self updateUI];
}

- (void)updateUI{
    if ([_settingKey isEqualToString:TOUCH_ID_ENABLED]){
       _infoLabel.text = TOUCH_ID_TEXT([[AppConfiguration sharedInstance] systemTitle]);
    }
    if ([_settingKey isEqualToString:SSL_ENABLED]){
        _infoLabel.text = SSL_ENABLED_TEXT([[AppConfiguration sharedInstance] systemTitle]);
    }
    if ([_settingKey isEqualToString:PIN_PROTECTION_ID]){
        _infoLabel.text = PIN_PROTECTION_TEXT([[AppConfiguration sharedInstance] systemTitle]);
    }
    if ([_settingKey isEqualToString:PIN_PROTECTION_ID]){
        _pinCodeView.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:_settingKey];
        _pinCodeMainView.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:_settingKey];
        code = [[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE];
        if (code == nil || [code isEqualToString:@""]){
            [_setChangePinCode setTitle:NSLocalizedString(@"SetPinCode", @"SetPinCode") forState:UIControlStateNormal];
        } else {
            [_setChangePinCode setTitle:NSLocalizedString(@"ChangePinCode", @"ChangePinCode") forState:UIControlStateNormal];
        }
    } else {
        _pinCodeView.hidden = YES;
        _pinCodeMainView.hidden = YES;
    }
}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

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


//#---------------------- END -------------------------------------

-(void)onPinCodeTurnOnOf:(id)sender{
    JTMaterialSwitch *sw = sender;
//    if (jswStatus.isOn){
//        [sw setOn:!jswStatus.isOn animated:YES];
//        [self initAttamptsViews:sw.isOn];
//        return;
//    }
    [self initSwitchTurnOnOff:sw];
//    [self initAttamptsViews:sw.isOn];
    code = [[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE];
    if (code == nil || [code isEqualToString:@""]){
        [_setChangePinCode setTitle:NSLocalizedString(@"SetPinCode", @"SetPinCode") forState:UIControlStateNormal];
    } else {
        [_setChangePinCode setTitle:NSLocalizedString(@"ChangePinCode", @"ChangePinCode") forState:UIControlStateNormal];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:PIN_PROTECTION_ID];
}

- (IBAction)changePasscode:(id)sender {
    NSString* title;
    NSString* message;
    BOOL isPinCode;
    code = [[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE];
    if (code == nil){
        title = NSLocalizedString(@"SetPinCode", @"SetPinCode");
        message = NSLocalizedString(@"SetPinCodeTitle", @"SetPinCodeTitle");
        isPinCode = NO;
    } else {
        title = NSLocalizedString(@"ChangePinCode", @"ChangePinCode");
        message = NSLocalizedString(@"ChangePinCodeTitle", @"ChangePinCodeTitle");
        isPinCode = YES;
    }
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:NSLocalizedString(@"YES", @"YES") actionBlock:^(void) {
        NSLog(@"YES clicked");
        if ([[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE] != nil){
            [self changePinCode];
        } else {
            [self setPinCode];
        }
    }];
    SCLButton * noButton = [alert addButton:NSLocalizedString(@"NO", @"NO") actionBlock:^(void) {
        NSLog(@"NO clicked");
    }];
    [noButton setDefaultBackgroundColor:[UIColor redColor]];
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:title subTitle:message closeButtonTitle:nil duration:0.0f];
}

-(void)changePinCode{
    passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionChange];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    passcodeViewController.delegate = self;
    passcodeViewController.passcode = code;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:passcodeViewController] animated:YES completion:nil];
}

-(void) setPinCode{
    passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    passcodeViewController.delegate = self;
    passcodeViewController.simple = YES;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:passcodeViewController] animated:YES completion:nil];
}


#pragma mark - PAPasscodeViewControllerDelegate

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        NSString* newPassword = controller.passcode;
        NSString* oldPassword = [[NSUserDefaults standardUserDefaults] objectForKey:PIN_CODE];
        if ([newPassword isEqualToString:oldPassword]){
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:@"You cannot set a new Pin code the same like old" closeButtonTitle:@"Close" duration:0.0f];
        } else {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:@"You have successfully set a new Pin code" closeButtonTitle:@"Close" duration:0.0f];
            [[NSUserDefaults standardUserDefaults] setObject:controller.passcode forKey:PIN_CODE];
        }
    }];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        [[NSUserDefaults standardUserDefaults] setObject:controller.passcode forKey:PIN_CODE];
        [_setChangePinCode setTitle:NSLocalizedString(@"ChangePinCode", @"ChangePinCode") forState:UIControlStateNormal];
    }];
}

- (void)PAPasscodeViewController:(PAPasscodeViewController *)controller didFailToEnterPasscode:(NSInteger)attempts{
    countFailedPin++;
    NSLog(@"Failed enter passcode, count - %i", countFailedPin);
    int attemptsCount = (int)[[NSUserDefaults standardUserDefaults] integerForKey:LOCKED_ATTEMPTS_COUNT];
    if (countFailedPin == attemptsCount-2){
        [self showAlertView];
    }
    if (countFailedPin == attemptsCount){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_APP_LOCKED];
        NSURL *url = [NSURL URLWithString:@"http://www.timeapi.org/utc/now"];
        NSString *str = [[NSString alloc] initWithContentsOfURL:url usedEncoding:nil error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:LOCKED_DATE];//[NSDate date]//[NSDate networkDate]
        [self performSelector:@selector(showPinView) withObject:nil afterDelay:1];
    }
}

- (IBAction)attemptsValueChanged:(UIStepper *)sender {
    double value = [sender value];
    
    [_attemptsLabel setText:[NSString stringWithFormat:@"%d", (int)value]];
    [[NSUserDefaults standardUserDefaults] setInteger:(int)value forKey:LOCKED_ATTEMPTS_COUNT];
}

-(void)showPinView{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"pinViewSegue" sender:self];
}

-(void)showAlertView{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:@"Close" actionBlock:^(void) {
        NSLog(@"Closed alert");
        [passcodeViewController showKeyboard];
    }];
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:NSLocalizedString(@"LastAttempts", @"LastAttempts") closeButtonTitle:nil duration:0.0f];
    [passcodeViewController hideKeyboard];
}

-(void)showAlertViewWithTitle:(NSString*)title andText:(NSString*)text{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:@"Close" actionBlock:^(void) {
        NSLog(@"Closed alert");
        [passcodeViewController showKeyboard];
    }];
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:text closeButtonTitle:nil duration:0.0f];
    [passcodeViewController hideKeyboard];
}


@end
