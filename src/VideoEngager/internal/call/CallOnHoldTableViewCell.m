//
//  CallOnHoldTableViewCell.m
//  leadsecure
//
//  Created by ivan shulev on 3/25/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "CallOnHoldTableViewCell.h"

#import "PureLayout.h"
#import "UIColor+Additions.h"

static CGFloat kCallerNameButtonMinInterspace = 20.0;

@implementation CallOnHoldTableViewCell
{
    UILabel* _callerNameLabel;
    UIButton* _resumeButton;
    BOOL _didSetConstraints;
    
    LSParticipant* _participant;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self == nil)
    {
        return nil;
    }
    
    self.backgroundColor = [UIColor clearColor];
    
    _callerNameLabel = [[UILabel alloc] init];
    _callerNameLabel.textColor = [UIColor whiteColor];
    _callerNameLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    [self.contentView addSubview:_callerNameLabel];
    
    _resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resumeButton setImage:nil forState:UIControlStateNormal];
    [_resumeButton setBackgroundImage:nil forState:UIControlStateNormal];
    [_resumeButton setTitle:@"Resume" forState:UIControlStateNormal];
    [_resumeButton setTitleColor:[UIColor videoSceneResumeButtonLabelsColor] forState:UIControlStateNormal];
    _resumeButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightLight];
    _resumeButton.layer.borderColor = [[UIColor videoSceneResumeButtonLabelsColor] CGColor];
    _resumeButton.layer.borderWidth = 1.0;
    _resumeButton.layer.cornerRadius = 17.0;
    [_resumeButton setContentEdgeInsets:UIEdgeInsetsMake(7.0, 15.0, 7.0, 15.0)];
    
    [_resumeButton addTarget:self
                      action:@selector(resumeAction:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_resumeButton];
    
    return self;
}

- (void)setupWithParticipant:(LSParticipant*)participant
{
    _participant = participant;
    
    NSString* participantName = [_participant name];
    
    if (!participantName || [participantName isEqualToString:@""])
    {
        participantName = ICOLLString(@"Vanity:Participant:Caller");
    }
    
    _callerNameLabel.text = participantName;
}

- (void)updateConstraints
{
    if (!_didSetConstraints)
    {
        _didSetConstraints = YES;
    }
    
    [_callerNameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:40.0];
    [_callerNameLabel autoPinEdge:ALEdgeTrailing
                           toEdge:ALEdgeLeading
                           ofView:_resumeButton
                       withOffset:-kCallerNameButtonMinInterspace];
    [_callerNameLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [_resumeButton autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:40.0];
    [_resumeButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    CGSize labelSize = [_resumeButton.titleLabel intrinsicContentSize];
    [_resumeButton autoSetDimensionsToSize:CGSizeMake(labelSize.width +
                                                      _resumeButton.contentEdgeInsets.left +
                                                      _resumeButton.contentEdgeInsets.right,
                                                      labelSize.height +
                                                      _resumeButton.contentEdgeInsets.top +
                                                      _resumeButton.contentEdgeInsets.bottom)];
    
    [super updateConstraints];
}

- (void)resumeAction:(id)sender
{
    [self.delegate callOnHoldTableViewCell:self didPressResumeForParticipant:_participant];
}

@end
