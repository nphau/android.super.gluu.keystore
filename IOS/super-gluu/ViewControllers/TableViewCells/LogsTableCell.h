//
//  LogsTableCell.h
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/12/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogsTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel* logTime;
@property (strong, nonatomic) IBOutlet UILabel* logLabel;
@property (strong, nonatomic) IBOutlet UIView* cellBackground;
@property (strong, nonatomic) IBOutlet UIButton* infoButton;

-(void)setData:(NSString*)logs;

@end
