//
//  PinCodeViewController.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/16/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPasscodeViewController.h"
#import "PinCodeDelegate.h"

@interface PinCodeViewController : BaseViewController <PAPasscodeViewControllerDelegate>{

    IBOutlet UIView* topView;
    IBOutlet UIImageView* topIconView;
    IBOutlet UILabel* titleLabel;
    IBOutlet UIView* timerView;
    IBOutlet UILabel* minutesLabel;
    IBOutlet UILabel* secondsLabel;
    IBOutlet UIButton* nextButton;
    IBOutlet UIButton* skipButton;
    IBOutlet UIButton* enterPinButton;
    
    int countFailedPin;
    int minutes, seconds;
    NSTimer* timer;
    
    PAPasscodeViewController *passcodeViewController;
    id delegate;
    
}

@property (nonatomic, assign) Boolean isCallback;

- (void) setDelegate:(id)newDelegate;

@end
