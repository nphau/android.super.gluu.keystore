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
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
     Drawing code
}
*/

-(id)initWithAdSize:(GADAdSize)adSize andRootView:(UIViewController*)rootView{
    if (bannerView == nil){
        bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
        [rootView.view addSubview:bannerView];
        if (adSize.size.height == kGADAdSizeBanner.size.height &&
            adSize.size.width == kGADAdSizeBanner.size.width){
            bannerView.center = CGPointMake(bannerView.center.x, [UIScreen mainScreen].bounds.size.height - 75);
//            bannerView.adUnitID = @"ca-app-pub-3326465223655655/1731023230";
            bannerView.adUnitID = @"ca-app-pub-3326465223655655/9778254436";
        } else {
            //Add close button for full screen AD
            UIButton* closeButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, [UIScreen mainScreen].bounds.size.height - 35, 70, 30)];
            [closeButton setTitle:@"Close" forState:UIControlStateNormal];
            [closeButton addTarget:rootView action:@selector(closeAD) forControlEvents:UIControlEventTouchUpInside];
            closeButton.layer.cornerRadius = CORNER_RADIUS;
            closeButton.layer.borderColor = [UIColor whiteColor].CGColor;
            closeButton.layer.borderWidth = 2.0;
            [bannerView addSubview:closeButton];
            bannerView.adUnitID = @"ca-app-pub-3326465223655655/9778254436";
//          bannerView.adUnitID = @"ca-app-pub-3326465223655655/1731023230";
        }
        bannerView.rootViewController = rootView;
        [bannerView loadRequest:[GADRequest request]];
        NSLog(@"Banner loaded successfully");
    }
    return self;
}

-(void)closeAD{
    [bannerView removeFromSuperview];
}

@end
