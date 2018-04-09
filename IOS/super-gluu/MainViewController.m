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
#import "UserLoginInfo.h"
#import "LogManager.h"
#import "SCLAlertView.h"
#import "TokenEntity.h"
#import "DataStoreManager.h"
#import "NetworkChecker.h"
#import "IAPShare.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "PinCodeViewController.h"
#import "PinCodeDelegate.h"
#import "SuperGluuBannerView.h"
#import "ADSubsriber.h"
#import "PushNotificationHelper.h"



#ifdef ADFREE
    #import "Super_Gluu___Ad_Free-Swift.h"
#else
    #import "Super_Gluu-Swift.h"
#endif

@interface MainViewController () <PAPasscodeViewControllerDelegate, PinCodeDelegate> {
    PeripheralScanner* scanner;
    BOOL isSecureClick;
    BOOL isEnroll;
    BOOL isShowingQRReader;
    
    int count;
    
    OXPushManager* oxPushManager;
    PinCodeViewController* pinView;
    UIAlertController * alert;
    
    SuperGluuBannerView* smallBannerView;
    SuperGluuBannerView* bannerView;
    
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // on initial load, prompt user to setup secure entry to app
    if ([GluuUserDefaults hasSeenSecurityPrompt] == false) {
        [self performSegueWithIdentifier:@"segueToSecurityPrompt" sender:nil];
    }
    
    count = 0;
    
    [self initWiget];
    [self initLocalization];
    [self initNotificationCenterObservers];
    [self setupDisplay];
    [self setupAdHandling];
    
    oxPushManager = [[OXPushManager alloc] init];
    
    //Disable BLE support
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SECURE_CLICK_ENABLED];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL secureClickEnable = [[NSUserDefaults standardUserDefaults] boolForKey:SECURE_CLICK_ENABLED];
    isSecureClick = secureClickEnable;
    [_notificationNetworkView checkNetwork];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERSTIAL object:nil];
    
    [self checkPushNotification];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // make sure the push notification ask happens after the security prompt
    if ([GluuUserDefaults hasSeenNotificationPrompt] == false && [GluuUserDefaults hasSeenSecurityPrompt] == true) {
        
//        [self registerForPushNotifications];
        [GluuUserDefaults setNotificationPrompt];
    } else {
        [self initQRScanner];
    }
    
}

- (void)setupDisplay {
    
    SEL sel = @selector(goToSettings);
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu"] style:UIBarButtonItemStylePlain target:self action:sel];
    self.navigationItem.rightBarButtonItem = menuButton;
    
}


- (void)setupAdHandling {
#ifdef ADFREE
        //skip here
#else
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideADView:) name:NOTIFICATION_AD_FREE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initADView:) name:NOTIFICATION_AD_NOT_FREE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInterstial:) name:NOTIFICATION_INTERSTIAL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_REGISTRATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_REGISTRATION_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_AUTENTIFICATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_AUTENTIFICATION_FAILED object:nil];
    
        //Here we should also check subsciption for AD free
    [[ADSubsriber sharedInstance] isSubscriptionExpired];
#endif
    bannerView = [[SuperGluuBannerView alloc] init];
    [bannerView createAndLoadInterstitial];
}

- (void)goToSettings {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsViewController *settingsVC = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:settingsVC] animated:YES completion:nil];
    
}

- (void)initSecureClickScanner:(NSNotification*)notification {
    
    NSData* valueData = notification.object;
    scanner = [[PeripheralScanner alloc] init];
    scanner.valueForWrite = valueData;
    scanner.isEnroll = isEnroll;
    [scanner start];
    [self showAlertViewWithTitle:@"SecureClick" andMessage:@"Short click on device button"];
    
}

- (void)checkPushNotification {
    
    // check for an existing request via push notification
    NSDictionary* pushNotificationRequest = [[NSUserDefaults standardUserDefaults] objectForKey:NotificationRequest];
    
    if (pushNotificationRequest == nil) return;
    
    NSDictionary* jsonDictionary = [PushNotificationHelper parsedInfo:pushNotificationRequest];
    
    if ([PushNotificationHelper isLastPushExpired] == true) {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:NotificationRequest];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUSH_TIMEOVER object:jsonDictionary];
        
        return;
    }
    
    
    /*
    NSData *data;
//    if (data == nil) return;
    NSString* requestString = [pushNotificationRequest objectForKey:@"request"];
    if ([requestString isKindOfClass:[NSDictionary class]]){
        data = [NSJSONSerialization dataWithJSONObject:requestString options:NSJSONWritingPrettyPrinted error:nil];
    } else {
        data = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    }
     */
    
       //[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if (jsonDictionary != nil){
