//
//  CallOnHoldTableViewCell.h
//  leadsecure
//
//  Created by ivan shulev on 3/25/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSParticipant.h"

@class CallOnHoldTableViewCell;

@protocol CallOnHoldTableViewCellDelegate <NSObject>

- (void)callOnHoldTableViewCell:(CallOnHoldTableViewCell*)callOnHoldTableViewCell
   didPressResumeForParticipant:(LSParticipant*)participant;

@end

@interface CallOnHoldTableViewCell : UITableViewCell

@property (nonatomic, weak) id <CallOnHoldTableViewCellDelegate> delegate;

- (void)setupWithParticipant:(LSParticipant*)participant;

@end
