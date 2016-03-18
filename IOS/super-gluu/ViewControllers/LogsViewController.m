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
    if ([logsArray count] > 2){
        [logsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:logsArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if ([logsArray count] > 0){
        [cleanLogs setHidden:NO];
        [cleanLogs setEnabled:YES];
    }
}

#pragma mark CustomIOS7AlertView Delegate

-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
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
    [alertView show];
}

#pragma mark UITableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return logsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier= @"LogsTableCellID";
    LogsTableCell *cell = (LogsTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.cellBackground.layer.cornerRadius = CORNER_RADIUS;
    [cell setData:[logsArray objectAtIndex:indexPath.row]];
    [cell.infoButton setTag:indexPath.row];
    
    return cell;
}

-(IBAction)showUserInfo:(id)sender{
    [self performSegueWithIdentifier:@"LogInfo" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"LogInfo"]) {
        //     MyViewController *myVC = [segue destinationViewController];
        UINavigationController* dest = [segue destinationViewController];
        ApproveDenyViewController* approveDenyView = (id)[dest topViewController];
        if (approveDenyView != nil){
            approveDenyView.delegate = self;
            [approveDenyView setIsLogInfo:YES];
            UserLoginInfo* userInfo = [logsArray objectAtIndex:[sender tag]];
            [approveDenyView setUserInfo:userInfo];
        }
    }
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
