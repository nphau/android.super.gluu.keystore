//
//  LogsViewController.h
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/12/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell/SWTableViewCell.h>

@interface LogsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>{

    NSMutableArray* logsArray;
    IBOutlet UIView* topView;
    IBOutlet UIImageView* topIconView;
    IBOutlet UITableView* logsTableView;
    IBOutlet UIButton* editLogsButton;
    IBOutlet UIButton* cancelButton;
    IBOutlet UILabel* noLogsLabel;
    IBOutlet UIView* contentView;
}

@end