//        NSString* message = NSLocalizedString(@"StartAuthentication", @"Authentication...");
//        [self updateStatus:message];
        
        //            [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
        
        
        [AuthHelper sharedInstance].requestDictionary = jsonDictionary;
        
        [self initUserInfo:jsonDictionary];
        
        BOOL isApprove = [[NSUserDefaults standardUserDefaults] boolForKey:NotificationRequestActionsApprove];
        BOOL isDeny    = [[NSUserDefaults standardUserDefaults] boolForKey:NotificationRequestActionsDeny];
        
        // Currently, we are double calling approve request.
        // It's getting called both when we approve via the home screen, then again when
        // the user comes into the app and the Main VC is launched.
        
        if (isApprove){
            [self approveRequest];
        } else if (isDeny){
            [self denyRequest];
        } else {
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self sendQRCodeRequest:jsonDictionary];
            });
        }
        
        // clear existing data
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:NotificationRequest];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NotificationRequestActionsApprove];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NotificationRequestActionsDeny];
    }
    
}

- (void)initWiget{
    if (IS_IPHONE_6){
        scanTextLabel.font = [UIFont systemFontOfSize:17];
    }
    statusView.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    
    scanButton.layer.cornerRadius = scanButton.bounds.size.height / 2;
    
    topView.backgroundColor    = [[AppConfiguration sharedInstance] systemColor];
    
    statusView.backgroundColor = [[AppConfiguration sharedInstance] systemColor];
    
    topIconView.image          = [[AppConfiguration sharedInstance] systemIcon];
    
    isUserInfo = NO;
}

-(void)initLocalization{
    welcomeLabel.text = NSLocalizedString(@"Welcome", @"Welcome");
    scanTextLabel.text = NSLocalizedString(@"ScanText", @"Scan Text");
}

- (void)initPushView:(NSNotification*)notification{
    //Make sound and vibrate like push
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1003);//push sound
    
    NSDictionary *requestDictionary = [notification object];
    
    [AuthHelper sharedInstance].requestDictionary = requestDictionary;
    
    [self sendQRCodeRequest:requestDictionary];
}

-(void)initNotificationCenterObservers{
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPushView:) name:NOTIFICATION_PUSH_ONLINE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_DECLINE_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_DECLINE_SUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_PUSH_TIMEOVER object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(initSecureClickScanner:)    name:INIT_SECURE_CLICK_NOTIFICATION  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidDisconnecPeritheralRecieved:) name:DID_DISCONNECT_PERIPHERAL object:nil];
}

-(void)notificationDidDisconnecPeritheralRecieved:(NSNotification*)notification{
    [scanner setScanning:NO];
}

