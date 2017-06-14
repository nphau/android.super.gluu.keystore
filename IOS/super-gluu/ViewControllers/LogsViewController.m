//
//  LogsViewController.m
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/12/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import "LogsViewController.h"
#import "LogManager.h"
#import "LogsTableCell.h"
#import "ApproveDenyViewController.h"
#import "DataStoreManager.h"
#import "UserLoginInfo.h"
#import "SCLAlertView.h"
#import "AppConfiguration.h"

@implementation LogsViewController

-(void)viewDidLoad{

    [super viewDidLoad];
    [self getLogs];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPushView) name:NOTIFICATION_PUSH_ONLINE object:nil];
    topView.backgroundColor = [[AppConfiguration sharedInstance] systemColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getLogs];
    [logsTableView reloadData];
}

-(void)initPushView{
    [self.tabBarController setSelectedIndex:0];
}

-(void)getLogs{
    logsArray = [[NSMutableArray alloc] init];
    logsArray = [[NSMutableArray alloc] initWithArray:[[DataStoreManager sharedInstance] getUserLoginInfo]];
    [logsArray count] == 0 ? [logsTableView setHidden:YES] : [logsTableView setHidden:NO];
    [logsArray count] == 0 ? [cleanLogs setHidden:YES] : [cleanLogs setHidden:NO];
    if ([logsArray count] > 0){
        [cleanLogs setHidden:NO];
        [cleanLogs setEnabled:YES];
    }
}

-(IBAction)cleanLogs:(id)sender{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:NSLocalizedString(@"YES", @"YES") actionBlock:^(void) {
        NSLog(@"YES clicked");
        [[DataStoreManager sharedInstance] deleteAllLogs];
        [self getLogs];
    }];
    [alert addButton:NSLocalizedString(@"NO", @"NO") actionBlock:^(void) {
        NSLog(@"NO clicked");
    }];
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"AlertTitle", @"Into") subTitle:NSLocalizedString(@"ClearLogs", @"Clear Logs") closeButtonTitle:nil duration:0.0f];
}

#pragma mark UITableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return logsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserLoginInfo* userInfo = (UserLoginInfo*)[logsArray objectAtIndex:indexPath.row];
    CGFloat height = 130.0;
    if (userInfo->logState == LOGIN_FAILED || userInfo->logState == ENROLL_FAILED || userInfo->logState == ENROLL_DECLINED || userInfo->logState == LOGIN_DECLINED){
        height = 80.0;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserLoginInfo* userInfo = (UserLoginInfo*)[logsArray objectAtIndex:indexPath.row];
    NSString *CellIdentifier= @"LogsTableCellID";//LogsFailedTableCellID
    if (userInfo->logState == LOGIN_FAILED || userInfo->logState == ENROLL_FAILED || userInfo->logState == ENROLL_DECLINED || userInfo->logState == LOGIN_DECLINED || userInfo->logState == UNKNOWN_ERROR){
        CellIdentifier= @"LogsFailedTableCellID";
    }
    LogsTableCell *cell = (LogsTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.cellBackground.layer.cornerRadius = CORNER_RADIUS;
    [cell setData:userInfo];
    [cell.infoButton setTag:indexPath.row];
    
    return cell;
}

-(IBAction)showUserInfo:(id)sender{
    if ([[sender accessibilityLabel] isEqualToString:@"1"]){
        //Show message about failed enroll/authentication
        UserLoginInfo* userInfo = [logsArray objectAtIndex:[sender tag]];
        NSString* message = userInfo->errorMessage;
        if (message != nil){
            NSDictionary* jsonError = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:kNilOptions
                                                                        error:nil];
            if (jsonError != nil){
                message = [jsonError valueForKey:@"errorDescription"];
            }
        } else {
            switch (userInfo->logState) {
                case LOGIN_DECLINED:
                    message = @"Login declined!";
                    break;
                    
                case ENROLL_DECLINED:
                    message = @"ENROL declined!";
                    
                default:
                    break;
            }
        }
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:message closeButtonTitle:@"Close" duration:0.0f];
    } else {
        [self loadApproveDenyView:sender];
    }
}

-(void)loadApproveDenyView:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ApproveDenyViewController* approveDenyView = [storyboard instantiateViewControllerWithIdentifier:@"ApproveDenyView"];
//    approveDenyView.delegate = self;
    [approveDenyView setIsLogInfo:YES];
    UserLoginInfo* userInfo = [logsArray objectAtIndex:[sender tag]];
    [approveDenyView setUserInfo:userInfo];
    [self.navigationController pushViewController:approveDenyView animated:YES];
//    [self presentViewController:approveDenyView animated:YES completion:nil];
}

-(void)initAnimationFromRigthToLeft{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [contentView.layer addAnimation:transition forKey:nil];
}

@end
