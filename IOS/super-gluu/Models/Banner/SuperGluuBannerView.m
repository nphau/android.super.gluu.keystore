//
//  SuperGluuBannerView.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 5/2/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "SuperGluuBannerView.h"

@implementation SuperGluuBannerView {

    GADBannerView *bannerView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
     Drawing code
}
*/

-(id)initWithAdSize:(GADAdSize)adSize andRootViewController:(UIViewController*)rootVC{
    //Determine type of AD (banner or interstitial)
    
    self = [[SuperGluuBannerView alloc] init];
    self.frame = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
    
    if (adSize.size.height == kGADAdSizeBanner.size.height &&
        adSize.size.width == kGADAdSizeBanner.size.width) {
    
            //Banner
        if (bannerView == nil) {
            
            bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
            bannerView.adUnitID = @"ca-app-pub-3326465223655655/9778254436";
            bannerView.rootViewController = rootVC;
                
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat screenHeight = rootVC.view.bounds.size.height;
            
            CGFloat adHeight = adSize.size.height;
            
            CGFloat adCenterX = screenWidth / 2;
            CGFloat adCenterY = screenHeight - (adHeight / 2);
            
            [self addSubview:bannerView];
            self.center = CGPointMake(adCenterX, adCenterY);
            
            bannerView.frame = self.bounds;
            
            [rootVC.view addSubview:self];
            [rootVC.view bringSubviewToFront:self];
            
            [bannerView loadRequest:[GADRequest request]];
            
            NSLog(@"Banner loaded successfully");
        }
    }

    return self;
}

- (void)createAndLoadInterstitial {
    _interstitial = nil;
    _interstitial.delegate = nil;
    GADInterstitial* newInterstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3326465223655655/1731023230"];
    GADRequest *request = [GADRequest request];
    request.testDevices = @[kGADSimulatorID];
    [newInterstitial loadRequest:request];
    _interstitial = newInterstitial;
    _interstitial.delegate = self;
}

- (void)showInterstitial:(UIViewController*)rootView {
    
    if ([AdHandler shared].shouldShowAds == false) {
        return;
    }
    
    if (_interstitial.isReady) {
        [_interstitial presentFromRootViewController:rootView];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self showInterstitial:rootView];
        });
        
        NSLog(@"Ad wasn't ready");
    }
}

-(void)closeAD {
    bannerView.hidden = YES;
    [self removeFromSuperview];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    [self createAndLoadInterstitial];
}

@end
