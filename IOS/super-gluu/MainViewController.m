//
//  ViewController.m
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/1/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import "MainViewController.h"
#import "QRCodeReader.h"
#import "QRCodeReaderViewController.h"
#import "Constants.h"
#import "OXPushManager.h"
#import "LogManager.h"
#import "CustomIOSAlertView.h"

#import "TokenEntity.h"
#import "DataStoreManager.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWiget];
    [self initNotifications];
    [self initQRScanner];
    [self initLocation];
    [self initLocalization];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [self checkDeviceOrientation];

    //For Push Notifications
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7){//for ios 8 and higth
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [self registerForNotification];
    }
    [self checkPushNotification];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkDeviceOrientation];
}

-(void)checkPushNotification{
    NSDictionary* pushNotificationRequest = [[NSUserDefaults standardUserDefaults] objectForKey:NotificationRequest];
    if (pushNotificationRequest == nil) return;
    NSData *data;
    NSString* requestString = [pushNotificationRequest objectForKey:@"request"];
    if ([requestString isKindOfClass:[NSDictionary class]]){
        data = [NSJSONSerialization dataWithJSONObject:requestString options:NSJSONWritingPrettyPrinted error:nil];
    } else {
        data = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (jsonDictionary != nil){
        [scanButton setEnabled:NO];
        NSString* message = NSLocalizedString(@"StartAuthentication", @"Authentication...");
        [self updateStatus:message];
        //            [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
        scanJsonDictionary = jsonDictionary
        ;
        [self sendQRCodeRequest:scanJsonDictionary];
        //[self onApprove];
        [self.tabBarController setSelectedIndex:0];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:NotificationRequest];
    }
}

- (void)registerForNotification {

    UIMutableUserNotificationAction *action1;
    action1 = [[UIMutableUserNotificationAction alloc] init];
    [action1 setActivationMode:UIUserNotificationActivationModeForeground];
    [action1 setTitle:NSLocalizedString(@"Approve", @"Approve")];
    [action1 setIdentifier:NotificationActionOneIdent];
    [action1 setDestructive:NO];
    [action1 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *action2;
    action2 = [[UIMutableUserNotificationAction alloc] init];
    [action2 setActivationMode:UIUserNotificationActivationModeForeground];
    [action2 setTitle:NSLocalizedString(@"Deny", @"Deny")];
    [action2 setIdentifier:NotificationActionTwoIdent];
    [action2 setDestructive:YES];
    [action2 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory *actionCategory;
    actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:NotificationCategoryIdent];
    [actionCategory setActions:@[action1, action2]
                    forContext:UIUserNotificationActionContextDefault];
    
    NSSet *categories = [NSSet setWithObject:actionCategory];
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types
                                                 categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

-(void)checkDeviceOrientation{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    }
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
                int y = [[UIScreen mainScreen] bounds].size.height/2.8;
                [welcomeView setCenter:CGPointMake(welcomeView.center.x, y)];
                [statusView setCenter:CGPointMake(statusView.center.x, y/4)];
                [scanTextLabel setCenter:CGPointMake(scanTextLabel.center.x, scanButton.center.y + 80)];
                [welcomeLabel setCenter:CGPointMake(welcomeLabel.center.x, scanButton.center.y - 70)];
                isLandScape = NO;
            }
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            //load the landscape view
            if (!isLandScape){
                int y = [[UIScreen mainScreen] bounds].size.height/2.3;//140;
                [welcomeView setCenter:CGPointMake(welcomeView.center.x, y)];
                [statusView setCenter:CGPointMake(statusView.center.x, y/4)];
                [scanTextLabel setCenter:CGPointMake(scanTextLabel.center.x, scanButton.center.y + 50)];
                [welcomeLabel setCenter:CGPointMake(welcomeLabel.center.x, scanButton.center.y - 50)];
                isLandScape = YES;
            }
            
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
}

