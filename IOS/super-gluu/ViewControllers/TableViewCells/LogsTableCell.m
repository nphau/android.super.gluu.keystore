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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialisation code here
    }
    return self;
}

-(void)setData:(UserLoginInfo*)userLoginInfo{
    NSString* server = userLoginInfo->issuer;
    if (server != nil){
        NSURL* serverURL = [NSURL URLWithString:server];
        [self adoptLogByState:serverURL andState:userLoginInfo->logState];
    }
    _logTime.text = [self getTimeAgo:userLoginInfo->created];
}

-(NSString*)getTimeAgo:(NSString*)createdTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    NSDate* date = [formatter dateFromString:createdTime];
    return [date formattedAsTimeAgo];
}

-(void)adoptLogByState:(NSURL*)serverURL andState:(LogState)logState{
    LogState state = logState;
    [_logo setImage:[[AppConfiguration sharedInstance] systemLogIcon]];
    switch (state) {
        case LOGIN_SUCCESS:
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LoggedIn", @"Logged in"), [serverURL host]];
            break;
            
        case LOGIN_FAILED:
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LoggedInFailed", @"Logged in failed"), [serverURL host]];
            [_logo setImage:[[AppConfiguration sharedInstance] systemLogRedIcon]];
            break;
        
        case ENROLL_SUCCESS:
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"EnrollIn", @"Enroll in"), [serverURL host]];
            break;
            
        case ENROLL_FAILED:
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"EnrollInFailed", @"Enroll in failed"), [serverURL host]];
            [_logo setImage:[[AppConfiguration sharedInstance] systemLogRedIcon]];
            break;
            
        case ENROLL_DECLINED:
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"EnrollDeclined", @"Login declined"), [serverURL host]];
            break;
            
        case LOGIN_DECLINED:
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LoginDeclined", @"Enroll declined"), [serverURL host]];
            break;
            
        case UNKNOWN_ERROR:
            _logLabel.text = [NSString stringWithFormat:NSLocalizedString(@"UnKnownError", @"UnKnownError"), [serverURL host]];
            break;
            
        default:
            break;
    }
}

- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1.0]
                                                title:@"View"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:246/255.0 green:0.0 blue:0.188 alpha:12/255.0]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

@end
