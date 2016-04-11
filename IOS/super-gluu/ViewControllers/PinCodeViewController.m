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

#define FAILED_PIN_COUNT 5

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
    [enterPinButton setHidden:YES];
    countFailedPin = 0;
    [self checkIsAppLocked];
}

-(void)initWiget{
    [[nextButton layer] setMasksToBounds:YES];
    [[nextButton layer] setCornerRadius:CORNER_RADIUS];
    [[nextButton layer] setBorderWidth:2.0f];
    [[nextButton layer] setBorderColor:CUSTOM_GREEN_COLOR.CGColor];
    
    [[skipButton layer] setMasksToBounds:YES];
    [[skipButton layer] setCornerRadius:CORNER_RADIUS];
    
    [[enterPinButton layer] setMasksToBounds:YES];
    [[enterPinButton layer] setCornerRadius:CORNER_RADIUS];
    [[enterPinButton layer] setBorderWidth:2.0f];
    [[enterPinButton layer] setBorderColor:[UIColor colorWithRed:57/255.0 green:127/255.0 blue:255/255.0 alpha:1.0].CGColor];
}

-(void)checkPinCodeEnabled{
    if ([[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE]){
        [titleLabel setHidden:YES];
        [nextButton setHidden:YES];
        [skipButton setHidden:YES];
        [self enterPasscode];
    }
}

-(void)checkIsAppLocked{
    int count = (int)[[NSUserDefaults standardUserDefaults] integerForKey:LOCKED_ATTEMPTS_COUNT];
    countFailedPin = count;
    if (count > 0){
        [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"FailedPinCode", @"FailedPinCode"), countFailedPin]];
    }
    NSDate* date = [[NSUserDefaults standardUserDefaults] objectForKey:LOCKED_DATE];
    NSDate* currentDate = [NSDate date];
    NSTimeInterval distanceBetweenDates = [currentDate timeIntervalSinceDate:date];
    int sec = (int)distanceBetweenDates;
    int min = sec / 60;
    sec = sec % 60;
    if (min < 10 && sec > 0){
        [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"FailedPinCode", @"FailedPinCode"), countFailedPin]];
        sec = 600 - sec;
        minutes = 9 - min;
        minutes = minutes < 0 ? 0 : minutes;
        seconds = sec % 60;
        [nextButton setHidden:YES];
        [skipButton setHidden:YES];
        [timerView setHidden:NO];
        timerView.layer.cornerRadius = CORNER_RADIUS;
        [titleLabel setTextColor:[UIColor redColor]];
        [titleLabel setHidden:NO];
        [enterPinButton setHidden:YES];
        NSString* minStr = minutes < 10 ? [NSString stringWithFormat:@"%i%i", 0, minutes] : [NSString stringWithFormat:@"%i", minutes];
        minutesLabel.text = minStr;
        NSString* secStr = seconds < 10 ? [NSString stringWithFormat:@":%i%i", 0, seconds] : [NSString stringWithFormat:@":%i", seconds];
        secondsLabel.text = secStr;
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    } else {
        [self performSelector:@selector(checkPinCodeEnabled) withObject:nil afterDelay:0.01];
    }
}

-(IBAction)reEnterPinCode:(id)sender{
    [self enterPasscode];
}

-(IBAction)next:(id)sender{
    [self setPasscode];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PIN_PROTECTION_ID];
}

-(IBAction)skip:(id)sender{
    [self loadMainView];
    //[self performSegueWithIdentifier:MAIN_VIEW sender:self];
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
    if ([[NSUserDefaults standardUserDefaults] stringForKey:PIN_CODE]){
        [enterPinButton setHidden:NO];
        [enterPinButton setTitle:NSLocalizedString(@"EnterPinCode", @"EnterPinCode") forState:UIControlStateNormal];
        [titleLabel setText:NSLocalizedString(@"ReEnterPinCode", @"ReEnterPinCode")];
        [titleLabel setHidden:NO];
    }
}

- (void)PAPasscodeViewControllerDidEnterAlternativePasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
//        [[[UIAlertView alloc] initWithTitle:nil message:@"Alternative Passcode entered correctly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        [self loadMainView];
//        [self performSegueWithIdentifier:MAIN_VIEW sender:self];
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
        [self loadMainView];
//        [self performSegueWithIdentifier:MAIN_VIEW sender:self];
//        _passcodeLabel.text = controller.passcode;
    }];
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
//        _passcodeLabel.text = controller.passcode;
    }];
}

- (void)PAPasscodeViewController:(PAPasscodeViewController *)controller didFailToEnterPasscode:(NSInteger)attempts{
    countFailedPin++;
    NSLog(@"Failed enter passcode, count - %i", countFailedPin);
    int attemptsCount = (int)[[NSUserDefaults standardUserDefaults] integerForKey:LOCKED_ATTEMPTS_COUNT];
    if (attemptsCount <= 0){
        attemptsCount = FAILED_PIN_COUNT;
    }
    if (countFailedPin == attemptsCount-2){
        [self showAlertView];
    }
    if (countFailedPin == attemptsCount){
    //lock app and wait approx 10 mins
        [timerView setHidden:NO];
        [self startTimer];
        [controller dismissViewControllerAnimated:YES completion:nil];
        //remove push request in case app locked
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:NotificationRequest];
    }
    
}

// -----------------------------------------------------------------------------------------

-(void)loadMainView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController* tabBar = [storyboard instantiateViewControllerWithIdentifier:@"MainTabNavigationID"];
    //    [tabBar setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:tabBar animated:YES completion:nil];
}

-(void)startTimer{
    timerView.layer.cornerRadius = CORNER_RADIUS;
    [titleLabel setTextColor:[UIColor redColor]];
    [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"FailedPinCode", @"FailedPinCode"), countFailedPin]];
    [titleLabel setHidden:NO];
    [enterPinButton setHidden:YES];
    minutes = 10;
    seconds = 0;
    minutesLabel.text = [NSString stringWithFormat:@"%i", minutes];
    secondsLabel.text = [NSString stringWithFormat:@":%i%i", seconds, seconds];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LOCKED_DATE];
    
}

-(void)tick{
    if (seconds == 0){
        minutes--;
        seconds = 60;
        seconds--;
    } else {
        seconds--;
    }
    NSString* min = minutes < 10 ? [NSString stringWithFormat:@"%i%i", 0, minutes] : [NSString stringWithFormat:@"%i", minutes];
    minutesLabel.text = min ;
    NSString* sec = seconds < 10 ? [NSString stringWithFormat:@":%i%i", 0, seconds] : [NSString stringWithFormat:@":%i", seconds];
    secondsLabel.text = sec;
    
    if (seconds == 0 && minutes == 0){
        [timer invalidate];
        timer = nil;
        [timerView setHidden:YES];
        [enterPinButton setHidden:NO];
        [enterPinButton setTitle:NSLocalizedString(@"EnterPinCode", @"EnterPinCode") forState:UIControlStateNormal];
        [titleLabel setText:NSLocalizedString(@"ReEnterPinCode", @"ReEnterPinCode")];
        [titleLabel setHidden:NO];
        [titleLabel setTextColor:[UIColor blackColor]];
    }
    
}

-(void)showAlertView{
    [[CustomIOSAlertView alertWithTitle:NSLocalizedString(@"Info", @"Info") message:NSLocalizedString(@"LastAttempts", @"LastAttempts")] show];
}

@end
