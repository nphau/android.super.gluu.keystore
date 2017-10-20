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
#ifdef ADFREE
    #import "Super_Gluu___Ad_Free-Swift.h"
#else
    #import "Super_Gluu-Swift.h"
#endif

@interface MainViewController () <PAPasscodeViewControllerDelegate, PinCodeDelegate> {
    PeripheralScanner* scanner;
    BOOL isSecureClick;
    BOOL isEnroll;
    
    OXPushManager* oxPushManager;
    PinCodeViewController* pinView;
    UIAlertController * alert;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWiget];
    [self initNotifications];
    [self initQRScanner];
    [self initLocalization];
    oxPushManager = [[OXPushManager alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(initSecureClickScanner:)    name:INIT_SECURE_CLICK_NOTIFICATION  object:nil];

    //For Push Notifications
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7){//for ios 8 and higth
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [self registerForNotification];
    }
    [self checkPushNotification];
    [self checkNetworkConnection];
    //Disable BLE support
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SECURE_CLICK_ENABLED];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    BOOL secureClickEnable = [[NSUserDefaults standardUserDefaults] boolForKey:SECURE_CLICK_ENABLED];
    isSecureClick = secureClickEnable;
    [_notificationNetworkView checkNetwork];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERSTIAL object:nil];
}

-(void)initSecureClickScanner:(NSNotification*)notification{
    NSData* valueData = notification.object;
    scanner = [[PeripheralScanner alloc] init];
    scanner.valueForWrite = valueData;
    scanner.isEnroll = isEnroll;
    [scanner start];
    [self showAlertViewWithTitle:@"SecureClick" andMessage:@"Short click on device button"];
}

-(void)checkPushNotification{
    NSDictionary* pushNotificationRequest = [[NSUserDefaults standardUserDefaults] objectForKey:NotificationRequest];
    if (pushNotificationRequest == nil) return;
    NSData *data;
    if (data == nil) return;
    NSString* requestString = [pushNotificationRequest objectForKey:@"request"];
    if ([requestString isKindOfClass:[NSDictionary class]]){
        data = [NSJSONSerialization dataWithJSONObject:requestString options:NSJSONWritingPrettyPrinted error:nil];
    } else {
        data = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (jsonDictionary != nil){
        NSString* message = NSLocalizedString(@"StartAuthentication", @"Authentication...");
        [self updateStatus:message];
        //            [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
        scanJsonDictionary = jsonDictionary
        ;
        [self initUserInfo:jsonDictionary];
        BOOL isApprove = [[NSUserDefaults standardUserDefaults] boolForKey:NotificationRequestActionsApprove];
        BOOL isDeny = [[NSUserDefaults standardUserDefaults] boolForKey:NotificationRequestActionsDeny];
        if (isApprove){
            [self onApprove];
        } else if (isDeny){
            [self onDecline];
        } else {
            [self sendQRCodeRequest:scanJsonDictionary];
        }
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

-(void)initWiget{
    if (IS_IPHONE_6){
        scanTextLabel.font = [UIFont systemFontOfSize:17];
    }
    statusView.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    
    scanButton.layer.cornerRadius = CORNER_RADIUS;
    scanButton.layer.borderWidth = 2.0;
    scanButton.layer.borderColor = [[AppConfiguration sharedInstance] systemColor].CGColor;
//    [scanButton setTitleColor:[[AppConfiguration sharedInstance] systemColor] forState:UIControlStateNormal];
    topView.backgroundColor = [[AppConfiguration sharedInstance] systemColor];
    statusView.backgroundColor = [[AppConfiguration sharedInstance] systemColor];
    topIconView.image = [[AppConfiguration sharedInstance] systemIcon];
    isUserInfo = NO;
}

-(void)initLocalization{
    welcomeLabel.text = NSLocalizedString(@"Welcome", @"Welcome");
    scanTextLabel.text = NSLocalizedString(@"ScanText", @"Scan Text");
    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"Home", @"Home")];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"Logs", @"Logs")];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setTitle:NSLocalizedString(@"Keys", @"Keys")];
}

