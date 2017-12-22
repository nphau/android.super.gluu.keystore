//
//  PinCodeSettingsTableViewController.m
//  Super Gluu
//
//  Created by Eric Webb on 12/12/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "PinCodeSettingsTableViewController.h"
#import "SCLAlertView.h"
#import "PinCodeViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>


@interface PinCodeSettingsTableViewController () <PAPasscodeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *pinSwitch;

@property (strong, nonatomic) PAPasscodeViewController* passcodeViewController;

@property (nonatomic) int countFailedPin;


@end



@implementation PinCodeSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDisplay];

}

- (void)setupDisplay {
    
    self.view.backgroundColor = [Constant tableBackgroundColor];
    
    self.tableView.backgroundColor = [Constant tableBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    BOOL isPinEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_ENABLED];
    [self.pinSwitch setOn:isPinEnabled];
    
    // setup the second section
    [self updateUI];
    
}

- (IBAction)pinSwitchValueChanged:(id)sender {
    
    // User turned pincode entry off
    if (self.pinSwitch.isOn == false) {
        [self removeUserPin];
    } else {
        // User turned pincode entry on.
        // Reset the pincode
        [self displayPinCodeEntryScreen];
    }

}

- (void)updateUI {

    // hide/show second section based on value of PIN_ENABLED
    
    [self.tableView reloadData];

}

- (NSString *)userPin {
    return [GluuUserDefaults userPin];
}

- (void)updateUserPin:(NSString *)pin {

    [GluuUserDefaults setUserPinWithNewPin:pin];
    
    [self updateUI];
}

- (void)removeUserPin {
    [GluuUserDefaults removeUserPin];
    [self.pinSwitch setOn:NO animated:YES];
    
    [self updateUI];
}

#pragma mark - Table View DataSource / Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.pinSwitch.isOn == YES) {
        return 2;
    } else {
        return 1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        // go to set pin code screen
        [self displayPinCodeEntryScreen];
    }
    
}

/*
- (void)goToUpdatePinCode {
    
    NSString* title;
    NSString* message;
    
    BOOL isPinCode;
    self.code = [[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE];
    
    if (self.code == nil) {
        title = NSLocalizedString(@"SetPinCode", @"SetPinCode");
        message = NSLocalizedString(@"SetPinCodeTitle", @"SetPinCodeTitle");
        isPinCode = NO;
    } else {
        title = NSLocalizedString(@"ChangePinCode", @"ChangePinCode");
        message = NSLocalizedString(@"ChangePinCodeTitle", @"ChangePinCodeTitle");
        isPinCode = YES;
    }
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:NSLocalizedString(@"YES", @"YES") actionBlock:^(void) {
        NSLog(@"YES clicked");
 
        [self displayPinCodeEntryScreen];

    }];
    SCLButton * noButton = [alert addButton:NSLocalizedString(@"NO", @"NO") actionBlock:^(void) {
        NSLog(@"NO clicked");
    }];
    [noButton setDefaultBackgroundColor:[UIColor redColor]];
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:title subTitle:message closeButtonTitle:nil duration:0.0f];
}
 */

- (void)displayPinCodeEntryScreen {
    
    if ([self userPin] != nil) {
        self.passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionChange];
        self.passcodeViewController.passcode = [self userPin];
        self.passcodeViewController.title = @"Reset Passcode";
    } else {
        self.passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    
    self.passcodeViewController.delegate = self;
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:self.passcodeViewController] animated:YES completion:nil];
    
}

#pragma mark - PAPasscodeViewControllerDelegate

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller {
    
    // if the user didn't enter a pin, pincode shouldn't be turned on
    if ([self userPin] == nil) {
        [self removeUserPin];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller {
    
    [self dismissViewControllerAnimated:YES completion:^() {
        NSString* newPassword = controller.passcode;
        NSString* oldPassword = [[NSUserDefaults standardUserDefaults] objectForKey:PIN_CODE];
        if ([newPassword isEqualToString:oldPassword]){
        
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:@"You cannot set a new Pin code the same like old" closeButtonTitle:@"Close" duration:0.0f];
        
        } else {
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:@"You have successfully set a new Pin code" closeButtonTitle:@"Close" duration:0.0f];
            
            [self updateUserPin:controller.passcode];
        }
    }];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        
        [self updateUserPin:controller.passcode];
        
        // eric
//        [_setChangePinCode setTitle:NSLocalizedString(@"ChangePinCode", @"ChangePinCode") forState:UIControlStateNormal];
        
    }];
}

- (void)PAPasscodeViewController:(PAPasscodeViewController *)controller didFailToEnterPasscode:(NSInteger)attempts{
    self.countFailedPin++;
    NSLog(@"Failed enter passcode, count - %i", self.countFailedPin);
    int attemptsCount = (int)[[NSUserDefaults standardUserDefaults] integerForKey:LOCKED_ATTEMPTS_COUNT];
    if (self.countFailedPin == attemptsCount-2){
        
        [self showAlertView];
        
    }
    if (self.countFailedPin == attemptsCount){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_APP_LOCKED];
        NSURL *url = [NSURL URLWithString:@"http://www.timeapi.org/utc/now"];
        NSString *str = [[NSString alloc] initWithContentsOfURL:url usedEncoding:nil error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:LOCKED_DATE];//[NSDate date]//[NSDate networkDate]
        
        // eric
//        [self performSelector:@selector(showPinView) withObject:nil afterDelay:1];
    }
}

- (void)showAlertView {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:@"Close" actionBlock:^(void) {
        NSLog(@"Closed alert");
        [self.passcodeViewController showKeyboard];
    }];
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:NSLocalizedString(@"LastAttempts", @"LastAttempts") closeButtonTitle:nil duration:0.0f];
    [self.passcodeViewController hideKeyboard];
}


@end
