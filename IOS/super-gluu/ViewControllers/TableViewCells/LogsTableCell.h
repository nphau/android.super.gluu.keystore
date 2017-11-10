//
//  LogsTableCell.h
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/12/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserLoginInfo.h"
#import "SWTableViewCell.h"

@interface LogsTableCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet UILabel* logTime;
@property (strong, nonatomic) IBOutlet UILabel* logLabel;
@property (strong, nonatomic) IBOutlet UIImageView* logo;

-(void)setData:(UserLoginInfo*)userLoginInfo;

@end
