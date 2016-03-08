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
#import "CustomIOS7AlertView.h"

NSString *const kTJCircularSpinner = @"TJCircularSpinner";

@interface MainViewController ()

@end

@implementation MainViewController{
    ApproveDenyViewController* approveDenyView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWiget];
    [self initNotifications];
    [self initQRScanner];
    [self adoptViewForDevice];
    [self initLocalization];
}

-(void)initWiget{
    if (IS_IPHONE_6){
        scanTextLabel.font = [UIFont systemFontOfSize:17];
    }
    statusView.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    
//    titleLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    
    circularSpinner = [[TJSpinner alloc] initWithSpinnerType:kTJCircularSpinner];
    [circularSpinner setFrame:CGRectMake(scanButton.frame.origin.x + 50, scanButton.frame.origin.y - 100, 50, 50)];
    circularSpinner.hidesWhenStopped = YES;
    circularSpinner.radius = 10;
    circularSpinner.pathColor = [UIColor whiteColor];
    circularSpinner.fillColor = [UIColor greenColor];
    circularSpinner.thickness = 7;
    [circularSpinner setHidden:YES];
    [self.view addSubview:circularSpinner];
//    [self showUserInfo:NO];
    isUserInfo = NO;
}

-(void)initLocalization{
    welcomeLabel.text = NSLocalizedString(@"Welcome", @"Welcome");
    scanTextLabel.text = NSLocalizedString(@"ScanText", @"Scan Text");
    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"Home", @"Home")];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"Logs", @"Logs")];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setTitle:NSLocalizedString(@"Keys", @"Keys")];
//    [scanButton setTitle:NSLocalizedString(@"ScanButtonTitle", @"Scan Title") forState:UIControlStateNormal];
//    titleLabel.text = NSLocalizedString(@"AppNameTitle", @"App Title");
}

-(void)adoptViewForDevice{
//    CGPoint center = CGPointMake(self.view.center.x, self.view.center.y);
//    [scanButton setCenter:center];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_PUSH_TIMEOVER object:nil];

}

-(void)notificationRecieved:(NSNotification*)notification{
    NSString* step = [notification.userInfo valueForKey:@"oneStep"];
    BOOL oneStep = [step boolValue];
    NSString* message = @"";
    if ([[notification name] isEqualToString:NOTIFICATION_REGISTRATION_SUCCESS]){
        [circularSpinner setHidden:YES];
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"SuccessEnrollment", @"Success Authentication");
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitleSuccess", @"Success") andMessage:message];
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_REGISTRATION_FAILED]){
        [circularSpinner setHidden:YES];
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
        [circularSpinner setHidden:YES];
        isUserInfo = YES;
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"SuccessAuthentication", @"Success Authentication");
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitleSuccess", @"Success") andMessage:message];
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_AUTENTIFICATION_FAILED]){
        [circularSpinner setHidden:YES];
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"FailedAuthentication", @"Failed Authentication");
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"FailedAuthentication", @"Failed Authentication")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"FailedAuthentication", @"Failed Authentication")];
        }
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_AUTENTIFICATION_STARTING]){
        message = NSLocalizedString(@"StartAuthentication", @"Authentication...");
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        }
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_ERROR]){
        [circularSpinner setHidden:YES];
        message = [notification object];
        [scanButton setEnabled:YES];
    } else 
    if ([[notification name] isEqualToString:NOTIFICATION_UNSUPPORTED_VERSION]){
        [circularSpinner setHidden:YES];
        [scanButton setEnabled:YES];
        message = NSLocalizedString(@"UnsupportedU2FV2Version", @"Unsupported U2F_V2 version...");
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_PUSH_RECEIVED]){
        [scanButton setEnabled:NO];
        message = NSLocalizedString(@"StartAuthentication", @"Authentication...");
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
    if ([[notification name] isEqualToString:NOTIFICATION_FAILED_KEYHANDLE]){
        [circularSpinner setHidden:YES];
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

-(void)showApproveDenyView{
    approveDenyView = [self.storyboard instantiateViewControllerWithIdentifier:@"ApproveDenyView"];
    if (approveDenyView != nil){
        approveDenyView.delegate = self;
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [contentView.layer addAnimation:transition forKey:nil];
        [contentView addSubview:approveDenyView.view];
    }
}

#pragma LicenseAgreementDelegates

-(void)approveRequest{
    [self initAnimationFromRigthToLeft];
    [approveDenyView.view removeFromSuperview];
    approveDenyView = nil;
    NSString* message = NSLocalizedString(@"StartAuthentication", @"Authentication...");
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    [self onApprove];
}

-(void)denyRequest{
    [self initAnimationFromRigthToLeft];
    [approveDenyView.view removeFromSuperview];
    approveDenyView = nil;
    NSString* message = @"Request canceled";
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
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
            [circularSpinner setHidden:YES];
        }
    }];
    
    isResultFromScan = NO;
}