-(void)notificationRecieved:(NSNotification*)notification{
    
    NSString* step = [notification.userInfo valueForKey:@"oneStep"];
    BOOL oneStep = [step boolValue];
    NSString* message = @"";
    NSString *notiName = [notification name];
    
    if ([notiName isEqual:NOTIFICATION_REGISTRATION_SUCCESS]){
        
        message = NSLocalizedString(@"SuccessEnrollment", @"Success Authentication");

        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitleSuccess", @"Success") andMessage:message];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERSTIAL object:nil];
        
    } else if ([notiName isEqual:NOTIFICATION_REGISTRATION_FAILED]){
        
        message = NSLocalizedString(@"FailedEnrollment", @"Failed Authentication");
        
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"FailedEnrollment", @"Failed Authentication")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"FailedEnrollment", @"Failed Enrollment")];
        }
        
        [self showAlertViewWithTitle:NSLocalizedString(@"FailedEnrollment", @"Failed Enrollment") andMessage:message];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERSTIAL object:nil];
        
    } else if ([notiName isEqual:NOTIFICATION_REGISTRATION_STARTING]){
        
        message = NSLocalizedString(@"StartRegistration", @"Registration...");
        
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"StartRegistration", @"Registration...")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"StartRegistration", @"Registration...")];
        }
        
    } else if ([notiName isEqual:NOTIFICATION_AUTENTIFICATION_SUCCESS]){
        
        isUserInfo = YES;
        
        message = NSLocalizedString(@"SuccessAuthentication", @"Success Authentication");
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitleSuccess", @"Success") andMessage:message];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERSTIAL object:nil];
        
    } else if ([notiName isEqual:NOTIFICATION_AUTENTIFICATION_FAILED]){
        
        message = NSLocalizedString(@"FailedAuthentication", @"Failed Authentication");

        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"FailedAuthentication", @"Failed Authentication")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"FailedAuthentication", @"Failed Authentication")];
        }

        [self showAlertViewWithTitle:NSLocalizedString(@"FailedAuthentication", @"Failed Authentication") andMessage:message];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERSTIAL object:nil];
        
    } else if ([notiName isEqual:NOTIFICATION_AUTENTIFICATION_STARTING]){
        
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        }
        
    } else if ([notiName isEqual:NOTIFICATION_ERROR] || [notiName isEqual:@"ERRROR"]){
        
        message = [notification object];
//        [UserLoginInfo sharedInstance]->logState = UNKNOWN_ERROR;
        [UserLoginInfo sharedInstance]->errorMessage = message;
        [[DataStoreManager sharedInstance] saveUserLoginInfo:[UserLoginInfo sharedInstance]];
        
    } else if ([notiName isEqual:NOTIFICATION_UNSUPPORTED_VERSION]){
        
        message = NSLocalizedString(@"UnsupportedU2FV2Version", @"Unsupported U2F_V2 version...");
        
    } else if ([notiName isEqual:NOTIFICATION_PUSH_RECEIVED]){
        
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        }
        
        NSDictionary* pushRequest = (NSDictionary*)notification.object;
        [self sendQRCodeRequest:pushRequest];
        
    } else if ([notiName isEqual:NOTIFICATION_PUSH_RECEIVED_APPROVE]) {
        // clear out the notification from user defaults. That way
        // the check in viewWillAppear doesn't get called
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:NotificationRequest];
        NSDictionary* pushRequest = (NSDictionary*)notification.object;
        [AuthHelper sharedInstance].requestDictionary = pushRequest;
        [self initUserInfo:pushRequest];
        [self approveRequest];
        return;
        
    } else if ([notiName isEqual:NOTIFICATION_PUSH_RECEIVED_DENY]) {
        // clear out the notification from user defaults. That way
        // the check in viewWillAppear doesn't get called
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:NotificationRequest];
        NSDictionary* pushRequest = (NSDictionary*)notification.object;
        [AuthHelper sharedInstance].requestDictionary = pushRequest;
        [self initUserInfo:pushRequest];
        [self denyRequest];
        return;
    }
    
     
    if ([notiName isEqual:NOTIFICATION_DECLINE_SUCCESS]){
        message = NSLocalizedString(@"DenySuccess", @"Deny Success");
    }
    
    if ([notiName isEqual:NOTIFICATION_DECLINE_FAILED]){
        message = NSLocalizedString(@"DenyFailed", @"Deny Failed");
    }
    
    if ([notiName isEqual:NOTIFICATION_FAILED_KEYHANDLE]){
        message = NSLocalizedString(@"FailedKeyHandle", @"Failed KeyHandles");
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitle", @"Info") andMessage:message];
    }
    
    if ([notiName isEqual:NOTIFICATION_PUSH_TIMEOVER]){
        NSString* mess = NSLocalizedString(@"PushTimeOver", @"Push Time Over");
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitle", @"Info") andMessage:mess];
        return;
    }
    
//    [self updateStatus:message];
//    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    
}

#pragma LicenseAgreementDelegates


- (void)approveRequest {
    
    [[AuthHelper sharedInstance] approveRequestWithCompletion:^(BOOL success, NSString *errorMessage) {
    }];
    
}

-(void)denyRequest{
    
    [[AuthHelper sharedInstance] denyRequestWithCompletion:^(BOOL success, NSString * errorMessage) {
    }];

}

