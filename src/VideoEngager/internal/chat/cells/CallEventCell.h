//
//  CallEventCell.h
//  leadsecure
//
//  Created by Angel Terziev on 3/21/17.
//  Copyright © 2017 SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallEventCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelBody;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelDuration;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLabelBodyLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLabelBodyHorizontalSpaceToLabelDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLabelDateRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLabelDateTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLabelDurationBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLabelBodyVerticalSpaceToLabelDuration;

@end
