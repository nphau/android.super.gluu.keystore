//
//  InformationViewController.h
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/9/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TokenEntity.h"

@interface InformationViewController : UIViewController <UIScrollViewDelegate>{

    IBOutlet UILabel* informationLabel;
    
    IBOutlet UILabel* userNameValueLabel;
    IBOutlet UILabel* createdValueLabel;
    IBOutlet UILabel* issuerValueLabel;
    IBOutlet UILabel* applicationValueLabel;
    IBOutlet UILabel* keyHandleValueLabel;
    
    IBOutlet UIButton* closeButton;
    IBOutlet UIButton* deleteButton;
    
    IBOutlet UIView* infoView;
    
}

@property (strong, nonatomic) TokenEntity* token;

@end
