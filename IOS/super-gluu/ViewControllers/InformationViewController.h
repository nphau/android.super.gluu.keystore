//
//  InformationViewController.h
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/9/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TokenEntity.h"
#import "CustomIOSAlertView.h"

@interface InformationViewController : UIViewController <UIScrollViewDelegate, CustomIOSAlertViewDelegate>{

    IBOutlet UILabel* informationLabel;
    
    IBOutlet UILabel* userNameLabel;
    IBOutlet UILabel* createdLabel;
    IBOutlet UILabel* issuerLabel;
    IBOutlet UILabel* applicationLabel;
    IBOutlet UILabel* authenticationModeLabel;
    IBOutlet UILabel* authenticationTypeLabel;
    
    IBOutlet UILabel* userNameValueLabel;
    IBOutlet UILabel* createdValueLabel;
    IBOutlet UILabel* issuerValueLabel;
    IBOutlet UILabel* applicationValueLabel;
    IBOutlet UILabel* authenticationValueModeLabel;
    IBOutlet UILabel* authenticationValueTypeLabel;
    
    IBOutlet UIButton* closeButton;
    IBOutlet UIButton* deleteButton;
    
    IBOutlet UIScrollView* scrollView;
    
    BOOL isLandScape;
    
}

@property (strong, nonatomic) TokenEntity* token;

@end
