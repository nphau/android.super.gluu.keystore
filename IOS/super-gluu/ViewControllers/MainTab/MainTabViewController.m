//
//  MainTabViewController.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 4/14/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "MainTabViewController.h"
#import "SuperGluuBannerView.h"


@interface MainTabViewController (){
    
    SuperGluuBannerView* smallBannerView;
    SuperGluuBannerView* bannerView;
}

@end

@implementation MainTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#ifdef ADFREE
    //skip here
#else
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideADView:) name:NOTIFICATION_AD_FREE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initADView:) name:NOTIFICATION_AD_NOT_FREE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInterstial:) name:NOTIFICATION_INTERSTIAL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_REGISTRATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_REGISTRATION_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_AUTENTIFICATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_AUTENTIFICATION_FAILED object:nil];
#endif
    bannerView = [[SuperGluuBannerView alloc] init];
    [bannerView createInterstitial:self];
}

-(void)initADView:(NSNotification*)notification{
    smallBannerView = [[SuperGluuBannerView alloc] initWithAdSize:kGADAdSizeBanner andRootView:self];
    smallBannerView.alpha = 1.0;
}

-(void)hideADView:(NSNotification*)notification{
    if (smallBannerView != nil){
        [smallBannerView closeAD];
    }
}

-(void)reloadInterstial:(NSNotification*)notification{
    bannerView = [[SuperGluuBannerView alloc] init];
    [bannerView createInterstitial:self];
}

-(void)initFullPageBanner:(NSNotification*)notification{
    [bannerView showInterstitial:self];
}

-(void)closeAD{
    [bannerView closeAD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
