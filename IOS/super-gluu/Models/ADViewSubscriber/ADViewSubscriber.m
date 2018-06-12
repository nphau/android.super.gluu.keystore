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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Init code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adViewShow:) name:NOTIFICATION_AD_NOT_FREE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adViewHide:) name:NOTIFICATION_AD_FREE object:nil];
    self.hidden = YES;
    
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initUI{
//    self.layer.borderColor = [UIColor blackColor].CGColor;
//    self.layer.borderWidth = 2.0;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 3;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 0.3;
    self.layer.cornerRadius = CORNER_RADIUS;
    self.adFreeButton.layer.cornerRadius = CORNER_RADIUS;
//    [self.adFreeButton setBackgroundColor:[[AppConfiguration sharedInstance] systemColor]];
}

- (IBAction)adFreeAction:(id)sender{
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

-(void)adViewShow:(NSNotification*)notification{
    
    BOOL isLicensed = [[NSUserDefaults standardUserDefaults] boolForKey:LICENSED_AD_FREE];
    if (isLicensed != true) {
        [self initUI];
        self.hidden = NO;
    } else {
        self.hidden = YES;
    }
}

-(void)adViewHide:(NSNotification*)notification{
    self.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
