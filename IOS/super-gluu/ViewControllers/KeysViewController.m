//
//  SettingsViewController.m
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/9/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import "KeysViewController.h"
#import "KeyHandleCell.h"
#import "TokenEntity.h"
#import "DataStoreManager.h"
#import "InformationViewController.h"
#import "SCLAlertView.h"
#import "AppConfiguration.h"

@implementation KeysViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadKeyHandlesFromDatabase];
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [longPressRecognizer setMinimumPressDuration:3.0];
    [keyHandleTableView addGestureRecognizer:longPressRecognizer];
    
    keyHandleTableView.layer.borderColor = [UIColor grayColor].CGColor;
    keyHandleTableView.layer.borderWidth = 1.0;
    [keyHandleTableView.layer setMasksToBounds:YES];
    keyCells = [[NSMutableDictionary alloc] init];
    //uniqueKeyLabel.text = [NSString stringWithFormat: NSLocalizedString(@"UniqueKeyLabel", @"UniqueKeyLabel"), [[AppConfiguration sharedInstance] systemTitle]];
    topView.backgroundColor = [[AppConfiguration sharedInstance] systemColor];
    topIconView.image = [[AppConfiguration sharedInstance] systemIcon];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPushView) name:NOTIFICATION_PUSH_ONLINE object:nil];
}

-(void)initPushView{
    [self.tabBarController setSelectedIndex:0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadKeyHandlesFromDatabase];
    [keyHandleTableView reloadData];
}

-(void)showEditNameAlert{
    KeyHandleCell *cell = (KeyHandleCell*)[keyHandleArray objectAtIndex:rowToDelete];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UITextField *textField = [alert addTextField:@"Enter key's name"];
    
    [alert addButton:@"Save" actionBlock:^(void) {
        NSLog(@"Text value: %@", textField.text);
        if ([self checkUniqueName:textField.text andID:cell.accessibilityLabel]){
            [[DataStoreManager sharedInstance] setTokenEntitiesNameByID:cell.accessibilityLabel userName:cell.accessibilityValue newName:textField.text];
            [self loadKeyHandlesFromDatabase];
        } else {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:@"Name is exist or empty, please enter another one" closeButtonTitle:@"Close" duration:0.0f];
        }
    }];
    
    [alert showEdit:self title:@"New key's name" subTitle:@"Enter new key's name" closeButtonTitle:@"Close" duration:0.0f];
}

-(void)loadKeyHandlesFromDatabase{
    NSArray* keyHandles = [[DataStoreManager sharedInstance] getTokenEntities];
    keyHandleArray = [[NSMutableArray alloc] initWithArray:keyHandles];
    if ([keyHandleArray count] > 0){
        [keyHandleTableView reloadData];
        [keyHandleTableView setHidden:NO];
    } else {
        [keyHandleTableView setHidden:YES];
    }
    keyHandleTableView.tableFooterView = [[UIView alloc] init];
//    [self initLabel:(int)[keyHandleArray count]];
}

-(void)initLabel:(int)keyCount{
    if (keyCount > 0){
        [keyHandleLabel setText:[NSString stringWithFormat:@"%@ (%i):", NSLocalizedString(@"AvailableKeyHandles", @"Available KeyHandles"), keyCount]];
    } else {
        [keyHandleLabel setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"AvailableKeyHandles", @"Available KeyHandles")]];
    }
}

-(BOOL)checkUniqueName:(NSString*)name andID:(NSString*)keyID{
    if (name == nil) return NO;
    if (name.length == 0) return NO;
    for (NSString* cellKey in [keyCells allKeys]){
        if (![cellKey isEqualToString:keyID]){
            if ([[keyCells valueForKey:cellKey] isEqualToString:name]){
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark UITableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return keyHandleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier= @"KeyHandleCellID";
    KeyHandleCell *cell = (KeyHandleCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    TokenEntity* tokenEntity = (TokenEntity*)[keyHandleArray objectAtIndex:indexPath.row];
    [cell setData:tokenEntity];
    if ([tokenEntity isKindOfClass:[TokenEntity class]]){
//        NSString* keyName = tokenEntity->keyName == nil ? [NSString stringWithFormat:@"key for %@", tokenEntity->application] : tokenEntity->keyName;
        [keyCells setObject:tokenEntity->application forKey:tokenEntity->application];
    }
    [cell setTag:indexPath.row];
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showKeyInfo:indexPath.row];
}

-(void)showKeyInfo:(NSInteger)index{
    TokenEntity* tokenEntity = [keyHandleArray objectAtIndex:index];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InformationViewController* info = [storyboard instantiateViewControllerWithIdentifier:@"InformationViewControllerID"];
    [info setToken:tokenEntity];
    [self.navigationController pushViewController:info animated:YES];
}

-(void)showDeleteAlert{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:NSLocalizedString(@"YES", @"YES") actionBlock:^(void) {
        NSLog(@"YES clicked");
        [self deleteRow];
    }];
    SCLButton* noButton = [alert addButton:NSLocalizedString(@"NO", @"NO") actionBlock:^(void) {
        NSLog(@"NO clicked");
    }];
    [noButton setBackgroundColor:[UIColor redColor]];
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Delete", @"Delete") subTitle:NSLocalizedString(@"DeleteKeyHandle", @"Delete KeyHandle") closeButtonTitle:nil duration:0.0f];
}

-(void)deleteRow{
    TokenEntity* tokenEntity = [keyHandleArray objectAtIndex:rowToDelete];
    [[DataStoreManager sharedInstance] deleteTokenEntitiesByID:tokenEntity->application userName:tokenEntity->userName];
    [self loadKeyHandlesFromDatabase];
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0] normalIcon:[UIImage imageNamed:@"view_action"] selectedIcon:nil];
    UIColor* green = [UIColor colorWithRed:1/256.0 green:161/256.0 blue:97/256.0 alpha:1.0];
    [rightUtilityButtons sw_addUtilityButtonWithColor:green normalIcon:[UIImage imageNamed:@"rename_action"] selectedIcon:nil];
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
            [self showKeyInfo:cell.tag];
            break;
        case 1:
        {
            // Delete button was pressed
            NSLog(@"Rename button was pressed");
            rowToDelete = (int)cell.tag;
            [self showEditNameAlert];
            break;
        }
        case 2:
        {
            // Delete button was pressed
            NSLog(@"Delete button was pressed");
            rowToDelete = (int)cell.tag;
            [self showDeleteAlert];
            break;
        }
        default:
            break;
    }
}

@end
