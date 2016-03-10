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

#define RELEASE_SERVER @"Gluu Server CE Release"
#define DEV_SERVER @"Gluu Server CE Dev"

#define moveUpY 70
#define LANDSCAPE_Y 290

@interface ApproveDenyViewController ()

@end

@implementation ApproveDenyViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocalization];
    [self initLocation];
    [self initBackButtonUI];
    [self updateInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
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
                [buttonView setCenter:CGPointMake(buttonView.center.x, buttonView.center.y + LANDSCAPE_Y)];
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
                [buttonView setCenter:CGPointMake(buttonView.center.x, buttonView.center.y - LANDSCAPE_Y)];
                [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width, 800)];
                scrollView.delegate = self;
                scrollView.scrollEnabled = YES;
                isLandScape = YES;
            }
            
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
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
    locationLabel.text = [self getIPAddress];
    
    if (_isLogInfo){
        [backButton setHidden:NO];
        [titleLabel setHidden:YES];
        [buttonView setHidden:YES];
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
}

-(IBAction)onDeny:(id)sender{
    [delegate denyRequest];
}

-(IBAction)back:(id)sender{
    [delegate denyRequest];
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
                      
                      cityNameLabel.text = address;
                      
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
    cityNameLabel.text = NSLocalizedString(@"FailedGettingCityName", @"Failed getting cityName");
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
- (NSString *)getIPAddress {
    NSString *address = @"error";
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
