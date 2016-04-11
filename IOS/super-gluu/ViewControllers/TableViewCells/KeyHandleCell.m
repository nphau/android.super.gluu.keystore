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
    [self.keyHandleTextField setText:[tokenEntity keyName]];
    keyHandleTime.text = [self getTime:[tokenEntity pairingTime]];
    self.accessibilityLabel = [tokenEntity application];
}

-(NSString*)getTime:(NSString*)createdTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    NSDate* date = [formatter dateFromString:createdTime];
    [formatter setDateFormat:@" MMM dd, yyyy hh:mm:ss"];
    return [formatter stringFromDate:date];
}

@end
