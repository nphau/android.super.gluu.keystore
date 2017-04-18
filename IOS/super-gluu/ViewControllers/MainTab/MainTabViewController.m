//
//  MainTabViewController.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 4/14/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "MainTabViewController.h"

@import GoogleMobileAds;

@interface MainTabViewController (){

    GADBannerView *bannerView;
}

@end

@implementation MainTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Currently AD view will be shown all the time, should be configurable from Server
    [self initADView];
}

-(void)initADView{
    if (bannerView == nil){
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        [self.view addSubview:bannerView];
        bannerView.center = CGPointMake(bannerView.center.x, [UIScreen mainScreen].bounds.size.height - 75);
        bannerView.adUnitID = @"ca-app-pub-3326465223655655/9778254436";
        bannerView.rootViewController = self;
        [bannerView loadRequest:[GADRequest request]];
        NSLog(@"Banner loaded successfully");
    }
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
