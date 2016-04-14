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

@implementation KeysViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadKeyHandlesFromDatabase];
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [longPressRecognizer setMinimumPressDuration:3.0];
    [keyHandleTableView addGestureRecognizer:longPressRecognizer];
    
    keyHandleTableView.layer.borderColor = [UIColor blackColor].CGColor;
    keyHandleTableView.layer.borderWidth = 2.0;
    [keyHandleTableView.layer setMasksToBounds:YES];
    keyCells = [[NSMutableDictionary alloc] init];
    keyRenameInfoLabel.text = NSLocalizedString(@"RenameKeyNameInfo", @"Rename Key's Name");
    uniqueKeyLabel.text = NSLocalizedString(@"UniqueKeyLabel", @"UniqueKeyLabel");
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPushView) name:NOTIFICATION_PUSH_ONLINE object:nil];
}

-(void)initPushView{
    [self.tabBarController setSelectedIndex:0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadKeyHandlesFromDatabase];
    [keyHandleTableView reloadData];
    [self checkDeviceOrientation];
}

-(void)checkDeviceOrientation{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
                [self adjustViewsForOrientation:UIInterfaceOrientationLandscapeLeft];
//        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

-(void)onLongPress:(UILongPressGestureRecognizer*)pGesture
{
    if (pGesture.state == UIGestureRecognizerStateBegan)
    {
        //Do something to tell the user!
        CGPoint touchPoint = [pGesture locationInView:keyHandleTableView];
        NSIndexPath* row = [keyHandleTableView indexPathForRowAtPoint:touchPoint];
        selectedRow = row;
        if (row != nil) {
            //Handle the long press on row
            NSLog(@"Cell title will be changed");
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:NSLocalizedString(@"YES", @"YES") actionBlock:^(void) {
                NSLog(@"YES clicked");
                [self showEditNameAlert];
            }];
            [alert addButton:NSLocalizedString(@"NO", @"NO") actionBlock:^(void) {
                NSLog(@"NO clicked");
            }];
            [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:NSLocalizedString(@"AlertTitle", @"Into") subTitle:NSLocalizedString(@"ChangeKeyHandleName", @"Change KeyHandle Name") closeButtonTitle:nil duration:0.0f];
        }
    }
}

-(void)showEditNameAlert{
    KeyHandleCell *cell = (KeyHandleCell*)[keyHandleTableView cellForRowAtIndexPath:selectedRow];
    UILabel* keyTextLabel = [cell keyHandleNameLabel];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UITextField *textField = [alert addTextField:@"Enter key's name" andText:keyTextLabel.text];
    
    [alert addButton:@"Save" actionBlock:^(void) {
        NSLog(@"Text value: %@", textField.text);
        if ([self checkUniqueName:keyTextLabel.text andID:cell.accessibilityLabel]){
            [[DataStoreManager sharedInstance] setTokenEntitiesNameByID:cell.accessibilityLabel newName:textField.text];
            [self loadKeyHandlesFromDatabase];
        } else {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"Close" actionBlock:^(void) {
                NSLog(@"Close clicked");
                [textField becomeFirstResponder];
            }];
            [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:NSLocalizedString(@"Info", @"Info") subTitle:@"Name is exist, please enter another one" closeButtonTitle:nil duration:0.0f];
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
    [self initLabel:(int)[keyHandleArray count]];
}

-(void)initLabel:(int)keyCount{
    if (keyCount > 0){
        [keyHandleLabel setText:[NSString stringWithFormat:@"%@ (%i):", NSLocalizedString(@"AvailableKeyHandles", @"Available KeyHandles"), keyCount]];
        [keyRenameInfoLabel setHidden:NO];
    } else {
        [keyHandleLabel setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"AvailableKeyHandles", @"Available KeyHandles")]];
        [keyRenameInfoLabel setHidden:YES];
    }
}

-(BOOL)checkUniqueName:(NSString*)name andID:(NSString*)keyID{
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
    TokenEntity* tokenEntity = [keyHandleArray objectAtIndex:indexPath.row];
    [cell setData:tokenEntity];
    
    [keyCells setObject:[tokenEntity keyName] forKey:[tokenEntity application]];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TokenEntity* tokenEntity = [keyHandleArray objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InformationViewController* info = [storyboard instantiateViewControllerWithIdentifier:@"InformationViewControllerID"];
    [info setModalPresentationStyle:UIModalPresentationFullScreen];
    [info setToken:tokenEntity];
    [self presentViewController:info animated:YES completion:nil];
//    KeyHandleCell *cell = (KeyHandleCell*)[tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    rowToDelete = (int)indexPath.row;
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:NSLocalizedString(@"YES", @"YES") actionBlock:^(void) {
        NSLog(@"YES clicked");
        [self deleteRow];
    }];
    [alert addButton:NSLocalizedString(@"NO", @"NO") actionBlock:^(void) {
        NSLog(@"NO clicked");
    }];
    [alert showCustom:[UIImage imageNamed:@"gluuIconAlert.png"] color:CUSTOM_GREEN_COLOR title:NSLocalizedString(@"Delete", @"Delete") subTitle:NSLocalizedString(@"DeleteKeyHandle", @"Delete KeyHandle") closeButtonTitle:nil duration:0.0f];
}

-(void)deleteRow{
    TokenEntity* tokenEntity = [keyHandleArray objectAtIndex:rowToDelete];
    [[DataStoreManager sharedInstance] deleteTokenEntitiesByID:[tokenEntity application]];
    [self loadKeyHandlesFromDatabase];
}

- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {

    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            //load the portrait view
            if (isLandScape){
                [keyRenameInfoLabel setCenter:CGPointMake(keyRenameInfoLabel.center.x, [UIScreen mainScreen].bounds.size.height - 135)];
                isLandScape = NO;
            }
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            //load the landscape view
            if (!isLandScape){
                [keyRenameInfoLabel setCenter:CGPointMake(keyRenameInfoLabel.center.x, [UIScreen mainScreen].bounds.size.height - 125)];
                isLandScape = YES;
            } else {
                [keyRenameInfoLabel setCenter:CGPointMake(keyRenameInfoLabel.center.x, [UIScreen mainScreen].bounds.size.height - 125)];
            }
            
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
}


@end
