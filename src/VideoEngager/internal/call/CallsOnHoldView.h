//
//  CallsOnHoldView.h
//  leadsecure
//
//  Created by ivan shulev on 3/25/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CallOnHoldTableViewCell.h"
#import "ListParticipantsOnHoldOperation.h"
#import "LSParticipant.h"

@class CallsOnHoldView;

@protocol CallsOnHoldViewDelegate <NSObject>

- (void)callsOnHoldView:(CallsOnHoldView*)callsOnHoldView
didPressResumeOnParticipant:(LSParticipant*)participant;

@end

@interface CallsOnHoldView : UIView <UITableViewDataSource,
                                     UITableViewDelegate,
                                     CallOnHoldTableViewCellDelegate>

@property (nonatomic, weak) id <CallsOnHoldViewDelegate> delegate;

- (instancetype)initWithListParticipants:(ListParticipantsOnHoldOperation*)listParticipantsOnHoldOperation;

@end
