//
//  SuperGluuBannerView.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 5/2/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMobileAds;

@interface SuperGluuBannerView : UIView <GADInterstitialDelegate>

@property (nonatomic, strong) GADInterstitial *interstitial;

-(id)initWithAdSize:(GADAdSize)adSize andRootView:(UIViewController*)rootView;

- (void)createAndLoadInterstitial;

- (void)showInterstitial:(UIViewController*)rootView;

-(void)closeAD;

@end
