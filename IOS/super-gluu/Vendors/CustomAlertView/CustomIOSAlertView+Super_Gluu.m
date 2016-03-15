//
//  CustomIOSAlertView+Super_Gluu.m
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/14/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "CustomIOSAlertView+Super_Gluu.h"
#import <objc/runtime.h>

#define kCustomIOS7DefaultButtonColor [UIColor colorWithRed:0.670f green:0.670f blue:0.670f alpha:1.0f]
#define kCustomIOS7GreenButtonColor [UIColor colorWithRed:1/255.0 green:161/255.0 blue:97/255.0 alpha:1.0]

const static CGFloat kCustomIOS7AlertViewCornerRadius              = 0;

@implementation CustomIOSAlertView (Super_Gluu)

CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;

+ (CustomIOSAlertView *) alertWithTitle:(NSString *)title message:(NSString *)message
{
    CustomIOSAlertView* alertView = [[CustomIOSAlertView alloc] init];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, alertView.bounds.size.width - 40, 100)];
    
    // Add some custom content to the alert view
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, view.bounds.size.width - 40, 100)];
    titleLabel.numberOfLines = 0;
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:25.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    
    CGRect frame = titleLabel.frame;
    frame.size.width =  view.bounds.size.width - 40;
    titleLabel.frame = frame;
    
    [view addSubview:titleLabel];
    
    // Add some custom content to the alert view
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, view.bounds.size.width - 40, 100)];
    
    messageLabel.numberOfLines = 0;
    messageLabel.text = message;
    messageLabel.font = [UIFont systemFontOfSize:18.0f];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [messageLabel sizeToFit];
    
    CGRect frame2 = messageLabel.frame;
    frame2.size.width =  view.bounds.size.width - 40;
    messageLabel.frame = frame2;
    
    [view addSubview:messageLabel];
    
    CGRect frame3 = view.frame;
    frame3.size.height = titleLabel.bounds.size.height + messageLabel.bounds.size.height + 30;
    view.frame = frame3;

    [alertView setContainerView:view];
    [alertView setUseMotionEffects:true];
    
    return alertView;
}

- (void)addButtonsToView: (UIView *)container andButtonTitles:(NSArray*)buttonTitles
{
    for (int i = 0; i < [buttonTitles count]; i++)
    {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [closeButton setFrame:CGRectMake(0, container.bounds.size.height - ([buttonTitles count] - i) * (buttonHeight + buttonSpacerHeight), self.containerView.bounds.size.width, buttonHeight)];
        
        [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:i];
        [closeButton setTitle:[buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        
        if([self.buttonColors count] > i && [self.buttonColors objectAtIndex:i])
            [closeButton setBackgroundColor:[self.buttonColors objectAtIndex:i]];
        else [closeButton setBackgroundColor:kCustomIOS7GreenButtonColor];
        
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [closeButton.layer setCornerRadius:kCustomIOS7AlertViewCornerRadius];
        
        [container addSubview:closeButton];
    }
}

-(NSArray *)buttonColors{
    return objc_getAssociatedObject(self, @selector(buttonColors));
}

-(void)setButtonColors:(NSArray *)bColors{
    objc_setAssociatedObject(self, @selector(buttonColors), bColors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
