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

@implementation LicenseAgreementView{
    UIAlertController * alert;
    
    BOOL isSucess;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self initWiget];
    [self initLocalization];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLicenseAgreement) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    [self performSelector:@selector(checkLicenseAgreement) withObject:nil afterDelay:0.1];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if (isTouchID && !isSucess){
        LAContext *myContext = [[LAContext alloc] init];
        NSError *authError = nil;
        NSString *myLocalizedReasonString = @"Please authenticate with your fingerprint to continue.";
        [alert dismissViewControllerAnimated:YES completion:nil];
        if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
            [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                      localizedReason:myLocalizedReasonString
                                reply:^(BOOL success, NSError *error) {
                                    if (success) {
                                        // User authenticated successfully, take appropriate action
                                        NSLog(@"User authenticated successfully, take appropriate action");
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        isSucess = YES;
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self loadMainView];
                                        });
                                    } else {
                                        // User did not authenticate successfully, look at error and take appropriate action
                                        [self showTouchIDErrorMessage];
                                        isSucess = NO;
                                    }
                                }];
        } else {
            // Could not evaluate policy; look at authError and present an appropriate message to user
            [self showTiuchIDResultError:authError];
            isSucess = NO;
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

-(void)showTouchIDErrorMessage{
    alert = [UIAlertController
                                 alertControllerWithTitle:@"TouchID Failed"
                                 message:@"Wrong fingerprint, if biometric locked go to TouchID&Passcode settings and reactive it"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showTiuchIDResultError:(NSError*) authError{
    NSString* message  = [NSString stringWithFormat:@"%@ Please add fingerprint in TouchID&Passcode settings", [authError.userInfo valueForKey:@"NSLocalizedDescription"]];
    alert = [UIAlertController
                                 alertControllerWithTitle:@"TouchID Failed"
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Ok, thanks"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)loadPinView{
    [self performSegueWithIdentifier:@"pinViewSegue" sender:self];
}

-(void)loadMainView{
    [self performSegueWithIdentifier:@"mainViewSegue" sender:self];
}

@end
