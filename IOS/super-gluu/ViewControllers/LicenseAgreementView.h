//
//  LicenseAgreementView.h
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/2/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LicenseAgreementView : UIViewController <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) IBOutlet UILabel* titleLabel;
//@property (strong, nonatomic) IBOutlet UILabel* titleLabel;
@property (strong, nonatomic) IBOutlet UIButton* acceptButton;

@end
