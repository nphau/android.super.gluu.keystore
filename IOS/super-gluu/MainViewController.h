//
//  MainViewController.h
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/1/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeReaderDelegate.h"
#import "ApproveDenyViewController.h"
#import "UserLoginInfo.h"
#import "LecenseAgreementDelegate.h"

@interface MainViewController : UIViewController <QRCodeReaderDelegate, ApproveDenyDelegate>{
    
    IBOutlet UIButton* scanButton;
    IBOutlet UIButton* infoButton;
    IBOutlet UILabel* statusLabel;
    IBOutlet UIView* statusView;
    
    IBOutlet UILabel* welcomeLabel;
    IBOutlet UILabel* scanTextLabel;
    IBOutlet UIView* welcomeView;
    IBOutlet UIView* contentView;

    BOOL isResultFromScan;
    BOOL isStatusViewVisible;
    BOOL isUserInfo;
    QRCodeReaderViewController *qrScanerVC;
    
    NSDictionary* scanJsonDictionary;
    
    BOOL isLocation;
    
    BOOL isLandScape;

}

- (IBAction)scanAction:(id)sender;
- (IBAction)infoAction:(id)sender;

@end

