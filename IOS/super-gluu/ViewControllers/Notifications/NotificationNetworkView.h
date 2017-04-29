//
//  NotificationNetworkView.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 4/29/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationNetworkView : UIView

@property (nonatomic, weak) IBOutlet UIButton* retryButton;
@property (nonatomic, assign) BOOL isNetworkAvailable;

-(void)checkNetwork;

@end
