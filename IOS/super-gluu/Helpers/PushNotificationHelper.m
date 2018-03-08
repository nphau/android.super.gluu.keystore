//
//  PushNotificationHelper.m
//  Super Gluu
//
//  Created by Eric Webb on 1/26/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

#import "PushNotificationHelper.h"

@implementation PushNotificationHelper


+ (BOOL)isLastPushExpired {
    
    NSDate* pushReceivedDate = [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_CAME_DATE];
    
    if (pushReceivedDate == nil) return NO;
    
    NSDate* currentDate = [NSDate date];
    NSTimeInterval distanceBetweenDates = [currentDate timeIntervalSinceDate:pushReceivedDate];
    int seconds = (int)distanceBetweenDates;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PUSH_CAME_DATE];
    
    return seconds > WAITING_TIME;
    
}

+ (NSDictionary *)parsedInfo:(NSDictionary *)pushInfo {
    
    if (pushInfo == nil) { return nil; }
    
    NSData *data;
    NSString* requestString = [pushInfo objectForKey:@"request"];
    
    if ([requestString isKindOfClass:[NSDictionary class]]){
        data = [NSJSONSerialization dataWithJSONObject:requestString options:NSJSONWritingPrettyPrinted error:nil];
    } else {
        data = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
}

@end
