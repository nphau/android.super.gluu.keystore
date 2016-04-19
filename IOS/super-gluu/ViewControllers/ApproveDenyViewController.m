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
#import <netinet/in.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/ethernet.h>
#import <net/if_dl.h>

#import "AFHTTPRequestOperationManager.h"

#define moveUpY 70
#define LANDSCAPE_Y 290
#define LANDSCAPE_Y_IPHONE_5 245
#define START_TIME 40

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
    [approveImage setCenter:approveRequest.center];
    [denyImage setCenter:denyRequest.center];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL:)];
    serverUrlLabel.userInteractionEnabled = YES;
    [serverUrlLabel addGestureRecognizer:tap];
}

- (void)openURL:(UITapGestureRecognizer *)tap
{
    UILabel *label = (UILabel *)tap.view;
    NSURL *targetURL = [NSURL URLWithString:label.text];
    [[UIApplication sharedApplication] openURL:targetURL];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    }

}

-(void)checkDeviceOrientation{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)orientationChanged:(NSNotification *)notification{
    [approveImage setCenter:approveRequest.center];
    [denyImage setCenter:denyRequest.center];
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
    timerLabelTitle.text = NSLocalizedString(@"SecondsLeft", @"seconds left");
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
    NSString* server = [info issuer];
    serverUrlLabel.text = server;
    if (server != nil){
        NSURL* serverURL = [NSURL URLWithString:server];
        serverNameLabel.text = [NSString stringWithFormat:@"Gluu Sever %@", [serverURL host]];
    }
    createdTimeLabel.text = [self getTime:[info created]];
    createdDateLabel.text = [self getDate:[info created]];
    if ([info locationIP] != nil){
        locationLabel.text = [info locationIP];
    }
    if ([info locationCity] != nil){
        cityNameLabel.text = [info locationCity];
    }
    typeLabel.text = [info authenticationType];
    
    if (_isLogInfo){
        [backButton setHidden:NO];
        [timerView setHidden:YES];
        [buttonView setHidden:YES];
        titleLabel.text = NSLocalizedString(@"Information", @"Information");
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
    [timer invalidate];
    timer = nil;
}

-(IBAction)onDeny:(id)sender{
    [delegate denyRequest];
    [self dismissViewControllerAnimated:YES completion:nil];
    [timer invalidate];
    timer = nil;
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
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
//    [formatter setDateFormat:@"hh:mm:ss  aa"];
//    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString* times = [formatter stringFromDate:dateTime];
    
    return times;
}

-(NSString*)getDate:(NSString*)date{
    if (date == nil) return nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate* dateT = [self getNSDate:date];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setDateFormat:@"MMMM dd, yyyy"];
    NSString* dateTime = [formatter stringFromDate:dateT];
    
    return dateTime;
}

-(NSDate*)getNSDate:(NSString*)dateTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeZone:[NSTimeZone localTimeZone]];//timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];//.SSSSSS//:mm:ss
    NSDate* date = [formatter dateFromString:dateTime];
    
    return date;
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
