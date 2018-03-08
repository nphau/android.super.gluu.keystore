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
    
    [self setupView];

}

- (void)setupView {
    
    self.view.backgroundColor = [Constant tableBackgroundColor];
    
    for (UILabel *label in valueLabels) {
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [Constant appGreenColor];
    }
    
    for (UILabel *label in keyLabels) {
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor blackColor];
    }
    
    for (UIView *view in separators) {
        view.backgroundColor = [Constant tableBackgroundColor];
    }
    
    self.navigationItem.rightBarButtonItem = [self editBBI];
    
}

- (UIBarButtonItem *)editBBI {
    
    SEL editSel = @selector(showEditActionSheet);
    
    return [[UIBarButtonItem alloc] initWithTitle: @"Edit"
                                            style: UIBarButtonItemStylePlain
                                           target: self
                                           action: editSel];
    
}

- (void)showEditActionSheet {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
            // Cancel button tappped.
        [actionSheet dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
            // Distructive button tapped.
        [self performSelector:@selector(delete)];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Edit Name" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [actionSheet dismissViewControllerAnimated:true completion:^{
        }];
        
        [self showKeyRenameAlert];
        
    }]];
    
        // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (void)showKeyRenameAlert {


    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert setHorizontalButtons:YES];
    
    alert.backgroundViewColor = [UIColor whiteColor];
    
    [alert setTitleFontFamily:@"ProximaNova-Semibold" withSize:20.0f withColor:[[AppConfiguration sharedInstance] systemColor]];
    [alert setBodyTextFontFamily:@"ProximaNova-Regular" withSize:15.0f];
    [alert setButtonsTextFontFamily:@"ProximaNova-Regular" withSize:15.0f];
    
    SCLTextView *textField = [alert addTextField:@"Enter a name"];
    
    SCLButton* saveButton = [alert addButton:@"Save" actionBlock:^(void) {
        NSString *newName = textField.text;
        
        if ([[DataStoreManager sharedInstance] isUniqueTokenName:newName]) {
            [[DataStoreManager sharedInstance] setTokenEntitiesNameByID:self.token->ID userName:self.token->userName newName:newName];
        } else {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showCustom:[[AppConfiguration sharedInstance] systemAlertIcon] color:[[AppConfiguration sharedInstance] systemColor] title:NSLocalizedString(@"Info", @"Info") subTitle:@"Name already exists or is empty. Please enter another one." closeButtonTitle:@"Close" duration:0.0f];
        }

    }];
    
    [saveButton setDefaultBackgroundColor:[[AppConfiguration sharedInstance] systemColor]];
    
    alert.completeButtonFormatBlock = ^NSDictionary* (void)
    {
    NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
    
    buttonConfig[@"backgroundColor"] = [UIColor redColor];
    buttonConfig[@"textColor"] = [UIColor whiteColor];
    
    return buttonConfig;
    };
    
    [alert showTitle:self image:[UIImage imageNamed:@"rename_action_title_icon"] color:[[AppConfiguration sharedInstance] systemColor] title:@"Change key name" subTitle:@"Enter a new name for your key:" style:SCLAlertViewStyleCustom closeButtonTitle:@"Cancel" duration:0.0f];
}

-(void)setupInformation{
    if ([_token isKindOfClass:[TokenEntity class]]){
        
        NSURL* url = [NSURL URLWithString:_token->application];
        NSString* keyHandleString = [NSString stringWithFormat:@"%@...%@", [_token->keyHandle substringToIndex:6], [_token->keyHandle substringFromIndex:_token->keyHandle.length - 6]];
        NSString* time = [self convertPairingTime:_token->pairingTime];
        
        userNameValueLabel.text = _token->userName;
        createdValueLabel.text = time;
        applicationValueLabel.text = url.host;
        keyHandleValueLabel.text = keyHandleString;
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
//    informationLabel.text = NSLocalizedString(@"Information", @"Information");
//    userNameLabel.text = NSLocalizedString(@"UserName", @"UserName");
//    createdLabel.text = NSLocalizedString(@"Created", @"Created");
//    applicationLabel.text = NSLocalizedString(@"Application", @"Application");
//    issuerLabel.text = NSLocalizedString(@"Issuer", @"Issuer");
//    closeButton.titleLabel.text = NSLocalizedString(@"CloseButton", @"CloseButton");
//    keyHandleLabel.text = NSLocalizedString(@"keyHandle", @"Key handle");
}

- (void)delete {
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
    // Eric
     [[DataStoreManager sharedInstance] deleteTokenEntitiesByID:_token->application userName:_token->userName];

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSAttributedString*)generateAttrStrings:(NSString*)name value:(NSString*)value {
    
    NSString* wholeString = [NSString stringWithFormat:@"%@ : %@", name, value];
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:wholeString];
    
    NSRange rangeName = [wholeString rangeOfString:name];
    NSRange rangeDots = [wholeString rangeOfString:@":"];
    NSRange rangeValue = [wholeString rangeOfString:value];
    
    [attrString addAttribute:NSForegroundColorAttributeName
                   value:[UIColor blackColor]
                   range:rangeName];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[Constant appGreenColor]
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
