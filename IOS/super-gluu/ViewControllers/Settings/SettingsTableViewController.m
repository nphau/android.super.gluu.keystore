//
//  SettingsTableViewController.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/20/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingsTableCell.h"
#import "SettingsDetailsViewController.h"
#import "BLEDevicesViewController.h"
#import "ADSubsriber.h"

@implementation SettingsTableViewController{

    NSArray *settingsTopics;
    NSArray *settingsKeys;
    int selectedSettingIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    settingsTopics = [[NSArray alloc] initWithObjects:@"Pin code", @"TouchID (fingerprint)", @"U2F BLE device(s)", @"Trust all (SSL)", nil];//@"U2F BLE device(s)",
    settingsKeys = [[NSArray alloc] initWithObjects:PIN_PROTECTION_ID, TOUCH_ID_ENABLED, SECURE_CLICK_ENABLED, SSL_ENABLED, nil];// SECURE_CLICK_ENABLED,
//    if (![[ADSubsriber sharedInstance] isSubscribed]){
//        settingsTopics = [[NSArray alloc] initWithObjects:@"Pin code", @"TouchID (fingerprint)", @"U2F BLE device(s)", @"Trust all (SSL)", nil];//, @"AD Free", @"U2F BLE device(s)",
//        settingsKeys = [[NSArray alloc] initWithObjects:PIN_PROTECTION_ID, TOUCH_ID_ENABLED, SECURE_CLICK_ENABLED, SSL_ENABLED, NOTIFICATION_AD_FREE, nil];// SECURE_CLICK_ENABLED,
//    }
    _settingsTable.tableFooterView = [UIView new];
    [_settingsTable setSeparatorColor:[[AppConfiguration sharedInstance] systemColor]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_settingsTable reloadData];
}

-(NSString*)getSubTitleForSettings:(int)settings_index{
    NSString* subTitle = @"";
    switch (settings_index) {
        case 0:
            subTitle = [self checkSettingsFor:PIN_PROTECTION_ID];
            break;
        case 1:
            subTitle = [self checkSettingsFor:TOUCH_ID_ENABLED];
            break;
        case 2:
            subTitle = [self checkSettingsFor:SECURE_CLICK_ENABLED];
            break;
        case 3:
            subTitle = [self checkSettingsFor:SSL_ENABLED];
            break;
            
        default:
            break;
    }
    return subTitle;
}

-(NSString*)checkSettingsFor:(NSString*)settingKey{
    BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:settingKey];
    NSString* result = isOn ? @"On" : @"Off";
    return [NSString stringWithFormat:@"Status: %@", result];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"settingsDetailsSegue"]){
        SettingsDetailsViewController* settingsDetails = (SettingsDetailsViewController*)[segue destinationViewController];
        settingsDetails.settingTitle = settingsTopics[selectedSettingIndex];
        settingsDetails.settingKey = settingsKeys[selectedSettingIndex];
    }
}


#pragma mark UITableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return settingsTopics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier= @"settingsTableCell";
    SettingsTableCell *cell = (SettingsTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.titleLabel.text = [settingsTopics objectAtIndex:indexPath.row];
    cell.subTitleLabel.text = [self getSubTitleForSettings:(int)indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedSettingIndex = (int)indexPath.row;
    if (selectedSettingIndex == 2){
        [self performSegueWithIdentifier:@"settingsBLESegue" sender:self];
    } else if (selectedSettingIndex == settingsKeys.count-1 && [[NSUserDefaults standardUserDefaults] boolForKey:NOTIFICATION_AD_FREE]){
    
    } else {
        [self performSegueWithIdentifier:@"settingsDetailsSegue" sender:self];

    }
}

@end
