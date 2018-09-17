//
//  VDEAgentDashboardTableViewCell.h
//  VideoEngager
//
//  Created by Bozhko Terziev on 10.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VDEAgentDashboardTableViewCellDelegate;

@interface VDEAgentDashboardTableViewCell : UITableViewCell

@property(nonatomic, strong) NSIndexPath* ip;
@property(nonatomic, strong) NSString* buttonTitle;

@property(nonatomic, weak) id<VDEAgentDashboardTableViewCellDelegate> delegate;

-(void)updateCell;

@end

@protocol VDEAgentDashboardTableViewCellDelegate <NSObject>

-(void)didPressButtonForCell:(VDEAgentDashboardTableViewCell*)cell;

@end
