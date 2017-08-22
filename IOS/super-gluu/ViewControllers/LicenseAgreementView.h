//
//  LicenseAgreementView.h
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/2/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <CoreLocation/CoreLocation.h>

@interface LicenseAgreementView : UIViewController {
    
    IBOutlet UIView* topView;
}

@property (strong, nonatomic) IBOutlet UITextView* licenseTextField;
@property (strong, nonatomic) IBOutlet UIButton* acceptButton;
@property (strong, nonatomic) IBOutlet UIButton* backButton;

@property (assign) BOOL isFromSettings;

@end
