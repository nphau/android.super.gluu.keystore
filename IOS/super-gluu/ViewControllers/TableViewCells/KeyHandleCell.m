//
//  KeyHandleCell.m
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/10/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import "KeyHandleCell.h"
#import "Base64.h"

@implementation KeyHandleCell

-(void)setData:(TokenEntity*)tokenEntity{
    _key = [[tokenEntity keyHandle] base64EncodedString];
    NSString* application = [tokenEntity application];
    NSURL* urlApplication = [NSURL URLWithString:application];
    NSString* displayName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"keyHandleFor", @"keyHandleFor"), [urlApplication host]];
    NSString* keyHandleName = [[NSUserDefaults standardUserDefaults] stringForKey:@"keyHandleDisplayName"];
    displayName = keyHandleName != nil ? keyHandleName : displayName;
    [self.keyHandleTextField setText:displayName];
    
    keyHandleTime.text = [self getTime:[tokenEntity pairingTime]];
}

-(NSString*)getTime:(NSString*)createdTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSSSSS"];
    NSDate* date = [formatter dateFromString:createdTime];
    [formatter setDateFormat:@" MMM dd, yyyy hh:mm:ss"];
    return [formatter stringFromDate:date];
}

@end
