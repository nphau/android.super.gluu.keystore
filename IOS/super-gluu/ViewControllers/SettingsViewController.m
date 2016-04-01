//
//  SettingsViewController.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/17/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_PROTECTION_ID];
    [pinCodeTypeView setHidden:!isPin];
    [setChangePinCode setHidden:!isPin];
    isSimple = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SIMPLE_ID];
    code = [[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE];
    if (code == nil || [code isEqualToString:@""]){
        [setChangePinCode setTitle:NSLocalizedString(@"SetPinCode", @"SetPinCode") forState:UIControlStateNormal];
    } else {
        [setChangePinCode setTitle:NSLocalizedString(@"ChangePinCode", @"ChangePinCode") forState:UIControlStateNormal];
        [pinCodeTypeView setHidden:YES];
    }
    [self initWidget];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkDeviceOrientation];
}

-(void)initWidget{
    //Init custom uiswitch
    JTMaterialSwitch *jswStatus = [[JTMaterialSwitch alloc] init];
    jswStatus.center = [pinCodeType center];
    [jswStatus setOn:isSimple animated:YES];
    [jswStatus addTarget:self action:@selector(onPinCodeTypeSelected:) forControlEvents:UIControlEventValueChanged];
    pinCodeType.hidden = YES;
    [self initSwitchProperty:jswStatus];
    [pinCodeTypeView addSubview:jswStatus];
    
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
    
    [[setChangePinCode layer] setMasksToBounds:YES];
    [[setChangePinCode layer] setCornerRadius:CORNER_RADIUS];
    [[setChangePinCode layer] setBorderWidth:2.0f];
    [[setChangePinCode layer] setBorderColor:[UIColor colorWithRed:57/255.0 green:127/255.0 blue:255/255.0 alpha:1.0].CGColor];
    
    int count = (int)[[NSUserDefaults standardUserDefaults] integerForKey:LOCKED_ATTEMPTS_COUNT];
    if (count > 0){
        attemptsLabel.text = [NSString stringWithFormat:@"%i", count];
    }
    attemptsTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"AttemptsText", @"App will be locked for X minutes after this many failed attempts")];
    if (pinCodeTypeView.isHidden){
        [attemptsView setCenter:CGPointMake(pinCodeTypeView.center.x, pinCodeTypeView.center.y + attemptsView.frame.size.height/3)];
    } else {
        [attemptsView setCenter:CGPointMake(pinCodeTypeView.center.x, pinCodeTypeView.center.y + attemptsView.frame.size.height)];
    }
}

-(void)checkDeviceOrientation{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
        //        [self adjustViewsForOrientation:UIInterfaceOrientationLandscapeLeft];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void) initSwitchProperty:(JTMaterialSwitch*) jtSwitch {
    jtSwitch.thumbOnTintColor = CUSTOM_GREEN_COLOR;
    jtSwitch.thumbOffTintColor = CUSTOM_GREEN_COLOR;
    jtSwitch.trackOnTintColor = [UIColor greenColor];
    jtSwitch.trackOffTintColor = [UIColor greenColor];
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
    [setChangePinCode setHidden:!sw.isOn];
    [pinCodeTypeView setHidden:!sw.isOn];
    code = [[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE];
    if (code == nil || [code isEqualToString:@""]){
        [setChangePinCode setTitle:NSLocalizedString(@"SetPinCode", @"SetPinCode") forState:UIControlStateNormal];
    } else {
        [setChangePinCode setTitle:NSLocalizedString(@"ChangePinCode", @"ChangePinCode") forState:UIControlStateNormal];
        [pinCodeTypeView setHidden:YES];
    }
    if (pinCodeTypeView.isHidden){
        [attemptsView setCenter:CGPointMake(pinCodeTypeView.center.x, pinCodeTypeView.center.y + attemptsView.frame.size.height/3)];
    } else {
        [attemptsView setCenter:CGPointMake(pinCodeTypeView.center.x, pinCodeTypeView.center.y + attemptsView.frame.size.height)];
    }
    [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:PIN_PROTECTION_ID];
}

-(void)onPinCodeTypeSelected:(id)sender{
    JTMaterialSwitch *sw = sender;
    [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:PIN_SIMPLE_ID];
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
    CustomIOSAlertView* alertView = [CustomIOSAlertView alertWithTitle:title  message:message];
    [alertView setButtonTitles:[NSArray arrayWithObjects:NSLocalizedString(@"YES", @"YES"), NSLocalizedString(@"NO", @"NO"), nil]];
    [alertView setButtonColors:[NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], nil]];
    alertView.delegate = self;
    [alertView show];
}

- (IBAction)attemptsValueChanged:(UIStepper *)sender {
    double value = [sender value];
    
    [attemptsLabel setText:[NSString stringWithFormat:@"%d", (int)value]];
    [[NSUserDefaults standardUserDefaults] setInteger:(int)value forKey:LOCKED_ATTEMPTS_COUNT];
}

#pragma mark CustomIOS7AlertView Delegate

-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        if ([[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE] != nil){
            [self changePinCode];
        } else {
            [self setPinCode];
        }
    }
    [alertView close];
}


-(void)changePinCode{
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionChange];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    passcodeViewController.delegate = self;
    passcodeViewController.passcode = code;
    passcodeViewController.simple = !isSimple;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:passcodeViewController] animated:YES completion:nil];
}

-(void) setPinCode{
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    passcodeViewController.delegate = self;
    passcodeViewController.simple = YES;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:passcodeViewController] animated:YES completion:nil];
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        [[NSUserDefaults standardUserDefaults] setObject:controller.passcode forKey:PIN_CODE];
    }];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        [[NSUserDefaults standardUserDefaults] setObject:controller.passcode forKey:PIN_CODE];
        [setChangePinCode setTitle:NSLocalizedString(@"ChangePinCode", @"ChangePinCode") forState:UIControlStateNormal];
        [pinCodeTypeView setHidden:YES];
        if (pinCodeTypeView.isHidden){
            [attemptsView setCenter:CGPointMake(pinCodeTypeView.center.x, pinCodeTypeView.center.y)];
        } else {
            [attemptsView setCenter:CGPointMake(pinCodeTypeView.center.x, pinCodeTypeView.center.y + attemptsView.frame.size.height)];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orientationChanged:(NSNotification *)notification{
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
