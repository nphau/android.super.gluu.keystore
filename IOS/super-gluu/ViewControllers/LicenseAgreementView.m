//
//  LicenseAgreementView.m
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/2/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "LicenseAgreementView.h"
#import "Constants.h"
#import "PinCodeViewController.h"
#import "NSMutableAttributedString+Color.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "SCLAlertView.h"

#define LICENSE_AGREEMENT @"LicenseAgreement"
#define MAIN_VIEW @"MainTabView"
#define PIN_VIEW @"PinCodeID"

#define IS_FIRST_LOAD @"firstLoad"

@implementation LicenseAgreementView

-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self initWiget];
    [self initLocalization];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(checkLicenseAgreement) withObject:nil afterDelay:0.1];
}

-(void)initWiget{
    [_titleLabel setHidden:YES];
    [_licenseTextField setHidden:YES];
    [_acceptButtonView setHidden:YES];
    
    [[_acceptButton layer] setMasksToBounds:YES];
    [[_acceptButton layer] setCornerRadius:CORNER_RADIUS];
    [[_acceptButton layer] setBorderWidth:2.0f];
    [[_acceptButton layer] setBorderColor:[UIColor colorWithRed:1/255.0 green:161/255.0 blue:97/255.0 alpha:1.0].CGColor];
    [self colorHashtag];
}

-(void)initLocalization{
    [_titleLabel setText:NSLocalizedString(@"LicenseAgreementTitle", @"License Agreement")];
    [_acceptButton setTitle:NSLocalizedString(@"AcceptButtonTitle", @"Accept") forState:UIControlStateNormal];
}

-(void)colorHashtag
{
    NSString *licenceText = _licenseTextField.text;
    if (licenceText == nil) return;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:licenceText];
    [string setColorForText:@"https://www.gluu.org/privacy-policy/" withColor:[UIColor blueColor]];
    _licenseTextField.attributedText = string;
}

-(IBAction)onLicenseAgreement:(id)sender{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LICENSE_AGREEMENT];
    [self checkPinProtection];
}

-(void)checkLicenseAgreement{
    BOOL isLicenseAgreement = [[NSUserDefaults standardUserDefaults] boolForKey:LICENSE_AGREEMENT];
    if (isLicenseAgreement){
        [self checkPinProtection];
    } else {
        [_titleLabel setHidden:NO];
        [_licenseTextField setHidden:NO];
        [_acceptButtonView setHidden:NO];
    }
}

-(void)checkPinProtection{
    BOOL isTouchID = [[NSUserDefaults standardUserDefaults] boolForKey:TOUCH_ID_ENABLED];
    if (isTouchID){
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
                                        [self loadMainView];
                                    } else {
                                        // User did not authenticate successfully, look at error and take appropriate action
                                    }
                                }];
        } else {
            // Could not evaluate policy; look at authError and present an appropriate message to user
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            //[[UIApplication sharedApplication] openURL:[NSURL
            [alert addButton:@"Ok" actionBlock:^(void) {
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            NSString* message  = [NSString stringWithFormat:@"%@ Please add fingerprint in TouchID&Passcode settings", [authError.userInfo valueForKey:@"NSLocalizedDescription"]];
            [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:NSLocalizedString(@"Info", @"Info") subTitle:message closeButtonTitle:nil duration:0.0f];
        }
    } else {
        BOOL isFirstLoad = [[NSUserDefaults standardUserDefaults] boolForKey:IS_FIRST_LOAD];
        if (!isFirstLoad){
            [self loadPinView];
            //[self performSegueWithIdentifier:PIN_VIEW sender:self];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_FIRST_LOAD];
        } else {
            BOOL isPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_PROTECTION_ID];
            if (isPin){
                [self loadPinView];
                //            [self performSegueWithIdentifier:PIN_VIEW sender:self];
            } else {
                [self loadMainView];
                //            [self performSegueWithIdentifier:MAIN_VIEW sender:self];
            }
        }
    }
}

-(void)loadPinView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PinCodeViewController* pinView = [storyboard instantiateViewControllerWithIdentifier:@"PinCodeViewID"];
    [self presentViewController:pinView animated:YES completion:nil];
}

-(void)loadMainView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController* tabBar = [storyboard instantiateViewControllerWithIdentifier:@"MainTabNavigationID"];
//    [tabBar setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:tabBar animated:YES completion:nil];
}

@end
