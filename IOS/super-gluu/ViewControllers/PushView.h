//
//  PushView.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 4/8/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LecenseAgreementDelegate.h"

@interface PushView : UIControl

@property (nonatomic,assign)  id <LicenseAgreementDelegate> delegate;
@property (strong, nonatomic) UILabel* pushLabel;

-(id)init;
- (id)initWithFrame:(CGRect)frame;

@end
