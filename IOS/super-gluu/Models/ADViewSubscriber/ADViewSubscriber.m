//
//  ADViewSubscriber.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 6/9/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "ADViewSubscriber.h"
#import "ADSubsriber.h"
#import "AppConfiguration.h"
#import "SCLAlertView.h"

@implementation ADViewSubscriber

-(void)initUI{

    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 3;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 0.3;
    self.layer.cornerRadius = CORNER_RADIUS;
    self.adFreeButton.layer.cornerRadius = CORNER_RADIUS;
}

/*
- (IBAction)adFreeAction:(id)sender{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    SCLButton * noButton = [alert addButton:NSLocalizedString(@"Cancel", @"Cancel") actionBlock:^(void) {
        NSLog(@"Cancel clicked");
    }];
    [noButton setDefaultBackgroundColor:[UIColor redColor]];
    [alert addButton:NSLocalizedString(@"OK", @"OK") actionBlock:^(void) {
        NSLog(@"OK clicked");
        [[ADSubsriber sharedInstance] purchaseSubscription:^(BOOL success, NSString *message) {
            if (success == true) {
                [[AdHandler shared] refreshAdStatus];
            } else {
                SCLAlertView *errAlert = [[SCLAlertView alloc] initWithNewWindow];
                [errAlert showError:@"Unable to purchase" subTitle:message closeButtonTitle:@"Ok" duration:3.0];
            }
        }];
    }];
    [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:@"Ad-Free Subscriptions" subTitle: @"The monthly subscription makes Super Gluu totally ad-free. The subscription auto-renews each month for $0.99. If you previously purchased a subscription on another device, click the \"Restore\" button in the menu to restore your subscription." closeButtonTitle:nil duration:0.0f];
}
 */



@end
