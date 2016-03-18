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

@implementation KeysViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadKeyHandlesFromDatabase];
    [self initIfoView];
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [longPressRecognizer setMinimumPressDuration:3.0];
    [keyHandleTableView addGestureRecognizer:longPressRecognizer];
    
    keyHandleTableView.layer.borderColor = [UIColor blackColor].CGColor;
    keyHandleTableView.layer.borderWidth = 2.0;
    [keyHandleTableView.layer setMasksToBounds:YES];
    
    keyRenameInfoLabel.text = NSLocalizedString(@"RenameKeyNameInfo", @"Rename Key's Name");
    uniqueKeyLabel.text = NSLocalizedString(@"UniqueKeyLabel", @"UniqueKeyLabel");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadKeyHandlesFromDatabase];
    [keyHandleTableView reloadData];
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
            CustomIOSAlertView* alertView = [CustomIOSAlertView alertWithTitle:NSLocalizedString(@"AlertTitle", @"Into") message:NSLocalizedString(@"ChangeKeyHandleName", @"Change KeyHandle Name")];
            [alertView setButtonTitles:[NSArray arrayWithObjects: NSLocalizedString(@"YES", @"YES"), NSLocalizedString(@"NO", @"NO"), nil]];
            [alertView setButtonColors:[NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], nil]];
            alertView.delegate = self;
            [alertView show];
        }
    }
}

-(void)initIfoView{
    infoView = [CustomIOSAlertView alertWithTitle:NSLocalizedString(@"AlertTitle", @"Into") message:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
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

-(IBAction)onInfoClick:(id)sender{
    [infoView show];
}

#pragma mark UITextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    KeyHandleCell *cell = (KeyHandleCell*)[keyHandleTableView cellForRowAtIndexPath:selectedRow];
    UITextField* keyTextField = [cell keyHandleTextField];
    [keyTextField setEnabled:NO];
    [[NSUserDefaults standardUserDefaults] setObject:keyTextField.text forKey:@"keyHandleDisplayName"];
    
    return YES;
}

#pragma mark CustomIOS7AlertView Delegate

-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        if (((CustomIOSAlertView*)alertView).tag == 2){
            [self deleteRow];
        } else {
            NSLog(@"User wants to change keyHandleName");
            KeyHandleCell *cell = (KeyHandleCell*)[keyHandleTableView cellForRowAtIndexPath:selectedRow];
            UITextField* keyTextField = [cell keyHandleTextField];
            [keyTextField setEnabled:YES];
            [keyTextField becomeFirstResponder];
            [keyTextField setReturnKeyType:UIReturnKeyDone];
            keyTextField.delegate = self;
        }
    }
    [alertView close];
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

//    [[CustomIOS7AlertView alertWithTitle:cell.keyHandleTextField.text message:cell.key] show];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    rowToDelete = (int)indexPath.row;
    CustomIOSAlertView* alertView = [CustomIOSAlertView alertWithTitle:NSLocalizedString(@"Delete", @"Delete") message:NSLocalizedString(@"DeleteKeyHandle", @"Delete KeyHandle")];
    [alertView setButtonTitles:[NSArray arrayWithObjects: NSLocalizedString(@"YES", @"YES"), NSLocalizedString(@"NO", @"NO"), nil]];
    [alertView setButtonColors:[NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], nil]];
    alertView.delegate = self;
    alertView.tag = 2;
    [alertView show];
}

-(void)deleteRow{
    TokenEntity* tokenEntity = [keyHandleArray objectAtIndex:rowToDelete];
    [[DataStoreManager sharedInstance] deleteTokenEntitiesByID:[tokenEntity application]];
    [keyHandleArray removeObjectAtIndex:0];
    [keyHandleTableView reloadData];
    [self initLabel:(int)[keyHandleArray count]];
}

@end
