//
//  InformationViewController.m
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/9/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import "InformationViewController.h"
#import "Constants.h"
#import "DataStoreManager.h"
#import "SCLAlertView.h"

@implementation InformationViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupInformation];
    [self initLocalization];
}

-(void)setupInformation{
    if ([_token isKindOfClass:[TokenEntity class]]){
        NSURL* url = [NSURL URLWithString:_token->application];
        NSString* keyHandleString = [NSString stringWithFormat:@"%@...%@", [_token->keyHandle substringToIndex:6], [_token->keyHandle substringFromIndex:_token->keyHandle.length - 6]];
        NSString* time = [self convertPairingTime:_token->pairingTime];
        userNameValueLabel.attributedText = [self generateAttrStrings:@"Username" value:_token->userName];
        createdValueLabel.attributedText = [self generateAttrStrings:@"Created" value:time];
        applicationValueLabel.attributedText = [self generateAttrStrings:@"Username" value:url.host];
        keyHandleValueLabel.attributedText = [self generateAttrStrings:@"Key handle" value:keyHandleString];
    }
}

-(NSString*)convertPairingTime:(NSString*)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    NSDate* date = [formatter dateFromString:time];
    [formatter setDateFormat:@" MMM dd, yyyy hh:mm:ss"];
    return [formatter stringFromDate:date];
}

-(void)initLocalization{
    informationLabel.text = NSLocalizedString(@"Information", @"Information");
//    userNameLabel.text = NSLocalizedString(@"UserName", @"UserName");
//    createdLabel.text = NSLocalizedString(@"Created", @"Created");
//    applicationLabel.text = NSLocalizedString(@"Application", @"Application");
//    issuerLabel.text = NSLocalizedString(@"Issuer", @"Issuer");
    closeButton.titleLabel.text = NSLocalizedString(@"CloseButton", @"CloseButton");
//    keyHandleLabel.text = NSLocalizedString(@"keyHandle", @"Key handle");
}

-(IBAction)delete:(id)sender{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:NSLocalizedString(@"YES", @"YES") actionBlock:^(void) {
        NSLog(@"YES clicked");
        [self deleteKey];
    }];
    SCLButton* noButton = [alert addButton:NSLocalizedString(@"NO", @"NO") actionBlock:^(void) {
        NSLog(@"NO clicked");
    }];
    [noButton setDefaultBackgroundColor:[UIColor redColor]];
    [alert showCustom:[UIImage imageNamed:@"delete_action_titleIcon"] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Delete", @"Delete") subTitle:NSLocalizedString(@"DeleteKeyHandle", @"Delete KeyHandle") closeButtonTitle:nil duration:0.0f];
}

-(void)deleteKey{
    [[DataStoreManager sharedInstance] deleteTokenEntitiesByID:_token->application userName:_token->userName];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSAttributedString*)generateAttrStrings:(NSString*)name value:(NSString*)value {
    
    NSString* wholeString = [NSString stringWithFormat:@"%@ : %@", name, value];
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:wholeString];
    
    NSRange rangeName = [wholeString rangeOfString:name];
    NSRange rangeDots = [wholeString rangeOfString:@":"];
    NSRange rangeValue = [wholeString rangeOfString:value];
    
    UIColor* green = [UIColor colorWithRed:1/256.0 green:161/256.0 blue:97/256.0 alpha:1.0];
    
    [attrString addAttribute:NSForegroundColorAttributeName
                   value:[UIColor blackColor]
                   range:rangeName];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:green
                       range:rangeDots];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor grayColor]
                       range:rangeValue];
    
    return attrString;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
