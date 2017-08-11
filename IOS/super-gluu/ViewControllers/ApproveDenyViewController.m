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
    [self updateInfo];
    if (!_isLogInfo){
        [self initAndStartTimer];
    }
    timerView.layer.cornerRadius = CORNER_RADIUS;
    [approveImage setCenter:approveRequest.center];
    [denyImage setCenter:denyRequest.center];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL:)];
    serverUrlLabel.userInteractionEnabled = YES;
    [serverUrlLabel addGestureRecognizer:tap];
    [timerView setBackgroundColor:[[AppConfiguration sharedInstance] systemColor]];
}

- (void)openURL:(UITapGestureRecognizer *)tap
{
    UILabel *label = (UILabel *)tap.view;
    NSURL *targetURL = [NSURL URLWithString:label.text];
    [[UIApplication sharedApplication] openURL:targetURL];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    if (info->userName == nil){
        [userNameView setHidden:YES];
        [self moveUpViews];
    } else {
        [userNameView setHidden:NO];
        userNameLabel.text = info->userName;
    }
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
        [backButton setHidden:NO];
        [timerView setHidden:YES];
        [buttonView setHidden:YES];
        titleLabel.text = NSLocalizedString(@"Information", @"Information");
        titleLabel.center = CGPointMake(titleLabel.center.x, navigationView.frame.origin.y + navigationView.frame.size.height + 50);
        scrollView.frame = CGRectMake(scrollView.frame.origin.x, titleLabel.center.y + 20, scrollView.frame.size.width, scrollView.frame.size.height + 50);
    }
}

-(void)moveUpViews{
    [locationView setCenter:CGPointMake(locationView.center.x, locationView.center.y - moveUpY)];
    [timeView setCenter:CGPointMake(timeView.center.x, timeView.center.y - moveUpY)];
}

-(IBAction)onApprove:(id)sender{
    [delegate approveRequest];
    [self back];
    [timer invalidate];
    timer = nil;
}

-(IBAction)onDeny:(id)sender{
    [delegate denyRequest];
    [self back];
    [timer invalidate];
    timer = nil;
}

-(IBAction)back{
    [self.navigationController popViewControllerAnimated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
