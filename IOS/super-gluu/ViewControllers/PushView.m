//
//  PushView.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 4/8/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "PushView.h"
#import "Constants.h"

@interface PushView ()

@end

@implementation PushView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWidget];
}

- (void) initWidget{
    //create main push view
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [blurEffectView setTag:BLUR_VIEW_TAG];
    [self.view addSubview:blurEffectView];
    
    UILabel* loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, self.view.frame.size.width, 30)];
    loadingLabel.text = @"Enrol/Authentication request";
    loadingLabel.textColor = [UIColor whiteColor];
    [blurEffectView addSubview:loadingLabel];
    
    UIButton* approveButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width/2, 30)];
    [approveButton setTitle:NSLocalizedString(@"Approve", @"Approve") forState:UIControlStateNormal];
    approveButton.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.1];
    approveButton.layer.cornerRadius = CORNER_RADIUS;
    approveButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIButton* denyButton = [[UIButton alloc] initWithFrame:CGRectMake(approveButton.frame.origin.x + 30, 70, self.view.frame.size.width/2, 30)];
    [denyButton setTitle:NSLocalizedString(@"Deny", @"Deny") forState:UIControlStateNormal];
    denyButton.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.1];
    denyButton.layer.cornerRadius = CORNER_RADIUS;
    denyButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [blurEffectView addSubview:approveButton];
    [blurEffectView addSubview:denyButton];
    
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
