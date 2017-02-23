//
//  SettingsViewController.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/17/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"
#import "PinCodeViewController.h"
#import "NSDate+NetworkClock.h"
#import "SCLAlertView.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface SettingsViewController (){
    JTMaterialSwitch *jswStatus;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_PROTECTION_ID];
    isSSL = [[NSUserDefaults standardUserDefaults] boolForKey:SSL_ENABLED];
    isTouchID = [[NSUserDefaults standardUserDefaults] boolForKey:TOUCH_ID_ENABLED];
    [setChangePinCode setHidden:!isPin];
    code = [[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE];
    if (code == nil || [code isEqualToString:@""]){
        [setChangePinCode setTitle:NSLocalizedString(@"SetPinCode", @"SetPinCode") forState:UIControlStateNormal];
    } else {
        [setChangePinCode setTitle:NSLocalizedString(@"ChangePinCode", @"ChangePinCode") forState:UIControlStateNormal];
    }
    [self initWidget];
//    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    countFailedPin=0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPushView) name:NOTIFICATION_PUSH_ONLINE object:nil];
    
    sslViewCenter = trustOnOffView.center;
}

-(void)initPushView{
    [self.tabBarController setSelectedIndex:0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkDeviceOrientation];
}

-(void)initWidget{
    //Init custom uiswitch
    jswStatus = [[JTMaterialSwitch alloc] init];
    jswStatus.center = [touchIDSwitch center];
    [jswStatus setOn:isTouchID animated:YES];
    [jswStatus addTarget:self action:@selector(onTouchIDSelected:) forControlEvents:UIControlEventValueChanged];
    touchIDSwitch.hidden = YES;
    if (!isTouchID){
        jswStatus.thumbOnTintColor = [UIColor grayColor];
        jswStatus.thumbOffTintColor = [UIColor grayColor];
        jswStatus.trackOnTintColor = [UIColor grayColor];
        jswStatus.trackOffTintColor = [UIColor grayColor];
    } else {
        [self initSwitchTurnOnOff:jswStatus];
    }
    [touchIDView addSubview:jswStatus];
    
    jswTurnOnOff = [[JTMaterialSwitch alloc] init];
    jswTurnOnOff.center = [pinCodeTurnOnOff center];
    [jswTurnOnOff addTarget:self action:@selector(onPinCodeTurnOnOf:) forControlEvents:UIControlEventValueChanged];
    pinCodeTurnOnOff.hidden = YES;
    [jswTurnOnOff setOn:isPin animated:YES];
    if (!isPin){
        jswTurnOnOff.thumbOnTintColor = [UIColor grayColor];
        jswTurnOnOff.thumbOffTintColor = [UIColor grayColor];
        jswTurnOnOff.trackOnTintColor = [UIColor grayColor];
        jswTurnOnOff.trackOffTintColor = [UIColor grayColor];
    } else {
        [self initSwitchTurnOnOff:jswTurnOnOff];
    }
    [pinCodeTurnOnOffView addSubview:jswTurnOnOff];
    
    //Set Switch for SSL Connections
    JTMaterialSwitch *sslSwitchStatus = [[JTMaterialSwitch alloc] init];
    sslSwitchStatus.center = [trustOnOff center];
    [sslSwitchStatus setOn:isSSL animated:YES];
    [sslSwitchStatus addTarget:self action:@selector(onSSLSelected:) forControlEvents:UIControlEventValueChanged];
    trustOnOff.hidden = YES;
    trustTextLabel.hidden = !isSSL;
    if (!isSSL){
        sslSwitchStatus.thumbOnTintColor = [UIColor grayColor];
        sslSwitchStatus.thumbOffTintColor = [UIColor grayColor];
        sslSwitchStatus.trackOnTintColor = [UIColor grayColor];
        sslSwitchStatus.trackOffTintColor = [UIColor grayColor];
    } else {
        [self initSwitchTurnOnOff:sslSwitchStatus];
    }
    [trustOnOffView addSubview:sslSwitchStatus];
    
    [[setChangePinCode layer] setMasksToBounds:YES];
    [[setChangePinCode layer] setCornerRadius:CORNER_RADIUS];
    [[setChangePinCode layer] setBorderWidth:2.0f];
    [[setChangePinCode layer] setBorderColor:[UIColor colorWithRed:57/255.0 green:127/255.0 blue:255/255.0 alpha:1.0].CGColor];
    
    int count = (int)[[NSUserDefaults standardUserDefaults] integerForKey:LOCKED_ATTEMPTS_COUNT];
    if (count > 0){
        attemptsLabel.text = [NSString stringWithFormat:@"%i", count];
    }
    attemptsTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"AttemptsText", @"App will be locked for X minutes after this many failed attempts")];
}

-(void)checkDeviceOrientation{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void) initSwitchTurnOnOff:(JTMaterialSwitch*) jtSwitch {
    jtSwitch.thumbOnTintColor = CUSTOM_GREEN_COLOR;
    jtSwitch.thumbOffTintColor = [UIColor grayColor];
    jtSwitch.trackOnTintColor = [UIColor greenColor];
    jtSwitch.trackOffTintColor = [UIColor grayColor];
}

