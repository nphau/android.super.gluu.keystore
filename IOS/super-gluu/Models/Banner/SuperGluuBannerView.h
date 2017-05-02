//
//  SuperGluuBannerView.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 5/2/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMobileAds;

@interface SuperGluuBannerView : UIView

-(id)initWithAdSize:(GADAdSize)adSize andRootView:(UIViewController*)rootView;

-(void)closeAD;

@end
