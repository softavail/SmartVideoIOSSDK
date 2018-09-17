//
//  LoginButtonCell.h
//  leadsecure
//
//  Created by Bozhko Terziev on 9/28/15.
//  Copyright © 2015 SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginButtonModel.h"
#import "LoginButtonCell.h"


@protocol LoginButtonCellDelegate;

@interface LoginButtonCell : UITableViewCell
{
    
}

@property(nonatomic, strong)LoginButtonModel* model;
@property(nonatomic, weak)id <LoginButtonCellDelegate> delegate;

- (void) updateButtonTitle;
- (void) updateCell;

@end


@protocol LoginButtonCellDelegate <NSObject>

-(void)didPressButton: (UIButton*) button forCell:(LoginButtonCell*) cell;

@end
