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
#import "ADSubsriber.h"

@implementation LogsViewController

-(void)viewDidLoad{

    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPushView) name:NOTIFICATION_PUSH_ONLINE object:nil];
    topView.backgroundColor = [[AppConfiguration sharedInstance] systemColor];
    topIconView.image = [[AppConfiguration sharedInstance] systemIcon];
    [cancelButton setHidden: YES];
    [editLogsButton setTag:1];
    if ([[ADSubsriber sharedInstance] isSubscribed]){
        [selectAllView setCenter:CGPointMake(selectAllView.center.x, selectAllView.center.y+50)];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self updateLogs];
    logsTableView.tableFooterView = [[UIView alloc] init];
    logsTableView.allowsMultipleSelectionDuringEditing = YES;
}

-(void)initPushView{
    [self.tabBarController setSelectedIndex:0];
}

-(void)getLogs{
    logsArray = [[NSMutableArray alloc] init];
    logsArray = [[NSMutableArray alloc] initWithArray:[[DataStoreManager sharedInstance] getUserLoginInfo]];
    [logsArray count] == 0 ? [logsTableView setHidden:YES] : [logsTableView setHidden:NO];
    [editLogsButton setHidden: [logsArray count] == 0];
}

-(void)deleteLog:(UserLoginInfo*)log {
    [[DataStoreManager sharedInstance] deleteLog:log];
    [self updateLogs];
}

-(void)deleteLogs:(NSArray*)logs {
    [[DataStoreManager sharedInstance] deleteLogs:logs];
    [self updateLogs];
    [selectAllView setHidden:YES];
}

-(void)updateLogs{
    [self getLogs];
    [logsTableView setEditing:NO animated:YES];
    [logsTableView reloadData];
}

-(IBAction)editCleanLogs:(id)sender{
    if (editLogsButton.tag == 1){
        //Editing table
        [logsTableView setEditing:YES animated:YES];
        [cancelButton setHidden:FALSE];
        [editLogsButton setTag: 2];
        [editLogsButton setTitle:@"Delete" forState:UIControlStateNormal];
        [selectAllView setHidden:NO];
    } else {
        //Deleting logs
        NSMutableArray* logsForDeleteArray = [self getLogsForDelete];
        if (logsForDeleteArray.count == 0){
            [self showNoLogsToDeleteAlert];
        } else {
            [self deleteLogsAlert:nil array:logsForDeleteArray];
        }
        [editLogsButton setTag: 1];
    }
}

-(IBAction)cancelEditLogs:(id)sender{
    [cancelButton setHidden:YES];
    [logsTableView setEditing:NO animated:YES];
    [editLogsButton setTag: 1];
    [self updateButtons];
    [selectAllView setHidden:YES];
    [self deselectAllLogs];
}

-(IBAction)selectAllClick:(id)sender{
    int tag = (int)((UIButton*)sender).tag;
    if (tag == 1){//select all
        [self selectAllLogs:YES];
        [selectAllButton setTag:2];
        [selectAllButton setTitle:@"Deselect All" forState:UIControlStateNormal];
    } else {//deselect all
        [self deselectAllLogs];
    }
}

-(void)deselectAllLogs{
    [self selectAllLogs:NO];
    [selectAllButton setTag:1];
    [selectAllButton setTitle:@"Select All" forState:UIControlStateNormal];
}

