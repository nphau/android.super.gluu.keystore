//
//  KeyHandleCell.h
//  oxPush2-IOS
//
//  Created by Nazar Yavornytskyy on 2/10/16.
//  Copyright © 2016 Nazar Yavornytskyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TokenEntity.h"
#import "SWTableViewCell.h"

@interface KeyHandleCell : SWTableViewCell {

    IBOutlet UILabel* keyHandleTime;
}

@property (strong, nonatomic) NSString* key;
@property (strong, nonatomic) IBOutlet UILabel* keyHandleNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* bleLabel;

-(void)setData:(TokenEntity*)tokenEntity;

@end
