//
//  LogsTableCell.m
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/12/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import "LogsTableCell.h"
#import "ApproveDenyViewController.h"
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
            [self adoptLogByState:serverURL andState:userLoginInfo.logState];
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

-(void)adoptLogByState:(NSURL*)serverURL andState:(LogState)logState{
    LogState state = logState;
    switch (state) {
        case LOGIN_SUCCESS:
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LoggedIn", @"Logged in"), [serverURL host]];
            break;
            
        case LOGIN_FAILED:
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LoggedInFailed", @"Logged in failed"), [serverURL host]];
            [_logo setImage:[UIImage imageNamed:@"gluuIconRed.png"]];
            break;
        
        case ENROLL_SUCCESS:
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"EnrollIn", @"Enroll in"), [serverURL host]];
            break;
            
        case ENROLL_FAILED:
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"EnrollInFailed", @"Enroll in failed"), [serverURL host]];
            [_logo setImage:[UIImage imageNamed:@"gluuIconRed.png"]];
            break;
            
        default:
            break;
    }
}

@end
