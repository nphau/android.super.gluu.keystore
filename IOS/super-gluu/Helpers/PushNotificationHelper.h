//
//  PushNotificationHelper.h
//  Super Gluu
//
//  Created by Eric Webb on 1/26/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotificationHelper : NSObject

+ (BOOL)isLastPushExpired;
+ (NSDictionary *)parsedInfo:(NSDictionary *)pushInfo;

@end
