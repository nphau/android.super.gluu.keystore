//
//  SettingsTableViewController.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/20/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingsTableCell.h"

@implementation SettingsTableViewController{

    NSArray *settingsTopics;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    settingsTopics = [[NSArray alloc] initWithObjects:@"Pin code", @"TouchID (fingerprint)", @"Trust all", @"U2F ble device(s)", nil];
    _settingsTable.tableFooterView = [UIView new];
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
            subTitle = [self checkSettingsFor:SSL_ENABLED];
            break;
        case 3:
            subTitle = [self checkSettingsFor:SECURE_CLICK_ENABLED];
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

@end