- (void) initPushView:(NSNotification*)notification{
    //Make sound and vibrate like push
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1003);//push sound
    scanJsonDictionary = [notification object];
    [self sendQRCodeRequest:scanJsonDictionary];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPushView:) name:NOTIFICATION_PUSH_ONLINE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_DECLINE_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_DECLINE_SUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:NOTIFICATION_PUSH_TIMEOVER object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidDisconnecPeritheralRecieved:) name:DID_DISCONNECT_PERIPHERAL object:nil];
}

-(void)notificationDidDisconnecPeritheralRecieved:(NSNotification*)notification{
    [scanner setScanning:NO];
}

-(void)notificationRecieved:(NSNotification*)notification{
    NSString* step = [notification.userInfo valueForKey:@"oneStep"];
    BOOL oneStep = [step boolValue];
    NSString* message = @"";
    if ([[notification name] isEqualToString:NOTIFICATION_REGISTRATION_SUCCESS]){
        message = NSLocalizedString(@"SuccessEnrollment", @"Success Authentication");
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitleSuccess", @"Success") andMessage:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERSTIAL object:nil];
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_REGISTRATION_FAILED]){
        message = NSLocalizedString(@"FailedEnrollment", @"Failed Authentication");
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"FailedEnrollment", @"Failed Authentication")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"FailedEnrollment", @"Failed Enrollment")];
        }
        [self showAlertViewWithTitle:NSLocalizedString(@"FailedEnrollment", @"Failed Enrollment") andMessage:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERSTIAL object:nil];
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
        message = NSLocalizedString(@"SuccessAuthentication", @"Success Authentication");
        [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitleSuccess", @"Success") andMessage:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERSTIAL object:nil];
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_AUTENTIFICATION_FAILED]){
        message = NSLocalizedString(@"FailedAuthentication", @"Failed Authentication");
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"FailedAuthentication", @"Failed Authentication")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"FailedAuthentication", @"Failed Authentication")];
        }
        [self showAlertViewWithTitle:NSLocalizedString(@"FailedAuthentication", @"Failed Authentication") andMessage:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERSTIAL object:nil];
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_AUTENTIFICATION_STARTING]){
        if (oneStep){
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"OneStep", @"OneStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        } else {
            message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TwoStep", @"TwoStep Authentication"), NSLocalizedString(@"StartAuthentication", @"Authentication...")];
        }
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_ERROR] || [[notification name] isEqualToString:@"ERRROR"]){
        message = [notification object];
//        [UserLoginInfo sharedInstance]->logState = UNKNOWN_ERROR;
        [UserLoginInfo sharedInstance]->errorMessage = message;
        [[DataStoreManager sharedInstance] saveUserLoginInfo:[UserLoginInfo sharedInstance]];
    } else 
    if ([[notification name] isEqualToString:NOTIFICATION_UNSUPPORTED_VERSION]){
        message = NSLocalizedString(@"UnsupportedU2FV2Version", @"Unsupported U2F_V2 version...");
    } else
    if ([[notification name] isEqualToString:NOTIFICATION_PUSH_RECEIVED]){
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
            [self initUserInfo:pushRequest];
            [self onApprove];
            [self.tabBarController setSelectedIndex:0];
            return;
        }
    if ([[notification name] isEqualToString:NOTIFICATION_PUSH_RECEIVED_DENY]){
        NSDictionary* pushRequest = (NSDictionary*)notification.object;
        scanJsonDictionary = pushRequest;
        [self initUserInfo:pushRequest];
        [self onDecline];
        [self.tabBarController setSelectedIndex:0];
        return;
    }
    if ([[notification name] isEqualToString:NOTIFICATION_DECLINE_SUCCESS]){
        message = NSLocalizedString(@"DenySuccess", @"Deny Success");
    }
    if ([[notification name] isEqualToString:NOTIFICATION_DECLINE_FAILED]){
        message = NSLocalizedString(@"DenyFailed", @"Deny Failed");
    }
    if ([[notification name] isEqualToString:NOTIFICATION_FAILED_KEYHANDLE]){
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

#pragma LicenseAgreementDelegates

-(void)approveRequest{
    NSString* message = NSLocalizedString(@"StartAuthentication", @"Authentication...");
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    [self.tabBarController.tabBar setHidden:NO];
    [self onApprove];
}

-(void)denyRequest{
    NSString* message = @"Request canceled";
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    [self.tabBarController.tabBar setHidden:NO];
    [self onDecline];
}

-(void)openRequest{
    [self loadApproveDenyView];
}

//# ------------ END -----------------------------

-(void)initQRScanner{
    // Create the reader object
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    qrScanerVC = [QRCodeReaderViewController readerWithCancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
    
    // Set the presentation style
    qrScanerVC.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Define the delegate receiver
    qrScanerVC.delegate = self;
    
//    isResultFromScan = NO;
}

-(void)sendQRCodeRequest:(NSDictionary*)jsonDictionary{
    if (jsonDictionary != nil){
        scanJsonDictionary = jsonDictionary;
        [self initUserInfo:jsonDictionary];
        [self checkTouchIDProtection];
    } else {
        [self updateStatus:NSLocalizedString(@"WrongQRImage", @"Wrong QR Code image")];
        [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    }
}

-(void)provideScanRequest{
    isUserInfo = NO;
    [self loadApproveDenyView];
//    [self performSegueWithIdentifier:@"InfoView" sender:nil];
}

-(void)loadApproveDenyView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ApproveDenyViewController* approveDenyView = [storyboard instantiateViewControllerWithIdentifier:@"ApproveDenyView"];
    approveDenyView.delegate = self;
    [self presentViewController:approveDenyView animated:YES completion:nil];
}

- (IBAction)scanAction:(id)sender
{
    if (_notificationNetworkView.isNetworkAvailable){
        if ([QRCodeReader isAvailable]){
            [self updateStatus:NSLocalizedString(@"QRCodeScanning", @"QR Code Scanning")];
            [self presentViewController:qrScanerVC animated:YES completion:NULL];
        } else {
            [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitle", @"Info") andMessage:NSLocalizedString(@"AlertMessageNoQRScanning", @"No QR Scanning available")];
        }
    }
}

-(void)onApprove{
    NSString* message = [NSString stringWithFormat:@"%@", NSLocalizedString(@"StartAuthentication", @"Authentication...")];
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    
    [oxPushManager onOxPushApproveRequest:scanJsonDictionary isDecline:NO isSecureClick:isSecureClick callback:^(NSDictionary *result,NSError *error){
        if (error){
            [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitle", @"Info") andMessage:error.localizedDescription];
        }
    }];
}

-(void)onDecline{
    NSString* message = @"Decline starting";
    [self updateStatus:message];
    [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
    [oxPushManager onOxPushApproveRequest:scanJsonDictionary isDecline:YES isSecureClick:isSecureClick callback:^(NSDictionary *result,NSError *error){
    }];
}

-(void)showAlertViewWithTitle:(NSString*)title andMessage:(NSString*)message{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:title subTitle:message closeButtonTitle:@"Close" duration:3.0f];
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        if(result){// && !isResultFromScan){
            [qrScanerVC dismissViewControllerAnimated:YES completion:nil];
//            isResultFromScan = YES;
            NSLog(@"%@", result);
            NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [self sendQRCodeRequest:jsonDictionary];
        }
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
//    if (!isResultFromScan){
        [self updateStatus:NSLocalizedString(@"QRCodeCalceled", @"QR Code Calceled")];
        [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:5.0];
//    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)checkTouchIDProtection{
    BOOL isTouchID = [[NSUserDefaults standardUserDefaults] boolForKey:TOUCH_ID_ENABLED];
    if (isTouchID){
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
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self provideScanRequest];
                                        });
                                    } else {
                                        // User did not authenticate successfully, look at error and take appropriate action
                                        [self showTouchIDErrorMessage];
                                    }
                                }];
        } else {
            // Could not evaluate policy; look at authError and present an appropriate message to user
            [self showTouchIDResultError:authError];
        }
    } else {
        BOOL isPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_PROTECTION_ID];
        if (isPin){
            [self loadPinView];
        } else {
            //Skip, continue normal flow
            [self provideScanRequest];
        }
    }
}

-(void)loadPinView{
    UIStoryboard *storyboardobj=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    pinView = (PinCodeViewController*)[storyboardobj instantiateViewControllerWithIdentifier:@"pinViewController"];
    pinView.isCallback = YES;
    [pinView setDelegate:self];
    [self presentViewController:pinView animated:YES completion:nil];
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
//                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showTouchIDResultError:(NSError*) authError{
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
//                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onResult:(Boolean)result{
    if (result){
        [pinView dismissViewControllerAnimated:YES completion:nil];
        [self provideScanRequest];
    }
}

@end
