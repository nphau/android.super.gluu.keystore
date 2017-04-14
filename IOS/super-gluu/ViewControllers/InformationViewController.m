//
//  InformationViewController.m
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/9/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "InformationViewController.h"
#import "Constants.h"
#import "DataStoreManager.h"
#import "SCLAlertView.h"

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
    if ([_token isKindOfClass:[TokenEntity class]]){
        NSURL* url = [NSURL URLWithString:_token->application];
        applicationValueLabel.text = url.host;
        issuerValueLabel.text = _token->issuer;
        userNameValueLabel.text = _token->userName;
        createdValueLabel.text = [self convertPairingTime:_token->pairingTime];
        authenticationValueModeLabel.text = _token->authenticationMode;
        authenticationValueTypeLabel.text = _token->authenticationType;
        NSString* keyHandleString = [NSString stringWithFormat:@"%@...%@", [_token->keyHandle substringToIndex:6], [_token->keyHandle substringFromIndex:_token->keyHandle.length - 6]];
        keyHandleValueLabel.text = keyHandleString;
    }
}

-(NSString*)convertPairingTime:(NSString*)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
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
    keyHandleLabel.text = NSLocalizedString(@"keyHandle", @"Key handle");
}

-(void)initWidget{
    closeButton.layer.cornerRadius = CORNER_RADIUS;
    closeButton.layer.borderColor = [UIColor blackColor].CGColor;
    closeButton.layer.borderWidth = 2.0;
    
    deleteButton.layer.cornerRadius = CORNER_RADIUS;
    deleteButton.layer.borderColor = [UIColor redColor].CGColor;
    deleteButton.layer.borderWidth = 2.0;
}

-(IBAction)delete:(id)sender{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:NSLocalizedString(@"YES", @"YES") actionBlock:^(void) {
        NSLog(@"YES clicked");
        [self deleteKey];
    }];
    [alert addButton:NSLocalizedString(@"NO", @"NO") actionBlock:^(void) {
        NSLog(@"NO clicked");
    }];
    [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:NSLocalizedString(@"Delete", @"Delete") subTitle:NSLocalizedString(@"DeleteKeyHandle", @"Delete KeyHandle") closeButtonTitle:nil duration:0.0f];
}

-(void)deleteKey{
    [[DataStoreManager sharedInstance] deleteTokenEntitiesByID:_token->application userName:_token->userName];
    [self dismissViewControllerAnimated:YES completion:nil];
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
                [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width, 250)];
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
