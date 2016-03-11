//
//  InformationViewController.m
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/9/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "InformationViewController.h"
#import "Constants.h"

@implementation InformationViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupInformation];
    [self initWidget];
    [self initLocalization];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}

-(void)checkDeviceOrientation{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
        //        [self adjustViewsForOrientation:UIInterfaceOrientationLandscapeLeft];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

-(void)setupInformation{
    if (_token != nil){
        applicationValueLabel.text = _token.application;
        issuerValueLabel.text = _token.issuer;
        userNameValueLabel.text = _token.userName;
        createdValueLabel.text = [self convertPairingTime:_token.pairingTime];
        authenticationValueModeLabel.text = _token.authenticationMode;
        authenticationValueTypeLabel.text = _token.authenticationType;
    }
}

-(NSString*)convertPairingTime:(NSString*)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSSSSS"];
    NSDate* date = [formatter dateFromString:time];
    [formatter setDateFormat:@" MMM dd, yyyy hh:mm:ss"];
    return [formatter stringFromDate:date];
}

-(void)initLocalization{
    informationLabel.text = NSLocalizedString(@"Information", @"Information");
    userNameLabel.text = NSLocalizedString(@"UserName", @"UserName");
    createdLabel.text = NSLocalizedString(@"Created", @"Created");
    applicationLabel.text = NSLocalizedString(@"Application", @"Application");
    issuerLabel.text = NSLocalizedString(@"Issuer", @"Issuer");
    authenticationModeLabel.text = NSLocalizedString(@"AuthenticationMode", @"AuthenticationMode");
    authenticationTypeLabel.text = NSLocalizedString(@"AuthenticationType", @"AuthenticationType");
    closeButton.titleLabel.text = NSLocalizedString(@"CloseButton", @"CloseButton");
}

-(void)initWidget{
    closeButton.layer.cornerRadius = CORNER_RADIUS;
    closeButton.layer.borderColor = [UIColor blackColor].CGColor;
    closeButton.layer.borderWidth = 2.0;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkDeviceOrientation];
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

-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
