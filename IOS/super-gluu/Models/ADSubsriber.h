//
//  ADSubsriber.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 6/9/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADSubsriber : NSObject

@property (nonatomic, assign) BOOL isSubscribed;

+ (instancetype) sharedInstance;

-(void)isSubscriptionExpired;
-(void)tryToSubsribe;

@end