-(void)onPinCodeTurnOnOf:(id)sender{
    [self initSwitchTurnOnOff:jswTurnOnOff];
    JTMaterialSwitch *sw = sender;
    touchIDView.center = sw.isOn ? CGPointMake(attemptsView.center.x, attemptsView.center.y+ attemptsView.frame.size.height/2 + 50) : CGPointMake(trustOnOffView.center.x, pinCodeButtonView.center.y+10);
    trustOnOffView.center = sw.isOn ? CGPointMake(touchIDView.center.x, touchIDView.center.y+ attemptsView.frame.size.height/2 + 20) : CGPointMake(trustOnOffView.center.x, pinCodeButtonView.center.y+70);
    [setChangePinCode setHidden:!sw.isOn];
    [attemptsView setHidden:!sw.isOn];
    code = [[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE];
    if (code == nil || [code isEqualToString:@""]){
        [setChangePinCode setTitle:NSLocalizedString(@"SetPinCode", @"SetPinCode") forState:UIControlStateNormal];
    } else {
        [setChangePinCode setTitle:NSLocalizedString(@"ChangePinCode", @"ChangePinCode") forState:UIControlStateNormal];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:PIN_PROTECTION_ID];
}

-(void)onPinCodeTypeSelected:(id)sender{
    JTMaterialSwitch *sw = sender;
    [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:PIN_SIMPLE_ID];
}

-(void)onSSLSelected:(id)sender{
    JTMaterialSwitch *sw = sender;
    [self initSwitchTurnOnOff:sw];
    trustTextLabel.hidden = !sw.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:SSL_ENABLED];
}

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
                                    if (success) {
                                        // User authenticated successfully, take appropriate action
                                        NSLog(@"User authenticated successfully, take appropriate action");
                                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TOUCH_ID_ENABLED];
                                    } else {
                                        // User did not authenticate successfully, look at error and take appropriate action
                                        [jswStatus setOn:NO animated:YES];
                                        [self showWrongTouchID];
                                    }
                                }];
        } else {
            // Could not evaluate policy; look at authError and present an appropriate message to user
            [self touchIDErrorMessage:authError];
            [jswStatus setOn:NO animated:YES];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TOUCH_ID_ENABLED];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:TOUCH_ID_ENABLED];
    }
}

- (IBAction)changePasscode:(id)sender {
    NSString* title;
    NSString* message;
    BOOL isPinCode;
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
    [alert addButton:NSLocalizedString(@"YES", @"YES") actionBlock:^(void) {
        NSLog(@"YES clicked");
        if ([[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE] != nil){
            [self changePinCode];
        } else {
            [self setPinCode];
        }
    }];
    [alert addButton:NSLocalizedString(@"NO", @"NO") actionBlock:^(void) {
        NSLog(@"NO clicked");
    }];
    [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:title subTitle:message closeButtonTitle:nil duration:0.0f];
}

- (IBAction)attemptsValueChanged:(UIStepper *)sender {
    double value = [sender value];
    
    [attemptsLabel setText:[NSString stringWithFormat:@"%d", (int)value]];
    [[NSUserDefaults standardUserDefaults] setInteger:(int)value forKey:LOCKED_ATTEMPTS_COUNT];
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
            [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:NSLocalizedString(@"Info", @"Info") subTitle:@"You cannot set a new Pin code the same like old" closeButtonTitle:@"Close" duration:0.0f];
        } else {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:NSLocalizedString(@"Info", @"Info") subTitle:@"You have successfully set a new Pin code" closeButtonTitle:@"Close" duration:0.0f];
            [[NSUserDefaults standardUserDefaults] setObject:controller.passcode forKey:PIN_CODE];
        }
    }];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        [[NSUserDefaults standardUserDefaults] setObject:controller.passcode forKey:PIN_CODE];
        [setChangePinCode setTitle:NSLocalizedString(@"ChangePinCode", @"ChangePinCode") forState:UIControlStateNormal];
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

-(void)showPinView{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PinCodeViewController* pinView = [storyboard instantiateViewControllerWithIdentifier:@"PinCodeViewID"];
    [self presentViewController:pinView animated:YES completion:nil];
}

-(void)showAlertView{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:@"Close" actionBlock:^(void) {
        NSLog(@"Closed alert");
        [passcodeViewController showKeyboard];
    }];
    [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:NSLocalizedString(@"Info", @"Info") subTitle:NSLocalizedString(@"LastAttempts", @"LastAttempts") closeButtonTitle:nil duration:0.0f];
    [passcodeViewController hideKeyboard];
}

-(void)showWrongTouchID{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:NSLocalizedString(@"Info", @"Info") subTitle:@"Wrong fingerprint, if biometric locked go to TouchID&Passcode settings and reactive it" closeButtonTitle:@"OK" duration:0.0f];
}

-(void)touchIDErrorMessage:(NSError*)authError{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:@"Ok" actionBlock:^(void) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:NSLocalizedString(@"Info", @"Info") subTitle:[authError.userInfo valueForKey:@"NSLocalizedDescription"] closeButtonTitle:nil duration:0.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orientationChanged:(NSNotification *)notification{
    [pinCodeTurnOnOffView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, pinCodeTurnOnOffView.center.y)];
    [pinCodeButtonView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2-20, pinCodeButtonView.center.y)];
    [attemptsView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2-20, attemptsView.center.y)];
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            //load the portrait view
            if (isLandScape){
                [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.width/2)];
                scrollView.delegate = nil;
                scrollView.scrollEnabled = NO;
                isLandScape = NO;
            }
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            //load the landscape view
            if (!isLandScape){
                [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width, 400)];
                scrollView.delegate = self;
                scrollView.scrollEnabled = YES;
                isLandScape = YES;
            }
            
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
