//
//  SuperGluuBannerView.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 5/2/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "SuperGluuBannerView.h"

@implementation SuperGluuBannerView{

    GADBannerView *bannerView;
    GADInterstitial *interstitial;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
     Drawing code
}
*/

-(id)initWithAdSize:(GADAdSize)adSize andRootView:(UIViewController*)rootView{
    //Determine type of AD (banner or interstitial)
    if (adSize.size.height == kGADAdSizeBanner.size.height &&
        adSize.size.width == kGADAdSizeBanner.size.width){
        //Banner
        if (bannerView == nil){
            bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
            [rootView.view addSubview:bannerView];
            if (adSize.size.height == kGADAdSizeBanner.size.height &&
                adSize.size.width == kGADAdSizeBanner.size.width){
                bannerView.center = CGPointMake(bannerView.center.x, [UIScreen mainScreen].bounds.size.height - 75);
                bannerView.adUnitID = @"ca-app-pub-3326465223655655/9778254436";
            }
            bannerView.rootViewController = rootView;
            [bannerView loadRequest:[GADRequest request]];
            NSLog(@"Banner loaded successfully");
        }
    } else {
        //interstitial
        [self showInterstitial:rootView];
    }
    return self;
}

- (void)createInterstitial:(UIViewController*)rootView {
    interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3326465223655655/1731023230"];
    GADRequest *request = [GADRequest request];
    request.testDevices = @[kGADSimulatorID];
    [interstitial loadRequest:request];
}

- (void)showInterstitial:(UIViewController*)rootView{
    if (interstitial.isReady) {
        [interstitial presentFromRootViewController:rootView];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

-(void)closeAD{
    bannerView.hidden = YES;
    //bannerView.center = CGPointMake(bannerView.center.x, [UIScreen mainScreen].bounds.size.height + 75);
}

@end