-(void)openRequest{
    [self loadApproveDenyView];
}

//# ------------ END -----------------------------

#pragma - mark - QR Code Reader

-(void)initQRScanner {
    
    if (qrScanerVC != nil) {
        return;
    }
    
    // Create the reader object
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    
    qrScanerVC = [QRCodeReaderViewController readerWithCancelButtonTitle:@""//NSLocalizedString(@"Cancel", @"Cancel")
                                                              codeReader:reader
                                                     startScanningAtLoad:YES
                                                  showSwitchCameraButton:NO
                                                         showTorchButton:NO];
    
    // Define the delegate receiver
    qrScanerVC.delegate = self;

}

-(void)sendQRCodeRequest:(NSDictionary*)jsonDictionary{

    if (jsonDictionary != nil){
    
        [AuthHelper sharedInstance].requestDictionary = jsonDictionary;
        [self initUserInfo:jsonDictionary];
        [self provideScanRequest];
        
    } else {
        [self updateStatus:NSLocalizedString(@"WrongQRImage", @"Wrong QR Code image")];
        [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    }
}

- (void)provideScanRequest {
    
    isUserInfo = NO;

    [self loadApproveDenyView];
}

- (void)loadApproveDenyView {
    
    count++;
    
    NSLog(@"Count = %d", count);
    
    // prevent approve deny from loading 2x
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[ApproveDenyViewController class]]) {
            return;
        }
    }
    
    if (self.presentedViewController != nil) {
        [self.presentedViewController dismissViewControllerAnimated:false completion:nil];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ApproveDenyViewController *approveDenyView = [storyboard instantiateViewControllerWithIdentifier:@"ApproveDenyView"];
    approveDenyView.delegate = self;
    approveDenyView.isLogInfo = false;
    
    [self.navigationController pushViewController:approveDenyView animated:true];
    
}

- (void)showQRReader {
    
    if (_notificationNetworkView.isNetworkAvailable) {
        
        if (qrScanerVC == nil) {
            [self initQRScanner];
        }
        
        if ([QRCodeReader isAvailable]) {
            
            [qrScanerVC setTitle:@"Scan Barcode"];
            
            [self.navigationController pushViewController:qrScanerVC animated:true];
            
        } else {
            
            [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitle", @"Info") andMessage:NSLocalizedString(@"AlertMessageNoQRScanning", @"No QR Scanning available")];
            
        }
    }
    
    [scanButton setEnabled:true];
}

#pragma mark - Camera Permission Handling

- (IBAction)scanQRTapped {
    
    [scanButton setEnabled:false];
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            [self showQRReader];
            break;
            
        case AVAuthorizationStatusNotDetermined: {
            
            NSLog(@"%@", @"Camera access not determined. Ask for permission.");
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
                if (granted) {
                    
                    NSLog(@"Granted access to %@", AVMediaTypeVideo);
                    [self showQRReader];
                    
                } else {
                    
                    NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                    [self cameraDenied];
                    
                }
            }];
            
            break;
        }
            
        case AVAuthorizationStatusRestricted:
            // User is restricted
            [self cameraDenied];
            break;
            
        case AVAuthorizationStatusDenied:
            // User needs to head to settings
            [self cameraDenied];
            break;
    
    }

}

- (void)cameraDenied {
    
    NSLog(@"%@", @"Denied camera access");
    
    NSString *alertText;
    NSString *alertButton;
    
    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
    if (canOpenSettings) {
        alertText = @"It looks like your privacy settings are preventing us from accessing your camera to do barcode scanning. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Touch Privacy.\n\n3. Turn the Camera on.\n\n4. Open this app and try again.";
        
        alertButton = @"Go";
    } else {
        alertText = @"It looks like your privacy settings are preventing us from accessing your camera to do barcode scanning. You can fix this by doing the following:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Touch Privacy.\n\n5. Turn the Camera on.\n\n6. Open this app and try again.";
        
        alertButton = @"OK";
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Camera Issue"
                          message:alertText
                          delegate:self
                          cancelButtonTitle:alertButton
                          otherButtonTitles:nil];
    
    alert.tag = 3491832;
    [alert show];
    
    [scanButton setEnabled:true];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3491832) {
        BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
        
        if (canOpenSettings)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
}

