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
#import "LicenseAgreementView.h"

@implementation SettingsTableViewController{

    NSArray *settingsTopics;
    NSArray *settingsKeys;
    int selectedSettingIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    settingsTopics = [[NSArray alloc] initWithObjects:@"Pin code", @"TouchID (fingerprint)", @"Trust all (SSL)", @"", @"User guide", @"Privacy policy", @"Upgrate to Ad-Free", @"", @"Version", @"", nil];//@"U2F BLE device(s)",
    settingsKeys = [[NSArray alloc] initWithObjects:PIN_PROTECTION_ID, TOUCH_ID_ENABLED, SSL_ENABLED, nil];// SECURE_CLICK_ENABLED,
    if ([[ADSubsriber sharedInstance] isSubscribed]){
        settingsTopics = [[NSArray alloc] initWithObjects:@"Pin code", @"TouchID (fingerprint)", @"Trust all (SSL)", @"", @"User guide", @"Privacy policy", @"", @"Version", @"", nil];
    }
    _settingsTable.tableFooterView = [UIView new];
    [_settingsTable setSeparatorColor:[[AppConfiguration sharedInstance] systemColor]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_settingsTable reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adViewHide:) name:NOTIFICATION_AD_FREE object:nil];
}

-(void)adViewHide:(NSNotification*)notification{
    settingsTopics = [[NSArray alloc] initWithObjects:@"Pin code", @"TouchID (fingerprint)", @"Trust all (SSL)", @"", @"User guide", @"Privacy policy", @"", @"Version", @"", nil];
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
//        case 2:
//            subTitle = [self checkSettingsFor:SECURE_CLICK_ENABLED];
//            break;
        case 2:
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

-(void) openLicenseView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LicenseAgreementView* info = [storyboard instantiateViewControllerWithIdentifier:@"LicenseAgreementView"];
    info.isFromSettings = YES;
    [self.navigationController pushViewController:info animated:YES];
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

    cell.backgroundColor = [cell.titleLabel.text isEqualToString:@""] ? [UIColor groupTableViewBackgroundColor] : [UIColor whiteColor];
    if ([[ADSubsriber sharedInstance] isSubscribed]){
        [cell.backArrowImage setHidden:!(indexPath.row <= 2 || (indexPath.row >= 3 && indexPath.row <= 5))];
    } else {
        [cell.backArrowImage setHidden:!(indexPath.row <= 2 || (indexPath.row >= 4 && indexPath.row <= 6))];
    }
    [cell.versionLabel setHidden:!(indexPath.row == settingsTopics.count-2)];
    
    //Extract app and build versions
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // example: 1.0.0
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"];
    
    [cell.versionLabel setText:[NSString stringWithFormat:@"%@ - %@", appVersion, buildNumber]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row <= 2){
        selectedSettingIndex = (int)indexPath.row;
        [self performSegueWithIdentifier:@"settingsDetailsSegue" sender:self];
    }
    if (indexPath.row == 4){
        //Open user guide url
        if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:USER_GUIDE_URL]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:USER_GUIDE_URL]];
    }
    if (indexPath.row == 5){
        //Open Privacy policy
        [self openLicenseView];
    }
    if (indexPath.row == 6 && ![[ADSubsriber sharedInstance] isSubscribed]){
        //Open Ad-Free functionality
        [[ADSubsriber sharedInstance] tryToSubsribe];
    }
}

@end
