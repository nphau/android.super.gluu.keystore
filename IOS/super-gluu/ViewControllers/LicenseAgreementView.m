//
//  LicenseAgreementView.m
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/2/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "LicenseAgreementView.h"
#import "Constants.h"

#define LICENSE_AGREEMENT @"LicenseAgreement"
#define MAIN_VIEW @"MainTabView"
#define PIN_VIEW @"PinCodeID"

#define IS_FIRST_LOAD @"firstLoad"

@implementation LicenseAgreementView

-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self initWiget];
    [self initLocalization];
    
    //Location services
//    locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
//    [locationManager startUpdatingLocation];
//    [locationManager requestWhenInUseAuthorization];
    
    [self performSelector:@selector(checkLicenseAgreement) withObject:nil afterDelay:0.01];
}

-(void)initWiget{
    [[_acceptButton layer] setMasksToBounds:YES];
    [[_acceptButton layer] setCornerRadius:CORNER_RADIUS];
    [[_acceptButton layer] setBorderWidth:2.0f];
    [[_acceptButton layer] setBorderColor:[UIColor colorWithRed:1/255.0 green:161/255.0 blue:97/255.0 alpha:1.0].CGColor];
}

-(void)initLocalization{
    [_titleLabel setText:NSLocalizedString(@"LicenseAgreementTitle", @"License Agreement")];
    [_acceptButton setTitle:NSLocalizedString(@"AcceptButtonTitle", @"Accept") forState:UIControlStateNormal];
}

-(IBAction)onLicenseAgreement:(id)sender{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LICENSE_AGREEMENT];
    [self checkPinProtection];
}

-(void)checkLicenseAgreement{
    BOOL isLicenseAgreement = [[NSUserDefaults standardUserDefaults] boolForKey:LICENSE_AGREEMENT];
    if (isLicenseAgreement){
        [self checkPinProtection];
    }
}

-(void)checkPinProtection{
    BOOL isFirstLoad = [[NSUserDefaults standardUserDefaults] boolForKey:IS_FIRST_LOAD];
    if (!isFirstLoad){
        [self performSegueWithIdentifier:PIN_VIEW sender:self];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_FIRST_LOAD];
    } else {
        BOOL isPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_PROTECTION_ID];
        if (isPin){
            [self performSegueWithIdentifier:PIN_VIEW sender:self];
        } else {
            [self performSegueWithIdentifier:MAIN_VIEW sender:self];
        }
    }
}

@end
