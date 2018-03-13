//
//  AppConfiguration.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 6/14/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "AppConfiguration.h"

#define SYSTEM_TITLE @"systemTitle"
#define SYSTEM_ICON @"systemIcon"
#define SYSTEM_ALERT_ICON @"systemAlertIcon"
#define SYSTEM_LOG_ICON @"icon_gluu_logo_log_details"
#define SYSTEM_LOG_RED_ICON @"systemLogRedIcon"
#define SYSTEM_COLOR @"systemColor"

@implementation AppConfiguration{

    NSDictionary *configDict;
}

+ (instancetype) sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance loadConfigurationFile];
        NSLog(@"%@", [NSString stringWithFormat:@"APP - %@", @"Configuration file loaded success"]);
    });
    return instance;
}

-(void)loadConfigurationFile{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pListpath = [bundle pathForResource:@"appConfiguration" ofType:@"plist"];
    configDict = [[NSDictionary alloc] initWithContentsOfFile:pListpath];
}

//Public methods
-(NSString*)systemTitle{
    
    NSString* title = [configDict valueForKey:SYSTEM_TITLE];
    return title;
}

//----------------------- Icons -------------
-(UIImage*)systemIcon{
    
    NSString* icon = [configDict valueForKey:SYSTEM_ICON];
    
    if (configDict == nil || [icon isEqualToString:@""]){
        return [UIImage imageNamed:@"gluu.png"];
    }
    
    return [UIImage imageNamed:icon];
}

-(UIImage*)systemAlertIcon{
    
    NSString* icon = [configDict valueForKey:SYSTEM_ALERT_ICON];
    
    if (configDict == nil || [icon isEqualToString:@""]){
        return [UIImage imageNamed:@"gluuIconAlert.png"];
    }
    
    return [UIImage imageNamed:icon];
}

-(UIImage*)systemLogIcon{
    
    NSString* icon = [configDict valueForKey:SYSTEM_LOG_ICON];
    
    if (configDict == nil || [icon isEqualToString:@""]){
        return [UIImage imageNamed:@"gluuIcon.png"];
    }
    
    return [UIImage imageNamed:SYSTEM_LOG_ICON];
}

-(UIImage*)systemLogRedIcon{
    
    NSString* icon = [configDict valueForKey:SYSTEM_LOG_RED_ICON];
    
    if (configDict == nil || [icon isEqualToString:@""]){
        return [UIImage imageNamed:@"gluuIconRed.png"];
    }
    
    return [UIImage imageNamed:icon];
}
//----------------------- End Icons -------------

// ---------------------- Colors -----------------
-(UIColor*)systemColor{
    
    NSDictionary* colorDic = [configDict objectForKey:SYSTEM_COLOR];
    
    NSInteger red = [[colorDic objectForKey:@"red"] integerValue];
    NSInteger green = [[colorDic objectForKey:@"green"] integerValue];
    NSInteger blue = [[colorDic objectForKey:@"blue"] integerValue];
    float alpha = [[colorDic objectForKey:@"alpha"] floatValue];
    
    if (configDict == nil || colorDic == nil){
        return [UIColor colorWithRed:1/255.0 green:161/255.0 blue:97/255.0 alpha:1.0];
    }
    
    return [UIColor colorWithRed:red/256.0 green:green/256.0 blue:blue/256.0 alpha:alpha];
}
//----------------------- End Colors -------------

@end
