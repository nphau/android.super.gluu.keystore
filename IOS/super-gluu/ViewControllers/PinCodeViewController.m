//
//  PinCodeViewController.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/16/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "PinCodeViewController.h"
#import "Constants.h"

#define MAIN_VIEW @"MainTabView"
#define PIN_PROTECTION_ID @"enabledPinCode"
#define PIN_ENABLED @"PinCodeEnabled"
#define PIN_CODE @"PinCode"

@implementation PinCodeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self initWiget];
    BOOL isPinCode = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_ENABLED];
    if (isPinCode){
        [titleLabel setHidden:YES];
        [nextButton setHidden:YES];
        [skipButton setHidden:YES];
    }
    [self performSelector:@selector(checkPinCodeEnabled) withObject:nil afterDelay:0.01];
}

-(void)initWiget{
    [[nextButton layer] setMasksToBounds:YES];
    [[nextButton layer] setCornerRadius:CORNER_RADIUS];
    [[nextButton layer] setBorderWidth:2.0f];
    [[nextButton layer] setBorderColor:CUSTOM_GREEN_COLOR.CGColor];
    
    [[skipButton layer] setMasksToBounds:YES];
    [[skipButton layer] setCornerRadius:CORNER_RADIUS];
}

-(void)checkPinCodeEnabled{
    BOOL isPinCode = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_ENABLED];
    if (isPinCode){
        [self enterPasscode];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
}

-(IBAction)next:(id)sender{
    [self setPasscode];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PIN_PROTECTION_ID];
}

-(IBAction)skip:(id)sender{
    [self performSegueWithIdentifier:MAIN_VIEW sender:self];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PIN_PROTECTION_ID];
}

- (void)setPasscode {
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    passcodeViewController.delegate = self;
    passcodeViewController.simple = YES;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:passcodeViewController] animated:YES completion:nil];
}

- (void)enterPasscode {
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    passcodeViewController.delegate = self;
    NSString* code = [[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE];
    passcodeViewController.passcode = code;//_passcodeLabel.text;
    passcodeViewController.alternativePasscode = @"9999";
    passcodeViewController.simple = YES;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:passcodeViewController] animated:YES completion:nil];
}

#pragma mark - PAPasscodeViewControllerDelegate

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)PAPasscodeViewControllerDidEnterAlternativePasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
//        [[[UIAlertView alloc] initWithTitle:nil message:@"Alternative Passcode entered correctly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        [self performSegueWithIdentifier:MAIN_VIEW sender:self];
//        [[[UIAlertView alloc] initWithTitle:nil message:@"Passcode entered correctly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PIN_ENABLED];
        [[NSUserDefaults standardUserDefaults] setObject:controller.passcode forKey:PIN_CODE];
        [titleLabel setHidden:YES];
        [nextButton setHidden:YES];
        [skipButton setHidden:YES];
        [self performSegueWithIdentifier:MAIN_VIEW sender:self];
//        _passcodeLabel.text = controller.passcode;
    }];
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
//        _passcodeLabel.text = controller.passcode;
    }];
}

@end
