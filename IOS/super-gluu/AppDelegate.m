//
//  AppDelegate.m
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/1/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import "AppDelegate.h"
#import "TokenDevice.h"
#import "Constants.h"
#import "OXPushManager.h"
#import "NHNetworkTime.h"
#import "AppConfiguration.h"
#import <AudioToolbox/AudioServices.h>

//#import <UbertestersSDK/Ubertesters.h>

@import GoogleMobileAds;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //For Push Notifications
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7){//for ios 8 and higth
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [self registerForNotification];
    }
    NSDictionary *remoteNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    //Accept push notification when app is not open
    if (remoteNotif != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:remoteNotif forKey:NotificationRequest];
    }
    
    //Setup Basic
    int count = (int)[[NSUserDefaults standardUserDefaults] integerForKey:LOCKED_ATTEMPTS_COUNT];
    if (count == 0){
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:LOCKED_ATTEMPTS_COUNT];
    }
    
    [[NHNetworkClock sharedNetworkClock] synchronize];
    
    //Ubertersters SDK initialization
//    [[Ubertesters shared] initialize];
    
    
    [self setupAppearance];
    
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-3326465223655655~8301521230"];
    
    return YES;
}

#pragma Push Notification

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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken  {
    NSString* token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[TokenDevice sharedInstance] setDeviceToken:token];
    NSLog(@"Token is: %@", token);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    if(application.applicationState == UIApplicationStateBackground) {
        
        NSLog(@"Inactive - the user has tapped in the notification when app was closed or in background");
        //do some tasks
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:PUSH_CAME_DATE];
//        [self manageRemoteNotification:userInfo];
        completionHandler(UIBackgroundFetchResultNewData);
    }
    if ( application.applicationState == UIApplicationStateActive ){
        // app was already in the foreground and we show custom push notifications view
        [self parsePushAndNotify:userInfo];
    } else {
        // app was just brought from background to foreground and we wait when user click or slide on push notification
        _pushNotificationRequest = userInfo;
        [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:NotificationRequest];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NotificationRequestActionsApprove];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NotificationRequestActionsDeny];
    NSLog(@"Received notification: %@", userInfo);
}

-(void)parsePushAndNotify:(NSDictionary*)pushInfo{
    if (pushInfo != nil) {
        NSData *data;
        NSString* requestString = [pushInfo objectForKey:@"request"];
        if ([requestString isKindOfClass:[NSDictionary class]]){
            data = [NSJSONSerialization dataWithJSONObject:requestString options:NSJSONWritingPrettyPrinted error:nil];
        } else {
            data = [requestString dataUsingEncoding:NSUTF8StringEncoding];
        }
        NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (jsonDictionary != nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUSH_ONLINE object:jsonDictionary];
        }
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
    if ([identifier isEqualToString:NotificationActionOneIdent]) {
        
        NSLog(@"You chose action Approve.");
        isDecline = NO;
        _pushNotificationRequest = userInfo;
        [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:NotificationRequest];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NotificationRequestActionsApprove];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NotificationRequestActionsDeny];
    }
    else if ([identifier isEqualToString:NotificationActionTwoIdent]) {
        NSLog(@"You chose action Deny.");
        isDecline = YES;
        _pushNotificationRequest = userInfo;
        [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:NotificationRequest];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NotificationRequestActionsDeny];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NotificationRequestActionsApprove];
    }
    if (completionHandler) {
        
        completionHandler();
    }
    [self sendQRReuest:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NHNetworkClock sharedNetworkClock] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"APP STARTING.....");
    [self sendQRReuest:NO];
    
    // eric
/*
    if (_pushNotificationRequest != nil){
        [[NSUserDefaults standardUserDefaults] setObject:_pushNotificationRequest forKey:NotificationRequest];
    }
 */
    
    
    [[NHNetworkClock sharedNetworkClock] synchronize];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

-(void)sendQRReuest:(BOOL)isAction{
    if (_pushNotificationRequest != nil) {
        NSData *data;
        NSString* requestString = [_pushNotificationRequest objectForKey:@"request"];
        if ([requestString isKindOfClass:[NSDictionary class]]){
            data = [NSJSONSerialization dataWithJSONObject:requestString options:NSJSONWritingPrettyPrinted error:nil];
        } else {
            data = [requestString dataUsingEncoding:NSUTF8StringEncoding];
        }
        NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (![self isTimeOver]){
            if (jsonDictionary){
                if (!isAction){
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUSH_RECEIVED object:jsonDictionary];
                } else {
                    isDecline ?
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUSH_RECEIVED_DENY object:jsonDictionary]
                    :
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUSH_RECEIVED_APPROVE object:jsonDictionary]
                    ;
                }
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUSH_TIMEOVER object:jsonDictionary];
        }
        _pushNotificationRequest = nil;
    }
}

-(BOOL)isTimeOver{
    NSDate* createdTime = [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_CAME_DATE];
    if (createdTime == nil) return NO;
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
////    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
//    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
//
//    //conversion of NSString to NSDate
//    NSDate *dateFromString = [formatter dateFromString:createdTimeStr];
//    if (dateFromString == nil) return NO;
    NSDate* currentDate = [NSDate date];
    NSTimeInterval distanceBetweenDates = [currentDate timeIntervalSinceDate:createdTime];
    int seconds = (int)distanceBetweenDates;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PUSH_CAME_DATE];
    return seconds > WAITING_TIME;//){
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUSH_TIMEOVER object:jsonDictionary];
//        return ;
//    } else {
//        return YES;
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [[NHNetworkClock sharedNetworkClock] synchronize];
}



#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.gluu.ios.oxPush2_IOS" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"super_gluu" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"super-gluu.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Appearance

- (void)setupAppearance {
    
    [[UINavigationBar appearance] setBarTintColor: [Constant appGreenColor]];
    [[UINavigationBar appearance] setTintColor: UIColor.whiteColor];
    [[UINavigationBar appearance] setTranslucent:false];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [[UITableView appearance] setBackgroundColor:[Constant tableBackgroundColor]];
    
    [[UISwitch appearance] setOnTintColor:[Constant appGreenColor]];
    
    NSDictionary *titleAttributes = @{
                                 NSForegroundColorAttributeName: [UIColor whiteColor]
//                                 NSShadowAttributeName: shadow,
//                                 NSFontAttributeName: [UIFont fontWithName:@"AmericanTypewriter" size:16.0]
                                 };
    
    [[UINavigationBar appearance] setTitleTextAttributes: titleAttributes];
    
    UIImage *backImage = [[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [[UINavigationBar appearance] setBackIndicatorImage:backImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backImage];

}


@end
