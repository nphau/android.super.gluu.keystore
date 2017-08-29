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
    if ([tokenEntity isKindOfClass:[TokenEntity class]]){
        _key = [tokenEntity->keyHandle base64EncodedString];
        NSURL* urlIssuer = [NSURL URLWithString:tokenEntity->issuer];
        NSString* keyName = tokenEntity->keyName == nil ? [NSString stringWithFormat:@"https://%@", urlIssuer.host] : tokenEntity->keyName;
        _keyHandleNameLabel.text = keyName;
        keyHandleTime.text = [self getTime:tokenEntity->pairingTime];
        self.accessibilityLabel = tokenEntity->application;
        self.accessibilityValue = tokenEntity->userName;
        if ([tokenEntity isExternalKey]){
            _keyHandleNameLabel.textColor = [UIColor colorWithRed:22/256.0 green:159/256.0 blue:220/256.0 alpha:1.0];
            _bleLabel.hidden = NO;
        } else {
            _bleLabel.hidden = YES;
        }
    }
}

-(NSString*)getTime:(NSString*)createdTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    NSDate* date = [formatter dateFromString:createdTime];
    [formatter setDateFormat:@"MMM dd, yyyy hh:mm:ss"];
    return [formatter stringFromDate:date];
}

@end