-(void)initWiget{
    if (IS_IPHONE_6){
        scanTextLabel.font = [UIFont systemFontOfSize:17];
    }
    statusView.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    
    scanButton.layer.cornerRadius = CORNER_RADIUS;
    scanButton.layer.borderColor = CUSTOM_GREEN_COLOR.CGColor;
    scanButton.layer.borderWidth = 2.0;
    
    isUserInfo = NO;
}

-(void)initLocalization{
    welcomeLabel.text = NSLocalizedString(@"Welcome", @"Welcome");
    scanTextLabel.text = NSLocalizedString(@"ScanText", @"Scan Text");
    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"Home", @"Home")];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"Logs", @"Logs")];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setTitle:NSLocalizedString(@"Keys", @"Keys")];
}

-(void)initNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_REGISTRATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_REGISTRATION_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_AUTENTIFICATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_AUTENTIFICATION_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_REGISTRATION_STARTING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_AUTENTIFICATION_STARTING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_ERROR object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_PUSH_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_PUSH_RECEIVED_APPROVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_PUSH_RECEIVED_DENY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_DECLINE_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_DECLINE_SUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_PUSH_TIMEOVER object:nil];

}

-(void)notificationRecieved:(NSNotification*)notification{
    NSString* step = [notification.userInfo valueForKey:@"oneStep"];
    BOOL oneStep = [step boolValue];
    NSString* message = @"";
    if ([[notification name] isEqualToString:NOTIFICATION_REGISTRATION_SUCCESS]){
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"SuccessEnrollment", @"Success Authentication");
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitleSuccess", @"Success") andMessage:message];
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_REGISTRATION_FAILED]){
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"FailedEnrollment", @"Failed Authentication");
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"FailedEnrollment", @"Failed Authentication")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"FailedEnrollment", @"Failed Authentication")];
        }
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_REGISTRATION_STARTING]){
        message = NSLocalizedString(@"StartRegistration", @"Registration...");
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"StartRegistration", @"Registration...")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"StartRegistration", @"Registration...")];
        }
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_AUTENTIFICATION_SUCCESS]){
        isUserInfo = YES;
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"SuccessAuthentication", @"Success Authentication");
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitleSuccess", @"Success") andMessage:message];
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_AUTENTIFICATION_FAILED]){
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"FailedAuthentication", @"Failed Authentication");
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"FailedAuthentication", @"Failed Authentication")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"FailedAuthentication", @"Failed Authentication")];
        }
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_AUTENTIFICATION_STARTING]){
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        }
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_ERROR]){
        message = [notification object];
        [scanButton setEnabled:YES];
    } else 
    if ([[notification name] isEqualToString:NOTIFICATION_UNSUPPORTED_VERSION]){
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"UnsupportedU2FV2Version", @"Unsupported U2F_V2 version...");
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_PUSH_RECEIVED]){
        [scanButton setEnabled:NO];
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        }
        NSDictionary* pushRequest = (NSDictionary*)notification.object;
        [self sendQRCodeRequest:pushRequest];
    } else
        if ([[notification name] isEqualToString:NOTIFICATION_PUSH_RECEIVED_APPROVE]){
            NSDictionary* pushRequest = (NSDictionary*)notification.object;
            scanJsonDictionary = pushRequest;
            [self onApprove];
            [self.tabBarController setSelectedIndex:0];
            return;
        }
    if ([[notification name] isEqualToString:NOTIFICATION_PUSH_RECEIVED_DENY]){
        NSDictionary* pushRequest = (NSDictionary*)notification.object;
        scanJsonDictionary = pushRequest;
        [self onDecline];
        [self.tabBarController setSelectedIndex:0];
        return;
    }
    if ([[notification name] isEqualToString:NOTIFICATION_DECLINE_SUCCESS]){
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"DenySuccess", @"Deny Success");
    }
    if ([[notification name] isEqualToString:NOTIFICATION_DECLINE_FAILED]){
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"DenyFailed", @"Deny Failed");
    }
    if ([[notification name] isEqualToString:NOTIFICATION_FAILED_KEYHANDLE]){
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"FailedKeyHandle", @"Failed KeyHandles");
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitle", @"Info") andMessage:message];
    }
    if ([[notification name] isEqualToString:NOTIFICATION_PUSH_TIMEOVER]){
        NSString* mess = NSLocalizedString(@"PushTimeOver", @"Push Time Over");
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitle", @"Info") andMessage:mess];
        return;
    }
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
}

