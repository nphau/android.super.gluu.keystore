//
//  ApproveDenyViewController.h
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/3/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "LecenseAgreementDelegate.h"
#import "UserLoginInfo.h"
#import "CATCurveProgressView.h"

@interface ApproveDenyViewController : BaseViewController <UIScrollViewDelegate> {
 
    
    IBOutlet UILabel* titleLabel;
    
    IBOutlet UIView* approveDenyContainerView;
    IBOutlet UIButton* approveRequest;
    IBOutlet UIButton* denyRequest;
    
    //Info
    IBOutlet UILabel* serverNameLabel;
    IBOutlet UILabel* serverUrlLabel;
    
    IBOutlet UILabel* userNameLabel;
    
    IBOutlet UILabel* locationLabel;
    IBOutlet UILabel* cityNameLabel;
    
    IBOutlet UILabel* createdTimeLabel;
    IBOutlet UILabel* createdDateLabel;

    IBOutlet UILabel* typeLabel;
    
    IBOutlet UIView* navigationView;
    IBOutlet UIButton* backButton;
    IBOutlet UIView* buttonView;
    
    IBOutlet CATCurveProgressView* timerView;
    
    IBOutlet UIView* mainInfoView;
    
    BOOL isLandScape;
    
    NSTimer* timer;
    int time;
    UILabel* timerLabel;
    
    IBOutlet UIImageView* approveImage;
    IBOutlet UIImageView* denyImage;
    
    IBOutletCollection(UIView) NSArray *separators;
    IBOutletCollection(UILabel) NSArray *titleLabels;
    IBOutletCollection(UILabel) NSArray *subtitleLabels;
}

@property (nonatomic,assign)  id <ApproveDenyDelegate> delegate;

// if isLogInfo, we're just displaying info about a previous data log
@property (assign, nonatomic) BOOL isLogInfo;

@property (strong, nonatomic) UserLoginInfo* userInfo;

-(void)updateInfo;

-(IBAction)onApprove:(id)sender;
-(IBAction)onDeny:(id)sender;

@end
