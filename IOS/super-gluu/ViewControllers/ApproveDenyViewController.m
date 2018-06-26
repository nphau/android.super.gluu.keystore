//
//  ApproveDenyViewController.m
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/3/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "ApproveDenyViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <CFNetwork/CFNetwork.h>
#import "NSString+URLEncode.h"

#import "OXPushManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "DataStoreManager.h"
#import "SCLAlertView.h"


#define moveUpY 70
#define LANDSCAPE_Y 290
#define LANDSCAPE_Y_IPHONE_5 245
#define START_TIME 40

#define ADDRESS_ERROR @"error"

@interface ApproveDenyViewController () {

OXPushManager* oxPushManager;
    SCLAlertView* alertView;

}

@end

@implementation ApproveDenyViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocalization];
    [self updateInfo];
    
    
    if (!_isLogInfo) {
        [self initAndStartTimer];
    } else {
        // showing info about a specific log
        SEL sel = @selector(showDeleteLogAlert);
        UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_nav_trash"] style:UIBarButtonItemStylePlain target:self action:sel];
        self.navigationItem.rightBarButtonItem = trashButton;
    }
    
    [self setupDisplay];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL:)];
    serverUrlLabel.userInteractionEnabled = YES;
    [serverUrlLabel addGestureRecognizer:tap];
    
//    [timerView setProgressColor:[[AppConfiguration sharedInstance] systemColor]];
//    [timerLabel setTextColor:[[AppConfiguration sharedInstance] systemColor]];
}

- (void)setupDisplay {
    
    for (UIView *v in separators) {
        v.backgroundColor = [Constant tableBackgroundColor];
    }
    
    for (UILabel *l in titleLabels) {
        l.textColor = [UIColor blackColor];
//        l.font = [Constant regularFont: 16.0];
    }
    
    cityNameLabel.textColor = [Constant lightGreyTextColor];
    createdDateLabel.textColor = [Constant lightGreyTextColor];
    
    alertView = [[SCLAlertView alloc] initWithNewWindow];
}

- (void)openURL:(UITapGestureRecognizer *)tap
{
    UILabel *label = (UILabel *)tap.view;
    NSURL *targetURL = [NSURL URLWithString:label.text];
    [[UIApplication sharedApplication] openURL:targetURL];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    if (!_isLogInfo){
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_FREE object:nil];
//    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    if (!_isLogInfo) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_NOT_FREE object:nil];
//    }
}

-(void)initAndStartTimer{
    
    // Add countdown timer label to right side of navbar
    
    timerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 24)];
//    timerLabel.font = customFont;
    timerLabel.numberOfLines = 1;
    timerLabel.backgroundColor = [UIColor clearColor];
    timerLabel.textColor = [UIColor whiteColor];
    timerLabel.textAlignment = NSTextAlignmentRight;
    
    UIBarButtonItem *timerBBI = [[UIBarButtonItem alloc] initWithCustomView: timerLabel];
    
    self.navigationItem.rightBarButtonItem = timerBBI;
    
    timerLabel.text = [NSString stringWithFormat:@"%i", START_TIME];
    time = START_TIME;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];

}

-(void)updateTime{
    time--;
    timerLabel.text = [NSString stringWithFormat:@"%i", time];
    if (time == 20){
        [timerView setProgressColor:[UIColor yellowColor]];
        [timerLabel setTextColor:[UIColor yellowColor]];
    }
    if (time == 10){
        [timerView setProgressColor:[UIColor redColor]];
        [timerLabel setTextColor:[UIColor redColor]];
    }
    if (time == 0){
        [self onDeny:nil];
    }

}

-(void)initLocalization{
//    [approveRequest setTitle:NSLocalizedString(@"Approve", @"Approve") forState:UIControlStateNormal];
//    [denyRequest setTitle:NSLocalizedString(@"Deny", @"Deny") forState:UIControlStateNormal];
    titleLabel.text = NSLocalizedString(@"PressApprove", @"To continue, press Approve");
}

-(void)updateInfo{
    UserLoginInfo* info = _userInfo;
    if (info == nil){
        info = [UserLoginInfo sharedInstance];
    }
//    if (info->userName == nil){
//        [userNameView setHidden:YES];
////        [self moveUpViews];
//    } else {
//        [userNameView setHidden:NO];
        userNameLabel.text = info->userName;
//    }
    NSString* server = info->issuer;
    serverUrlLabel.text = server;
    if (server != nil){
        NSURL* serverURL = [NSURL URLWithString:server];
        serverNameLabel.text = [NSString stringWithFormat:@"Gluu Sever %@", [serverURL host]];
    }
    createdTimeLabel.text = [self getTime:info->created];
    createdDateLabel.text = [self getDate:info->created];
    if (info->locationIP != nil){
        locationLabel.text = info->locationIP;
    }
    if (info->locationCity != nil){
        NSString* location = info->locationCity;
        NSString* locationDecode = [location URLDecode];
        cityNameLabel.text = locationDecode;
    }
    typeLabel.text = info->authenticationType;
    
    if (_isLogInfo){
        [approveDenyContainerView setHidden:YES];
        [backButton setHidden:NO];
        [timerView setHidden:YES];
        [buttonView setHidden:YES];
        titleLabel.text = NSLocalizedString(@"Information", @"Information");
    } else {
        self.navigationItem.hidesBackButton = YES;
        
        self.title = @"Permission Approval";
        
        [navigationView setHidden:YES];
    }
    [self moveUpViews];
}