-(void)selectAllLogs:(Boolean)isSelect{
    for (int i = 0; i < [logsTableView numberOfSections]; i++) {
        for (int j = 0; j < [logsTableView numberOfRowsInSection:i]; j++) {
            NSUInteger ints[2] = {i,j};
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
            if (isSelect){
                [logsTableView selectRowAtIndexPath:indexPath
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
            } else {
                [logsTableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            //Here is your code
            
        }
    }
}

-(void)updateButtons{
    NSString* title = editLogsButton.tag == 2 ? @"Delete" : @"Edit";
    [editLogsButton setTitle:title forState:UIControlStateNormal];
}

-(void)deleteLogsAlert:(UserLoginInfo*)log array:(NSArray*)logs{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:NSLocalizedString(@"YES", @"YES") actionBlock:^(void) {
        NSLog(@"YES clicked");
        if (log != nil){
            [self deleteLog:log];
        } else if (logs != nil || logs.count > 0){
            [self deleteLogs:logs];
        } else {
            [self showNoLogsToDeleteAlert];
        }
    }];
    SCLButton * noButton = [alert addButton:NSLocalizedString(@"NO", @"NO") actionBlock:^(void) {
        NSLog(@"NO clicked");
    }];
    [noButton setDefaultBackgroundColor:[UIColor redColor]];
    NSString* subText = logs != nil || logs.count > 0 ? NSLocalizedString(@"ClearLogs", @"Clear Logs") : NSLocalizedString(@"ClearLog", @"Clear Log");
    [alert showCustom:[UIImage imageNamed:@"delete_action_titleIcon"] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"AlertTitle", @"Into") subTitle: subText closeButtonTitle:nil duration:0.0f];
}

-(void)showNoLogsToDeleteAlert{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:NSLocalizedString(@"OK", @"OK") actionBlock:^(void) {
        NSLog(@"NO clicked");
    }];
    [alert showCustom:[UIImage imageNamed:@"delete_action_titleIcon"] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"AlertTitle", @"Into") subTitle:@"No selected log(s)" closeButtonTitle:nil duration:0.0f];
}

#pragma mark UITableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return logsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserLoginInfo* userInfo = (UserLoginInfo*)[logsArray objectAtIndex:indexPath.row];
    NSString *CellIdentifier= @"LogsTableCellID";//LogsFailedTableCellID
    if (userInfo->logState == LOGIN_FAILED || userInfo->logState == ENROLL_FAILED || userInfo->logState == ENROLL_DECLINED || userInfo->logState == LOGIN_DECLINED || userInfo->logState == UNKNOWN_ERROR){
        CellIdentifier= @"LogsFailedTableCellID";
    }
    LogsTableCell *cell = (LogsTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setData:userInfo];
    [cell setTag:indexPath.row];
    
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![logsTableView isEditing]){
        [self loadApproveDenyView:(int)indexPath.row];
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0] normalIcon:[UIImage imageNamed:@"view_action"] selectedIcon:nil];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] normalIcon:[UIImage imageNamed:@"delete_action"] selectedIcon:nil];
    
    return rightUtilityButtons;
}


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"check button was pressed");
            break;
        case 1:
            NSLog(@"clock button was pressed");
            break;
        case 2:
            NSLog(@"cross button was pressed");
            break;
        case 3:
            NSLog(@"list button was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"More button was pressed");
            [self loadApproveDenyView:(int)cell.tag];
            break;
        case 1:
        {
            // Delete button was pressed
            NSLog(@"Delete button was pressed");
            UserLoginInfo* log = [logsArray objectAtIndex:cell.tag];
            [self deleteLogsAlert:log array:nil];
            break;
        }
        default:
            break;
    }
}

//------------------ END --------------------------------

-(void)loadApproveDenyView:(int)index{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ApproveDenyViewController* approveDenyView = [storyboard instantiateViewControllerWithIdentifier:@"ApproveDenyView"];
    [approveDenyView setIsLogInfo:YES];
    UserLoginInfo* userInfo = [logsArray objectAtIndex:index];
    [approveDenyView setUserInfo:userInfo];
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController pushViewController:approveDenyView animated:YES];
}

-(NSMutableArray*) getLogsForDelete{
    NSArray* selectedCells = [logsTableView indexPathsForSelectedRows];
    NSMutableArray* updatedLogsArray = [[NSMutableArray alloc] init];
    for (NSIndexPath* indexParh in selectedCells) {
        UserLoginInfo* log = [logsArray objectAtIndex:indexParh.row];
        [updatedLogsArray addObject:log];
    }
    
    return updatedLogsArray;
}


@end
