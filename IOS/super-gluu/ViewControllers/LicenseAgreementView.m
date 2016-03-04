//
//  LicenseAgreementView.m
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/2/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "LicenseAgreementView.h"
#import "Constants.h"

@implementation LicenseAgreementView

-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self initWiget];
    [self initLocalization];
    
    //Location services
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    [locationManager requestWhenInUseAuthorization];
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

@end
