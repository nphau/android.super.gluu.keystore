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

@interface ApproveDenyViewController : UIViewController <UIScrollViewDelegate> {
 
    IBOutlet UILabel* titleLabel;
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
    
    IBOutlet UIView* serverView;
    IBOutlet UIView* userNameView;
    IBOutlet UIView* locationView;
    IBOutlet UIView* timeView;
    
    IBOutlet UIButton* backButton;
    
    IBOutlet UIView* buttonView;
    
    IBOutlet UIView* timerView;
    
    IBOutlet UIScrollView* scrollView;
    
    BOOL isLandScape;
    
    NSTimer* timer;
    int time;
    IBOutlet UILabel* timerLabel;
    IBOutlet UILabel* timerLabelTitle;
}

@property (nonatomic,assign)  id <LicenseAgreementDelegate> delegate;
@property (assign, nonatomic) BOOL isLogInfo;
@property (strong, nonatomic) UserLoginInfo* userInfo;

-(void)updateInfo;

-(IBAction)onApprove:(id)sender;
-(IBAction)onDeny:(id)sender;

+ (NSString *)getIPAddress;

@end
