//
//  CustomIOSAlertView+Super_Gluu.h
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/14/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import <CustomIOSAlertView/CustomIOSAlertView.h>
#import "CustomIOSAlertView.h"

@interface CustomIOSAlertView (Super_Gluu)

@property (nonatomic, retain) NSArray *buttonColors;

+ (CustomIOSAlertView *) alertWithTitle:(NSString *)title message:(NSString *)message;

@end
