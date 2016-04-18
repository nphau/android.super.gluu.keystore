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
    NSURL* serverURL = [NSURL URLWithString:[info application]];
    NSString*  ip = [self addressForHostname:[serverURL host]];
    locationLabel.text = ip;//[info locationIP];//[ApproveDenyViewController getIPAddress];
    cityNameLabel.text = [info locationCity];
    typeLabel.text = [info authenticationType];
    
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

- (NSString *)addressForHostname:(NSString *)hostname {
//    NSString *ipAddress = hostname;
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer
//                                  serializerWithReadingOptions:NSJSONReadingAllowFragments];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
//    
//    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
//    
//    [manager GET:@"http://ip-api.com/json/107.170.100.96" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
    // prepare JSON request
    
    NSArray *addresses = [self addressesForHostname:hostname];
//    NSArray *addresses2 = [self addressesForHostname2:hostname];
    if ([addresses count] > 0)
        return [addresses objectAtIndex:0];
    else
        return nil;
//        return ipAddress;
}

- (NSArray *)addressesForHostname:(NSString *)hostname {
    // Get the addresses for the given hostname.
    CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostname);
    BOOL isSuccess = CFHostStartInfoResolution(hostRef, kCFHostAddresses, nil);
    if (!isSuccess) return nil;
    CFArrayRef addressesRef = CFHostGetAddressing(hostRef, nil);
    if (addressesRef == nil) return nil;
    
    // Convert these addresses into strings.
    char ipAddress[INET6_ADDRSTRLEN];
    NSMutableArray *addresses = [NSMutableArray array];
    CFIndex numAddresses = CFArrayGetCount(addressesRef);
    for (CFIndex currentIndex = 0; currentIndex < numAddresses; currentIndex++) {
        struct sockaddr *address = (struct sockaddr *)CFDataGetBytePtr(CFArrayGetValueAtIndex(addressesRef, currentIndex));
        if (address == nil) return nil;
        getnameinfo(address, address->sa_len, ipAddress, INET6_ADDRSTRLEN, nil, 0, NI_NUMERICHOST);
//        if (ipAddress == nil) return nil;
        [addresses addObject:[NSString stringWithCString:ipAddress encoding:NSASCIIStringEncoding]];
    }
    
    return addresses;
}

- (NSArray *)addressesForHostname2:(NSString *)hostname {
    const char* hostnameC = [hostname UTF8String];
    
    struct addrinfo hints, *res;
    struct sockaddr_in *s4;
    struct sockaddr_in6 *s6;
    int retval;
    char buf[64];
    NSMutableArray *result; //the array which will be return
    NSMutableArray *result4; //the array of IPv4, to order them at the end
    NSString *previousIP = nil;
    
    memset (&hints, 0, sizeof (struct addrinfo));
    hints.ai_family = PF_UNSPEC;//AF_INET6;
    hints.ai_flags = AI_CANONNAME;
    //AI_ADDRCONFIG, AI_ALL, AI_CANONNAME,	AI_NUMERICHOST
    //AI_NUMERICSERV, AI_PASSIVE, OR AI_V4MAPPED
    
    retval = getaddrinfo(hostnameC, NULL, &hints, &res);
    if (retval == 0)
    {
        
        if (res->ai_canonname)
        {
            result = [NSMutableArray arrayWithObject:[NSString stringWithUTF8String:res->ai_canonname]];
        }
        else
        {
            //it means the DNS didn't know this host
            return nil;
        }
        result4= [NSMutableArray array];
        while (res) {
            switch (res->ai_family){
                case AF_INET6:
                    s6 = (struct sockaddr_in6 *)res->ai_addr;
                    if(inet_ntop(res->ai_family, (void *)&(s6->sin6_addr), buf, sizeof(buf))
                       == NULL)
                    {
                        NSLog(@"inet_ntop failed for v6!\n");
                    }
                    else
                    {
                        //surprisingly every address is in double, let's add this test
                        if (![previousIP isEqualToString:[NSString stringWithUTF8String:buf]]) {
                            [result addObject:[NSString stringWithUTF8String:buf]];
                        }
                    }
                    break;
                    
                case AF_INET:
                    s4 = (struct sockaddr_in *)res->ai_addr;
                    if(inet_ntop(res->ai_family, (void *)&(s4->sin_addr), buf, sizeof(buf))
                       == NULL)
                    {
                        NSLog(@"inet_ntop failed for v4!\n");
                    }
                    else
                    {
                        //surprisingly every address is in double, let's add this test
                        if (![previousIP isEqualToString:[NSString stringWithUTF8String:buf]]) {
                            [result4 addObject:[NSString stringWithUTF8String:buf]];
                        }
                    }
                    break;
                default:
                    NSLog(@"Neither IPv4 nor IPv6!");
                    
            }
            //surprisingly every address is in double, let's add this test
            previousIP = [NSString stringWithUTF8String:buf];
            
            res = res->ai_next;
        }
    }else{
        NSLog(@"no IP found");
        return nil;
    }
    
    return [result arrayByAddingObjectsFromArray:result4];
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

// get the IP address of current-device
+ (NSString *)getIPAddress:(NSString*)address {
    NSURL* url = [NSURL URLWithString:address];
    Boolean result;
    CFHostRef hostRef;
    CFArrayRef addresses = NULL;
    NSString *hostname = [url host];
    NSString *ipAddress = @"";
    
    hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostname);
    if (hostRef) {
        result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL); // pass an error instead of NULL here to find out why it failed
        if (result == TRUE) {
            addresses = CFHostGetAddressing(hostRef, &result);
        }
    }
    
    if (result == TRUE) {
        CFIndex index = 0;
        CFDataRef ref = (CFDataRef) CFArrayGetValueAtIndex(addresses, index);
        struct sockaddr_in* remoteAddr;
        char *ip_address;
        remoteAddr = (struct sockaddr_in*) CFDataGetBytePtr(ref);
        if (remoteAddr != NULL) {
            ip_address = inet_ntoa(remoteAddr->sin_addr);
        }
        ipAddress = [NSString stringWithCString:ip_address encoding:NSUTF8StringEncoding];
    }
//    struct ifaddrs *interfaces = NULL;
//    struct ifaddrs *temp_addr = NULL;
//    int success = 0;
//    // retrieve the current interfaces - returns 0 on success
//    success = getifaddrs(&interfaces);
//    if (success == 0) {
//        // Loop through linked list of interfaces
//        temp_addr = interfaces;
//        while(temp_addr != NULL) {
//            if(temp_addr->ifa_addr->sa_family == AF_INET) {
//                // Check if interface is en0 which is the wifi connection on the iPhone
//                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
//                    // Get NSString from C String
//                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
//                }
//            }
//            temp_addr = temp_addr->ifa_next;
//        }
//    }
//    freeifaddrs(interfaces);
    return ipAddress;
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
