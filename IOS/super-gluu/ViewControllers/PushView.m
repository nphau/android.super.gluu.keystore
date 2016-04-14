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

- (id)init {
    
    return [self initWithFrame:CGRectZero];
    
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        [self initWidget];
        
    }
    return self;
}

- (void) initWidget{
    //create main push view
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:blurEffectView];
    
    //Create logo
    UIImageView* logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gluuIcon40x3.png"]];
    logo.layer.cornerRadius = CORNER_RADIUS;
    [logo setFrame:CGRectMake(10, 20, 35, 35)];
    
    //Create application name label
    UILabel* appLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 15, 60, 20)];
    appLabel.text = @"Super Gluu";
    appLabel.font = [UIFont systemFontOfSize:10];
    appLabel.textColor = [UIColor whiteColor];
    [appLabel setUserInteractionEnabled:NO];
    
    //When label
    UILabel* timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50 + appLabel.frame.size.width + 10, 15, self.frame.size.width, 20)];
    timeLabel.text = @"now";
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.textColor = [UIColor grayColor];
    [timeLabel setUserInteractionEnabled:NO];
    
    _pushLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 35, self.frame.size.width, 20)];
    _pushLabel.text = @"Enrol/Authentication request";
    _pushLabel.font = [UIFont systemFontOfSize:12];
    _pushLabel.textColor = [UIColor whiteColor];
    [_pushLabel setUserInteractionEnabled:NO];
    
    
    UIButton* denyButton = [[UIButton alloc] init];
    [denyButton setFrame:CGRectMake(10, 80, self.frame.size.width/2.5, 30)];
    [denyButton setTitle:NSLocalizedString(@"Deny", @"Deny") forState:UIControlStateNormal];
    denyButton.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.3];
    denyButton.layer.cornerRadius = CORNER_RADIUS;
    denyButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [denyButton addTarget:self action:@selector(onDenyClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* approveButton = [[UIButton alloc] init];
    [approveButton setFrame:CGRectMake(10 + denyButton.frame.size.width + 30, 80, self.frame.size.width/2.5, 30)];
    [approveButton setTitle:NSLocalizedString(@"Approve", @"Approve") forState:UIControlStateNormal];
    approveButton.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.3];
    approveButton.layer.cornerRadius = CORNER_RADIUS;
    approveButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [approveButton addTarget:self action:@selector(onApproveClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self setUserInteractionEnabled:YES];
    
    [self addSubview:logo];
    [self addSubview:appLabel];
    [self addSubview:timeLabel];
    [self addSubview:_pushLabel];
    [self addSubview:approveButton];
    [self addSubview:denyButton];
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    [self addTarget:_delegate action:@selector(openRequest) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)onApproveClicked:(id)sender{
    NSLog(@"Button Approve clicked!");
    [_delegate approveRequest];
}

-(void)onDenyClicked:(id)sender{
    NSLog(@"Button Deny clicked!");
    [_delegate denyRequest];
}

-(void)openRequest{
    NSLog(@"Open request clicked!");
    [_delegate openRequest];
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