//-(void)showApproveDenyView{
//    approveDenyView = [self.storyboard instantiateViewControllerWithIdentifier:@"ApproveDenyView"];
//    if (approveDenyView != nil){
//        approveDenyView.delegate = self;
//        CATransition *transition = [CATransition animation];
//        transition.duration = 0.5;
//        transition.type = kCATransitionPush;
//        transition.subtype = kCATransitionFromRight;
//        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//        [contentView.layer addAnimation:transition forKey:nil];
//        [self.tabBarController.tabBar setHidden:YES];
//        [contentView addSubview:approveDenyView.view];
//    }
//}

#pragma LicenseAgreementDelegates

-(void)approveRequest{
    [self initAnimationFromRigthToLeft];
    NSString* message = NSLocalizedString(@"StartAuthentication", @"Authentication...");
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    [self.tabBarController.tabBar setHidden:NO];
    [self onApprove];
}

-(void)denyRequest{
    [self initAnimationFromRigthToLeft];
    NSString* message = @"Request canceled";
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    [self.tabBarController.tabBar setHidden:NO];
    [self onDecline];
}

//# ------------ END -----------------------------

//-(void)showUserInfo{
//    userNameLabel.text = [[UserLoginInfo sharedInstance] userName];
//    userApplicationLabel.text = [[UserLoginInfo sharedInstance] application];
//    userCreatedLabel.text = [[UserLoginInfo sharedInstance] created];
//    userIssuerLabel.text = [[UserLoginInfo sharedInstance] issuer];
//    userAuthencicationModeLabel.text = [[UserLoginInfo sharedInstance] authenticationMode];
//    userAuthencicationTypeLabel.text = [[UserLoginInfo sharedInstance] authenticationType];
//    [statusView setFrame:CGRectMake(statusView.frame.origin.x, statusView.frame.origin.y + 80, statusView.frame.size.width, statusView.frame.size.height + 120)];
//    [self showUserInfo:YES];
//}
//
//-(void)showUserInfo:(BOOL)isShow{
//    isShow = !isShow;
//    [userInfoView setHidden:isShow];
//}

