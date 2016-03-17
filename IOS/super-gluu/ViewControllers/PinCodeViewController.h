//
//  PinCodeViewController.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/16/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPasscodeViewController.h"

@interface PinCodeViewController : UIViewController <PAPasscodeViewControllerDelegate>{

    IBOutlet UILabel* titleLabel;
    IBOutlet UIView* passCodeView;
    IBOutlet UIButton* nextButton;
    IBOutlet UIButton* skipButton;
    
}

@end
