//
//  InformationViewController.h
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/9/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TokenEntity.h"

@interface InformationViewController : BaseViewController <UIScrollViewDelegate>{
    
    IBOutlet UILabel* userNameValueLabel;
    IBOutlet UILabel* createdValueLabel;
    IBOutlet UILabel* applicationValueLabel;
    IBOutlet UILabel* keyHandleValueLabel;
    
    IBOutletCollection(UILabel) NSArray *valueLabels;
    IBOutletCollection(UIView) NSArray *separators;
    IBOutletCollection(UILabel) NSArray *keyLabels;
    
}

@property (strong, nonatomic) TokenEntity* token;

@end