-(void)initQRScanner{
    // Create the reader object
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    qrScanerVC = [QRCodeReaderViewController readerWithCancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
    
    // Set the presentation style
    qrScanerVC.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Define the delegate receiver
    qrScanerVC.delegate = self;
    
    // Or use blocks
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        if(resultAsString && !isResultFromScan){
            isResultFromScan = YES;
            NSLog(@"%@", resultAsString);
            NSData *data = [resultAsString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [self sendQRCodeRequest:jsonDictionary];
            [qrScanerVC dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    isResultFromScan = NO;
}

-(void)sendQRCodeRequest:(NSDictionary*)jsonDictionary{
    if (jsonDictionary != nil){
        scanJsonDictionary = jsonDictionary;
        [self initUserInfo:jsonDictionary];
        [self performSelector:@selector(provideScanRequest) withObject:nil afterDelay:1.0];
    } else {
        [self updateStatus:NSLocalizedString(@"WrongQRImage", @"Wrong QR Code image")];
        [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    }
}

-(void)provideScanRequest{
    isUserInfo = NO;
    [scanButton setEnabled:NO];
    [self loadApproveDenyView];
//    [self performSegueWithIdentifier:@"InfoView" sender:nil];
}

-(void)loadApproveDenyView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ApproveDenyViewController* approveDenyView = [storyboard instantiateViewControllerWithIdentifier:@"ApproveDenyView"];
    //    [tabBar setModalPresentationStyle:UIModalPresentationFullScreen];
    approveDenyView.delegate = self;
    [self presentViewController:approveDenyView animated:YES completion:nil];
}

//#pragma mark - Action Methods
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if ([[segue identifier] isEqualToString:@"InfoView"]) {
//        UINavigationController* dest = [segue destinationViewController];
//        approveDenyView = (id)[dest topViewController];
//        if (approveDenyView != nil){
//            approveDenyView.delegate = self;
//        }
//    }
//}

- (IBAction)scanAction:(id)sender
{
    [self initQRScanner];
    if ([QRCodeReader isAvailable]){
        [self updateStatus:NSLocalizedString(@"QRCodeScanning", @"QR Code Scanning")];
        [self presentViewController:qrScanerVC animated:YES completion:NULL];
    } else {
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitle", @"Info") andMessage:NSLocalizedString(@"AlertMessageNoQRScanning", @"No QR Scanning available")];
    }
}

-(void)onApprove{
    NSString* message = [NSString stringWithFormat:@"%@", NSLocalizedString(@"StartAuthentication", @"Authentication...")];
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    OXPushManager* oxPushManager = [[OXPushManager alloc] init];
    [oxPushManager onOxPushApproveRequest:scanJsonDictionary isDecline:NO];
}

-(void)onDecline{
    [scanButton setEnabled:YES];
    NSString* message = @"Decline starting";
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    OXPushManager* oxPushManager = [[OXPushManager alloc] init];
    [oxPushManager onOxPushApproveRequest:scanJsonDictionary isDecline:YES];
}

-(void)showAlertViewWithTitle:(NSString*)title andMessage:(NSString*)message{
    CustomIOSAlertView *alertView = [CustomIOSAlertView alertWithTitle:title message:message];
    [alertView show];
}

//-(void)resetStatusView{
//    [statusView setFrame:CGRectMake(statusView.frame.origin.x, 0, statusView.frame.size.width, 40)];
//    isUserInfo = NO;
//    [self showUserInfo:NO];
//}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@", result);
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    if (!isResultFromScan){
        [self updateStatus:NSLocalizedString(@"QRCodeCalceled", @"QR Code Calceled")];
        [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    }
}

- (IBAction)infoAction:(id)sender{
    if (!isStatusViewVisible){
        [self updateStatus:nil];
        [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:7.0];
    }
}

-(void)updateStatus:(NSString*)status{
    if (status != nil){
        statusLabel.text = status;
    }
    [UIView animateWithDuration:0.2 animations:^{
        [statusView setAlpha:0.0];
        [statusView setCenter:CGPointMake(statusView.center.x, -40)];
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 animations:^{
            [statusView setAlpha:1.0];
            if (IS_IPHONE_4 || IS_IPHONE_5){
                if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
                {
                    // code for landscape orientation
                    [statusView setCenter:CGPointMake(statusView.center.x, 15)];
                } else {
                    [statusView setCenter:CGPointMake(statusView.center.x, 45)];
                }
            } else {
                if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
                {
                    // code for landscape orientation
                    [statusView setCenter:CGPointMake(statusView.center.x, 35)];
                } else {
                    [statusView setCenter:CGPointMake(statusView.center.x, 65)];
                }
            }
            isStatusViewVisible = YES;
        }];
        
    }];
}

-(void)hideStatusBar{
    [UIView animateWithDuration:1.0 animations:^{
        [statusView setAlpha:0.0];
        isStatusViewVisible = NO;
    } completion:^(BOOL finished) {
        //
    }];
}

-(void)initLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
}

// this delegate is called when the app successfully finds your current location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (!isLocation){
        // this creates a CLGeocoder to find a placemark using the found coordinates
        CLGeocoder *ceo = [[CLGeocoder alloc]init];
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude]; //insert your coordinates
        
        [ceo reverseGeocodeLocation:loc
                  completionHandler:^(NSArray *placemarks, NSError *error) {
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];
                      //                  NSLog(@"placemark %@",placemark);
                      //String to hold address
                      //                  NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                      //                  NSLog(@"addressDictionary %@", placemark.addressDictionary);
                      
                      //                  NSLog(@"placemark %@",placemark.region);
                      //                  NSLog(@"placemark %@",placemark.country);  // Give Country Name
                      //                  NSLog(@"placemark %@",placemark.locality); // Extract the city name
                      
                      NSString* address = @"";
                      
                      if (placemark.locality == nil || [placemark.addressDictionary valueForKey:@"State"] == nil){
                          address = NSLocalizedString(@"FaiedGetLocation", @"Failed to get location");
                      } else {
                          address = [NSString stringWithFormat:@"%@, %@", placemark.locality, [placemark.addressDictionary valueForKey:@"State"]];
                          isLocation = YES;
                      }
                      
                      [[UserLoginInfo sharedInstance] setLocationCity: address];
                      
                      //                  NSLog(@"location %@",placemark.name);
                      //                  NSLog(@"location %@",placemark.ocean);
                      //                  NSLog(@"location %@",placemark.postalCode);
                      //                  NSLog(@"location %@",placemark.subLocality);
                      //
                      //                  NSLog(@"location %@",placemark.location);
                      //                  //Print the location to console
                      //                  NSLog(@"I am currently at %@",locatedAt);
                  }
         ];
    }
}

