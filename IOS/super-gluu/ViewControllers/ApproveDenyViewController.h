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
#import "CoreLocation/CoreLocation.h"

@interface ApproveDenyViewController : UIViewController <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
 
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
    
    BOOL isLocation;
}

@property (nonatomic,assign)  id <LicenseAgreementDelegate> delegate;
@property (assign, nonatomic) BOOL isLogInfo;

-(void)updateInfo;

-(IBAction)onApprove:(id)sender;
-(IBAction)onDeny:(id)sender;

@end