- (void)moveUpViews{
    int moveUpPosition = titleLabel.center.y - timerView.center.y;
    [mainInfoView setCenter:CGPointMake(mainInfoView.center.x, titleLabel.center.y + titleLabel.frame.size.height/1.5)];
    if (!_isLogInfo){
        [timerView setCenter:CGPointMake(timerView.center.x, timerView.center.y - moveUpPosition)];
        [titleLabel setCenter:CGPointMake(titleLabel.center.x, titleLabel.center.y - moveUpPosition)];
        [mainInfoView setFrame:CGRectMake(mainInfoView.frame.origin.x, titleLabel.center.y + titleLabel.frame.size.height/2, mainInfoView.frame.size.width, mainInfoView.frame.size.height)];
    }
}

- (IBAction)onApprove:(id)sender {
    
    [self.view setUserInteractionEnabled:false];
    
    [self showAlertViewWithTitle:@"Approving..." andMessage:@"" withCloseButton:false];
    
    [[AuthHelper sharedInstance] approveRequestWithCompletion:^(BOOL success, NSString *errorMessage) {
        
        [alertView hideView];
        
//        if (success == false) {
//            [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitle", @"Info") andMessage:errorMessage withCloseButton:true];
//        } else {
//            NSString* message = @"";
//            message = NSLocalizedString(@"SuccessEnrollment", @"Success Authentication");
//
//            [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitleSuccess", @"Success") andMessage:message withCloseButton:true];
//        }
     
        [self.view setUserInteractionEnabled:true];
        [self.navigationController popToRootViewControllerAnimated:true];
    }];
    
    [timer invalidate];
    timer = nil;
}

- (IBAction)onDeny:(id)sender {
    
    [self.view setUserInteractionEnabled:false];
    
    [self showAlertViewWithTitle:@"Denying..." andMessage:@"" withCloseButton:false];
    
    [[AuthHelper sharedInstance] denyRequestWithCompletion:^(BOOL success, NSString *errorMessage) {
        
        [alertView hideView];
        
//        if (success == false) {
//            [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitle", @"Info") andMessage:errorMessage withCloseButton:true];
//        } else {
//            NSString* message = @"";
//            message = NSLocalizedString(@"SuccessEnrollment", @"Success Authentication");
//
//            [self showAlertViewWithTitle:NSLocalizedString(@"AlertTitleSuccess", @"Success") andMessage:message withCloseButton:true];
//        }
        
        [self.view setUserInteractionEnabled:true];
        [self.navigationController popToRootViewControllerAnimated:true];
    }];
    
//    [delegate denyRequest];
    
    [timer invalidate];
    timer = nil;
}


- (void)showAlertViewWithTitle:(NSString*)title andMessage:(NSString*)message withCloseButton:(BOOL)showCloseButton {
    
    NSString *closeTitle;
    
    if (alertView == nil) {
        alertView = [[SCLAlertView alloc] initWithNewWindow];
    }
    
    if (showCloseButton == true) {
        closeTitle = @"Close";
    }
    
    [alertView showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:title subTitle:message closeButtonTitle:closeTitle duration:20.0];
    
}

-(IBAction)onDeleteClick{
    [self showDeleteLogAlert];
}

-(NSString*)getTime:(NSString*)date{
    if (date == nil) return nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate* dateTime = [self getNSDate:date];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString* times = [formatter stringFromDate:dateTime];
    
    return times;
}

-(NSString*)getDate:(NSString*)date{
    if (date == nil) return nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate* dateT = [self getNSDate:date];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString* dateTime = [formatter stringFromDate:dateT];
    
    return dateTime;
}

-(NSDate*)getNSDate:(NSString*)dateTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    NSDate* date = [formatter dateFromString:dateTime];
    
    return date;
}

- (void)showDeleteLogAlert {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:NSLocalizedString(@"YES", @"YES") actionBlock:^(void) {
        NSLog(@"YES clicked");
        if (_userInfo != nil){
            [self deleteLog:_userInfo];
        }
    }];
    SCLButton* noButton = [alert addButton:NSLocalizedString(@"NO", @"NO") actionBlock:^(void) {
        NSLog(@"NO clicked");
    }];
    [noButton setDefaultBackgroundColor:[UIColor redColor]];
    [alert showCustom:[UIImage imageNamed:@"delete_action_titleIcon"] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"AlertTitle", @"Into") subTitle:NSLocalizedString(@"ClearLog", @"Clear Log") closeButtonTitle:nil duration:0.0f];
}

-(void)deleteLog:(UserLoginInfo*)log {
        // Eric
    [[DataStoreManager sharedInstance] deleteLog:log];
    
    [self.navigationController popViewControllerAnimated:true];
}


@end
