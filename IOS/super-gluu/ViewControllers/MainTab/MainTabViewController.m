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
    
    SuperGluuBannerView* bannerView;
}

@end

@implementation MainTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Currently AD view will be shown all the time, should be configurable from Server
    [self initADView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_REGISTRATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_REGISTRATION_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_AUTENTIFICATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFullPageBanner:) name:NOTIFICATION_AUTENTIFICATION_FAILED object:nil];
}

-(void)initADView{
    SuperGluuBannerView* smallBannerView = [[SuperGluuBannerView alloc] initWithAdSize:kGADAdSizeBanner andRootView:self];
    smallBannerView.alpha = 1.0;
}

-(void)initFullPageBanner:(NSNotification*)notification{
    bannerView = [[SuperGluuBannerView alloc] initWithAdSize:GADAdSizeFullWidthPortraitWithHeight([UIScreen mainScreen].bounds.size.height) andRootView:self];
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