-(void)sendQRCodeRequest:(NSDictionary*)jsonDictionary{
    if (jsonDictionary != nil){
        scanJsonDictionary = jsonDictionary;
//        [self initUserInfo:jsonDictionary];
        [self performSelector:@selector(provideScanRequest) withObject:nil afterDelay:1.0];
    } else {
        [self updateStatus:NSLocalizedString(@"WrongQRImage", @"Wrong QR Code image")];
        [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    }
}

-(void)provideScanRequest{
    [circularSpinner setHidden:YES];
    isUserInfo = NO;
    [scanButton setEnabled:NO];
//    [self showApproveDeclineView];
    [self showApproveDenyView];
}

//-(void)showApproveDeclineView{
//    [UIView animateWithDuration:0.5 animations:^{
//        NSString* message = [NSString stringWithFormat:NSLocalizedString(@"ApproveDeclineTitle", @"ApproveDeclineTitle"), NSLocalizedString(@"Approve", @"Approve"), NSLocalizedString(@"Decline", @"Decline")];
//        statusLabel.text = message;
//        [statusView setCenter:CGPointMake(statusView.center.x, 5)];
//        [statusView setAlpha:1.0];
//        [self showUserInfo];
////        [hiddenView setHidden:NO];
////        [approveButton setCenter:CGPointMake(self.view.center.x - approveButton.frame.size.width/2-4, approveButton.center.y)];
////        [declineButton setCenter:CGPointMake(self.view.center.x + declineButton.frame.size.width/2+4, declineButton.center.y)];
//    } completion:^(BOOL finished) {
//        //
//    }];
//}
//
//-(void)hideApproveDeclineView{
//    [UIView animateWithDuration:0.5 animations:^{
////        [approveButton setCenter:CGPointMake(HIDE_POSITION_APPROVE_BUTTON, approveButton.center.y)];
////        [declineButton setCenter:CGPointMake(HIDE_POSITION_DECLINE_BUTTON, declineButton.center.y)];
////        [self resetStatusView];
////        [hiddenView setHidden:YES];
//    } completion:^(BOOL finished) {
//        //
//    }];
//}

#pragma mark - Action Methods

- (IBAction)scanAction:(id)sender
{
    [self initQRScanner];
    if ([QRCodeReader isAvailable]){
        [circularSpinner setHidden:NO];
        [circularSpinner startAnimating];
//        [self resetStatusView];
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
    [oxPushManager onOxPushApproveRequest:scanJsonDictionary];
}

-(void)onDecline{
    [scanButton setEnabled:YES];
//    [self hideApproveDeclineView];
    NSString* message = @"Authentication was Declined";
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
}

-(void)showAlertViewWithTitle:(NSString*)title andMessage:(NSString*)message{
    CustomIOS7AlertView* infoView = [CustomIOS7AlertView alertWithTitle:title message:message];
    [infoView show];
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
        [circularSpinner setHidden:YES];
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
        [[LogManager sharedInstance] addLog:status];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [statusView setAlpha:0.0];
        [statusView setCenter:CGPointMake(statusView.center.x, -40)];
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 animations:^{
            [statusView setAlpha:1.0];
            [statusView setCenter:CGPointMake(statusView.center.x, 65)];
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

-(void)initUserInfo:(NSDictionary*)parameters{
    NSString* app = [parameters objectForKey:@"app"];
//    NSString* state = [parameters objectForKey:@"state"];
    NSString* created = [parameters objectForKey:@"created"];
    NSString* issuer = [parameters objectForKey:@"issuer"];
    NSString* username = [parameters objectForKey:@"username"];
    BOOL oneStep = username == nil ? YES : NO;
    
    [[UserLoginInfo sharedInstance] setApplication:app];
    [[UserLoginInfo sharedInstance] setCreated:created];
    [[UserLoginInfo sharedInstance] setIssuer:issuer];
    [[UserLoginInfo sharedInstance] setUserName:username];
    [[UserLoginInfo sharedInstance] setAuthenticationType:@"Authentication"];
    NSString* mode = oneStep ? NSLocalizedString(@"OneStepMode", @"One Step") : NSLocalizedString(@"TwoStepMode", @"Two Step");
    [[UserLoginInfo sharedInstance] setAuthenticationMode:mode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initAnimationFromRigthToLeft{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [contentView.layer addAnimation:transition forKey:nil];
}

@end
