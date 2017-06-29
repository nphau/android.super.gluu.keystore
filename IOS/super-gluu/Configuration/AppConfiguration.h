//
//  AppConfiguration.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 6/14/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppConfiguration : NSObject

+ (instancetype) sharedInstance;

-(NSString*)systemTitle;
-(UIImage*)systemIcon;
-(UIImage*)systemAlertIcon;
-(UIImage*)systemLogIcon;
-(UIImage*)systemLogRedIcon;
-(UIColor*)systemColor;

@end
