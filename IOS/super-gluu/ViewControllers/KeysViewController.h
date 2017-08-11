//
//  SettingsViewController.h
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/9/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell/SWTableViewCell.h>

@interface KeysViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>{

    NSMutableArray* keyHandleArray;
    IBOutlet UIView* topView;
    IBOutlet UIImageView* topIconView;
    IBOutlet UITableView* keyHandleTableView;
    IBOutlet UILabel* keyHandleLabel;
    IBOutlet UILabel* uniqueKeyLabel;
    int rowToDelete;
    
    BOOL isLandScape;
    
    NSMutableDictionary* keyCells;
}

@end