#pragma mark - Approve Deny View Delegate

- (void)onApprove {

}

- (void)onDecline {

}

-(void)showAlertViewWithTitle:(NSString*)title andMessage:(NSString*)message{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:title subTitle:message closeButtonTitle:@"Close" duration:3.0f];
}
    
#pragma mark - Ad Handling:
    
-(void)initADView:(NSNotification*)notification{
    smallBannerView = [[SuperGluuBannerView alloc] initWithAdSize:kGADAdSizeBanner andRootViewController:self];
    smallBannerView.alpha = 1.0;
}
    
-(void)hideADView:(NSNotification*)notification{
    if (smallBannerView != nil){
        [smallBannerView closeAD];
    }
}
    
-(void)reloadInterstial:(NSNotification*)notification{
    if (bannerView == nil){
        bannerView = [[SuperGluuBannerView alloc] init];
    }
    [bannerView createAndLoadInterstitial];
}
    
-(void)initFullPageBanner:(NSNotification*)notification{
    
    [bannerView showInterstitial:self];
}
    
-(void)reloadFullPageBanner:(NSNotification*)notification{
    [bannerView createAndLoadInterstitial];
}
    
-(void)closeAD{
    [bannerView closeAD];
}


#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    if (result) {
        NSLog(@"Did Scan Result");
        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        [self sendQRCodeRequest:jsonDictionary];
    }

}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    // We don't use it
}

- (void)updateStatus:(NSString*)status {
    if (status != nil){
        statusLabel.text = status;
    }
    [UIView animateWithDuration:0.2 animations:^{
        [statusView setAlpha:0.0];
        [statusView setCenter:CGPointMake(statusView.center.x, -40)];
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 animations:^{
            [statusView setAlpha:1.0];
            if (IS_IPHONE_5){//IS_IPHONE_4 ||
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

-(void)initUserInfo:(NSDictionary*)parameters{
    NSString* app = [parameters objectForKey:@"app"];
    NSString* created = [NSString stringWithFormat:@"%@", [NSDate date]];
    NSString* issuer = [parameters objectForKey:@"issuer"];
    NSString* username = [parameters objectForKey:@"username"];
    NSString* method = [parameters objectForKey:@"method"];
    BOOL oneStep = username == nil ? YES : NO;
    
    [UserLoginInfo sharedInstance]->application = app;
    [UserLoginInfo sharedInstance]->created = created;
    [UserLoginInfo sharedInstance]->issuer = issuer;
    [UserLoginInfo sharedInstance]->userName = username;
    isEnroll = [method isEqualToString:@"enroll"] ? YES : NO;
    if (isEnroll){
        NSString* type = NSLocalizedString(@"Enrol", @"Enrol");
        [UserLoginInfo sharedInstance]->authenticationType = type;
    } else {
        [UserLoginInfo sharedInstance]->authenticationType = method;
        
    }
    NSString* mode = oneStep ? NSLocalizedString(@"OneStepMode", @"One Step") : NSLocalizedString(@"TwoStepMode", @"Two Step");
    [UserLoginInfo sharedInstance]->authenticationMode = mode;
    [UserLoginInfo sharedInstance]->locationCity = [parameters objectForKey:@"req_loc"];
    [UserLoginInfo sharedInstance]->locationIP = [parameters objectForKey:@"req_ip"];
}


-(void)checkNetworkConnection{
    // Allocate a reachability object
    NetworkChecker *checker = [NetworkChecker reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [checker currentReachabilityStatus];
    
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        NSLog(@"UNREACHABLE!");
        [self showNetworkUnavailableMessage];
    }
    else
    {
        NSLog(@"REACHABLE!");
//        [_notificationNetworkView checkNetwork];
    }
}

-(void)showNetworkUnavailableMessage{
    [self showSystemMessage:@"Network Unavailable" message:NETWORK_UNREACHABLE_TEXT([[AppConfiguration sharedInstance] systemTitle])];
    [_notificationNetworkView checkNetwork];
}

-(void)showSystemMessage:(NSString*) title message: (NSString*)message {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)onResult:(Boolean)result{
    if (result){
        [pinView dismissViewControllerAnimated:YES completion:nil];
        [self provideScanRequest];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
