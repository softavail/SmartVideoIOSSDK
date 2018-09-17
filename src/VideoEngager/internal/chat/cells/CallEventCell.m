//
//  CallEventCell.m
//  leadsecure
//
//  Created by Angel Terziev on 3/21/17.
//  Copyright © 2017 SoftAvail. All rights reserved.
//

#import "CallEventCell.h"
#import "UIColor+Additions.h"

@implementation CallEventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self configureLabelBody];
    [self configureLabelDate];
    [self configureLabelDuration];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - configuration

- (void) configureLabelBody
{
    self.labelBody.textColor = [UIColor callEventTextColor];
    self.labelBody.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
}

- (void) configureLabelDate
{
    self.labelDate.textColor = [UIColor incomingMessageDateColor];
    self.labelDate.font = [UIFont systemFontOfSize:10 weight:UIFontWeightThin];
}

- (void) configureLabelDuration
{
    self.labelDuration.textColor = [UIColor incomingMessageDateColor];
    self.labelDuration.font = [UIFont systemFontOfSize:10 weight:UIFontWeightThin];
}

@end
