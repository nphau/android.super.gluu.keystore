//
//  LogsTableCell.m
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/12/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import "LogsTableCell.h"
#import "ApproveDenyViewController.h"
#import "UserLoginInfo.h"
#import "NSDate+NVTimeAgo.h"

#define RELEASE_SERVER @"Gluu CE Release"
#define DEV_SERVER @"Gluu CE Dev"

@implementation LogsTableCell

-(void)setData:(UserLoginInfo*)userLoginInfo{
    if (userLoginInfo != nil){
        _logTime.text = [self getTimeAgo:[userLoginInfo created]];
        NSString* server = [userLoginInfo issuer];
        if (server != nil){
            NSURL* serverURL = [NSURL URLWithString:server];
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LoggedIn", @"Logged in"), [serverURL host]];
        }
        [_logTime setHidden:NO];
        return;
    }
    _logTime.text = @"";
    [_logTime setHidden:YES];
}

-(NSString*)getTimeAgo:(NSString*)createdTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSSSSS"];
    NSDate* date = [formatter dateFromString:createdTime];
    return [date formattedAsTimeAgo];
}

@end
