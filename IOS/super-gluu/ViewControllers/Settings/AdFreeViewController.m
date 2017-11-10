//
//  AdFreeViewController.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 10/6/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "AdFreeViewController.h"
#import "ADSubsriber.h"
#import "SCLAlertView.h"

@interface AdFreeViewController ()

@end

@implementation AdFreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.purchaseTextView setContentOffset:CGPointZero animated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.purchaseTextView setContentOffset:CGPointZero animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onAdFree:(id)sender{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    SCLButton * noButton = [alert addButton:NSLocalizedString(@"Cancel", @"Cancel") actionBlock:^(void) {
        NSLog(@"Cancel clicked");
    }];
    [noButton setDefaultBackgroundColor:[UIColor redColor]];
    [alert addButton:NSLocalizedString(@"OK", @"OK") actionBlock:^(void) {
        NSLog(@"OK clicked");
        [[ADSubsriber sharedInstance] tryToSubsribe];
    }];
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:@"Ad-Free Subscriptions" subTitle: @"The monthly subscription makes Super Gluu totally ad-free. The subscription auto-renews each month for $0.99. If you previously purchased a subscription on another device, click the \"Restore\" button in the menu to restore your subscription." closeButtonTitle:nil duration:0.0f];
}

-(IBAction)onRestoreSubscription:(id)sender{
    [[ADSubsriber sharedInstance] restorePurchase];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