// this delegate method is called if an error occurs in locating your current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager:%@ didFailWithError:%@", manager, error);
    [[UserLoginInfo sharedInstance] setLocationCity: NSLocalizedString(@"FailedGettingCityName", @"Failed getting cityName")];
}


-(void)initUserInfo:(NSDictionary*)parameters{
    NSString* app = [parameters objectForKey:@"app"];
//    NSString* state = [parameters objectForKey:@"state"];
    NSString* created = [NSString stringWithFormat:@"%@", [NSDate date]];//[parameters objectForKey:@"created"];
    NSString* issuer = [parameters objectForKey:@"issuer"];
    NSString* username = [parameters objectForKey:@"username"];
    BOOL oneStep = username == nil ? YES : NO;
    
    [[UserLoginInfo sharedInstance] setApplication:app];
    [[UserLoginInfo sharedInstance] setCreated:created];
    [[UserLoginInfo sharedInstance] setIssuer:issuer];
    [[UserLoginInfo sharedInstance] setUserName:username];
    NSArray* tokenEntities = [[DataStoreManager sharedInstance] getTokenEntitiesByID:issuer];
    BOOL isEnroll = [tokenEntities count] > 0 ? NO : YES;
    if (isEnroll){//authentication
        NSString* type = NSLocalizedString(@"Enrol", @"Enrol");
        [[UserLoginInfo sharedInstance] setAuthenticationType:type];
    } else {//registration
        NSString* type = NSLocalizedString(@"Authentication", @"Authentication");
        [[UserLoginInfo sharedInstance] setAuthenticationType:type];
        
    }
//    [[UserLoginInfo sharedInstance] setAuthenticationType:@"Authentication"];
    NSString* mode = oneStep ? NSLocalizedString(@"OneStepMode", @"One Step") : NSLocalizedString(@"TwoStepMode", @"Two Step");
    [[UserLoginInfo sharedInstance] setAuthenticationMode:mode];
    [[UserLoginInfo sharedInstance] setLocationIP:[ApproveDenyViewController getIPAddress:issuer]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initAnimationFromRigthToLeft{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionPush;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [contentView.layer addAnimation:transition forKey:nil];
}

@end
