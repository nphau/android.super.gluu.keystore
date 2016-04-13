//
//  SettingsViewController.h
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/9/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeysViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{

    NSMutableArray* keyHandleArray;
    IBOutlet UITableView* keyHandleTableView;
    IBOutlet UILabel* keyHandleLabel;
    IBOutlet UILabel* keyRenameInfoLabel;
    IBOutlet UILabel* uniqueKeyLabel;
    IBOutlet UIButton* logsButton;
    IBOutlet UIButton* infoButton;
    int rowToDelete;
    NSIndexPath* selectedRow;
    
    BOOL isLandScape;
}

@end
