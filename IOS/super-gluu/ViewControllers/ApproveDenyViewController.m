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

#define RELEASE_SERVER @"Gluu Server CE Release"
#define DEV_SERVER @"Gluu Server CE Dev"

#define moveUpY 70
#define LANDSCAPE_Y 290
#define LANDSCAPE_Y_IPHONE_5 245
#define START_TIME 60

#define ADDRESS_ERROR @"error"

@interface ApproveDenyViewController ()

@end

@implementation ApproveDenyViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocalization];
    [self initBackButtonUI];
    [self updateInfo];
    if (!_isLogInfo){
        [self initAndStartTimer];
    }
    timerView.layer.cornerRadius = CORNER_RADIUS;
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [self checkDeviceOrientation];
}

-(void)initAndStartTimer{
    timerLabel.text = [NSString stringWithFormat:@"%i", START_TIME];
    time = START_TIME;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];


}

-(void)updateTime{
    time--;
    timerLabel.text = [NSString stringWithFormat:@"%i", time];
    if (time == 20){
        [timerView setBackgroundColor:[UIColor yellowColor]];
        [timerLabel setTextColor:[UIColor blackColor]];
        [timerLabelTitle setTextColor:[UIColor blackColor]];
    }
    if (time == 10){
        [timerView setBackgroundColor:[UIColor redColor]];
        [timerLabel setTextColor:[UIColor whiteColor]];
        [timerLabelTitle setTextColor:[UIColor whiteColor]];
    }
    if (time == 0){
        [self onDeny:nil];
        [timer invalidate];
        timer = nil;
    }

}

-(void)checkDeviceOrientation{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
//        [self adjustViewsForOrientation:UIInterfaceOrientationLandscapeLeft];
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
//                if (IS_IPHONE_5 || IS_IPHONE_4){
//                    [buttonView setCenter:CGPointMake(buttonView.center.x, buttonView.center.y + LANDSCAPE_Y_IPHONE_5)];
//                } else {
//                    [buttonView setCenter:CGPointMake(buttonView.center.x, buttonView.center.y + LANDSCAPE_Y)];
//                }
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
//                if (IS_IPHONE_5 || IS_IPHONE_4){
//                    [buttonView setCenter:CGPointMake(buttonView.center.x, buttonView.center.y - LANDSCAPE_Y_IPHONE_5)];
//                } else {
//                    [buttonView setCenter:CGPointMake(buttonView.center.x, buttonView.center.y - LANDSCAPE_Y)];
//                }
                if (_isLogInfo){
                    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height+100)];
                }
                [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width, 300)];
                scrollView.delegate = self;
                scrollView.scrollEnabled = YES;
                isLandScape = YES;
            }
            
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
}

-(void)initLocalization{
    [approveRequest setTitle:NSLocalizedString(@"Approve", @"Approve") forState:UIControlStateNormal];
    [denyRequest setTitle:NSLocalizedString(@"Deny", @"Deny") forState:UIControlStateNormal];
    titleLabel.text = NSLocalizedString(@"PressApprove", @"To continue, press Approve");
}

-(void)updateInfo{
    UserLoginInfo* info = _userInfo;
    if (info == nil){
        info = [UserLoginInfo sharedInstance];
    }
    if ([info userName] == nil){
        [userNameView setHidden:YES];
        [self moveUpViews];
    } else {
        [userNameView setHidden:NO];
        userNameLabel.text = [info userName];
    }
    NSString* server = [info application];
    serverUrlLabel.text = server;
    if (server != nil){
        if ([server rangeOfString:@"release"].location != NSNotFound){
            serverNameLabel.text = RELEASE_SERVER;
        } else {
            serverNameLabel.text = DEV_SERVER;
        }
    }
    createdTimeLabel.text = [self getTime:[info created]];
    createdDateLabel.text = [self getDate:[info created]];
    locationLabel.text = [info locationIP];//[ApproveDenyViewController getIPAddress];
    cityNameLabel.text = [info locationCity];
    
    if (_isLogInfo){
        [backButton setHidden:NO];
        [timerView setHidden:YES];
        [buttonView setHidden:YES];
        titleLabel.text = NSLocalizedString(@"Information", @"Information");
//        int y = 35;
//        [serverView setCenter:CGPointMake(serverView.center.x, serverView.center.y - y)];
//        [userNameView setCenter:CGPointMake(userNameView.center.x, userNameView.center.y - y)];
//        [locationView setCenter:CGPointMake(locationView.center.x, locationView.center.y - y)];
//        [timeView setCenter:CGPointMake(timeView.center.x, timeView.center.y - y)];
    }
}

-(void)moveUpViews{
    [locationView setCenter:CGPointMake(locationView.center.x, locationView.center.y - moveUpY)];
    [timeView setCenter:CGPointMake(timeView.center.x, timeView.center.y - moveUpY)];
}

-(void)initBackButtonUI{
    [[backButton layer] setMasksToBounds:YES];
    [[backButton layer] setCornerRadius:CORNER_RADIUS];
    [[backButton layer] setBorderWidth:2.0f];
    [[backButton layer] setBorderColor:[UIColor blackColor].CGColor];
}

-(IBAction)onApprove:(id)sender{
    [delegate approveRequest];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)onDeny:(id)sender{
    [delegate denyRequest];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)getTime:(NSString*)date{
    if (date == nil) return nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate* dateTime = [self getNSDate:date];
    [formatter setDateFormat:@"hh:mm:ss"];
    NSString* time = [formatter stringFromDate:dateTime];
    
    return time;
}

-(NSString*)getDate:(NSString*)date{
    if (date == nil) return nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate* dateT = [self getNSDate:date];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    NSString* dateTime = [formatter stringFromDate:dateT];
    
    return dateTime;
}

-(NSDate*)getNSDate:(NSString*)dateTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSSSSS"];
    NSDate* date = [formatter dateFromString:dateTime];
    
    return date;
}

// get the IP address of current-device
+ (NSString *)getIPAddress {
    NSString *address = ADDRESS_ERROR;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    if ([address isEqualToString:ADDRESS_ERROR]){
        CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netinfo subscriberCellularProvider];
        address = [carrier carrierName];
    }
    return address;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
