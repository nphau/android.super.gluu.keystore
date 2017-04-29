//
//  NotificationNetworkView.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 4/29/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "NotificationNetworkView.h"
#import "NetworkChecker.h"

@interface NotificationNetworkView ()

@end

@implementation NotificationNetworkView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self checkNetwork];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    return self;
}

-(IBAction)retry:(id)sender{
    [self checkNetwork];
}

-(void)checkNetwork{
    // Allocate a reachability object
    NetworkChecker* reach = [NetworkChecker reachabilityWithHostname:@"www.google.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(NetworkChecker *reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
            self.isNetworkAvailable = YES;
            [self showHideView];
        });
    };
    
    reach.unreachableBlock = ^(NetworkChecker *reach)
    {
        NSLog(@"UNREACHABLE!");
        self.isNetworkAvailable = NO;
        [self showHideView];
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];

}

-(void)showHideView{
    _retryButton.layer.cornerRadius = CORNER_RADIUS;
    CGFloat newY = self.isNetworkAvailable ? 0.0 : [self getYforDevice];
    [UIView animateWithDuration:0.5 animations: ^{
        self.center = CGPointMake(self.center.x, newY);
    }];
}

-(CGFloat)getYforDevice{
    CGFloat yPos = 68.0;
    
    if (IS_IPHONE_6){
        yPos = 88.0;
    }
    if (IS_IPHONE_6_PLUS){
        yPos = 110.0;
    }
    
    return yPos;
}


@end
