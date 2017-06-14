//
//  ADViewSubscriber.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 6/9/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "ADViewSubscriber.h"
#import "ADSubsriber.h"

@implementation ADViewSubscriber

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Init code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adViewShow:) name:NOTIFICATION_AD_NOT_FREE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adViewHide:) name:NOTIFICATION_AD_FREE object:nil];
    self.hidden = YES;
    
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initUI{
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 2.0;
    self.adFreeButton.layer.cornerRadius = CORNER_RADIUS;
    [self.adFreeButton setBackgroundColor:[[AppConfiguration sharedInstance] systemColor]];
}

- (IBAction)adFreeAction:(id)sender{
    [[ADSubsriber sharedInstance] tryToSubsribe];
}

-(void)adViewShow:(NSNotification*)notification{
    [self initUI];
    self.hidden = NO;
}

-(void)adViewHide:(NSNotification*)notification{
    self.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
