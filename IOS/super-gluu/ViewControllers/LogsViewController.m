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

@implementation LogsViewController{
//    ApproveDenyViewController* approveDenyView;
}

-(void)viewDidLoad{

    [super viewDidLoad];
    [self getLogs];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getLogs];
    [logsTableView reloadData];
}

-(void)getLogs{
    logsArray = [[NSMutableArray alloc] init];
    logsArray = [[NSMutableArray alloc] initWithArray:[[DataStoreManager sharedInstance] getUserLoginInfo]];
    [logsArray count] == 0 ? [logsTableView setHidden:YES] : [logsTableView setHidden:NO];
    [logsArray count] == 0 ? [cleanLogs setHidden:YES] : [cleanLogs setHidden:NO];
    if ([logsArray count] > 3){
        [logsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:logsArray.count-2 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if ([logsArray count] > 0){
        [cleanLogs setHidden:NO];
        [cleanLogs setEnabled:YES];
    }
}

#pragma mark CustomIOS7AlertView Delegate

-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView tag] == 1 && buttonIndex == 0){
        [[DataStoreManager sharedInstance] deleteAllLogs];
        [self getLogs];
    }
    [alertView close];
}

-(IBAction)cleanLogs:(id)sender{
    CustomIOSAlertView *alertView = [CustomIOSAlertView alertWithTitle:NSLocalizedString(@"AlertTitle", @"Into") message:NSLocalizedString(@"ClearLogs", @"Clear Logs")];
    [alertView setButtonTitles:[NSArray arrayWithObjects:NSLocalizedString(@"YES", @"YES"), NSLocalizedString(@"NO", @"NO"), nil]];
    [alertView setButtonColors:[NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], nil]];
    alertView.delegate = self;
    alertView.tag = 1;
    [alertView show];
}

#pragma mark UITableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return logsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserLoginInfo* userInfo = (UserLoginInfo*)[logsArray objectAtIndex:indexPath.row];
    CGFloat height = 131.0;
    if ([userInfo logState] == LOGIN_FAILED || [userInfo logState] == ENROLL_FAILED){
        height = 75.0;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserLoginInfo* userInfo = (UserLoginInfo*)[logsArray objectAtIndex:indexPath.row];
    NSString *CellIdentifier= @"LogsTableCellID";//LogsFailedTableCellID
    if ([userInfo logState] == LOGIN_FAILED || [userInfo logState] == ENROLL_FAILED){
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
        NSString* message = [userInfo errorMessage];
        NSDictionary* jsonError = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options:kNilOptions
                                                                    error:nil];
        if (jsonError != nil){
            message = [jsonError valueForKey:@"errorDescription"];
        }
        CustomIOSAlertView *alertView = [CustomIOSAlertView alertWithTitle:@"Error message" message:message];
        alertView.delegate = self;
        [alertView show];
    } else {
        [self loadApproveDenyView:sender];
//        [self performSegueWithIdentifier:@"LogInfo" sender:sender];
    }
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if ([[segue identifier] isEqualToString:@"LogInfo"]) {
//        //     MyViewController *myVC = [segue destinationViewController];
//        UINavigationController* dest = [segue destinationViewController];
//        ApproveDenyViewController* approveDenyView = (id)[dest topViewController];
//        if (approveDenyView != nil){
//            approveDenyView.delegate = self;
//            [approveDenyView setIsLogInfo:YES];
//            UserLoginInfo* userInfo = [logsArray objectAtIndex:[sender tag]];
//            [approveDenyView setUserInfo:userInfo];
//        }
//    }
//}

-(void)loadApproveDenyView:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ApproveDenyViewController* approveDenyView = [storyboard instantiateViewControllerWithIdentifier:@"ApproveDenyView"];
    //    [tabBar setModalPresentationStyle:UIModalPresentationFullScreen];
    approveDenyView.delegate = self;
    [approveDenyView setIsLogInfo:YES];
    UserLoginInfo* userInfo = [logsArray objectAtIndex:[sender tag]];
    [approveDenyView setUserInfo:userInfo];
    [self presentViewController:approveDenyView animated:YES completion:nil];
}

#pragma LicenseAgreementDelegates

-(void)approveRequest{
//    [approveDenyView.view removeFromSuperview];
//    approveDenyView = nil;
}

-(void)denyRequest{
//    [approveDenyView.view removeFromSuperview];
//    [self initAnimationFromRigthToLeft];
//    approveDenyView = nil;
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
