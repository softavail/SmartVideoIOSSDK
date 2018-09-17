//
//  ParticipantInfoView.m
//  leadsecure
//
//  Created by ivan shulev on 4/6/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "ParticipantInfoView.h"

#import "UIUtils.h"
#import "PureLayout.h"

static CGFloat kLabelsVerticalDistanceForScreenWidth320 = 5.0;
static CGFloat kLabelsVerticalDistance = 10.0;
static CGFloat kLabelsHorizontalDistance = 10.0;

@implementation ParticipantInfoView
{
    NSArray<ParticipantInfoItem*>* _participantInfoItems;
    NSMutableArray<UILabel*>* _titleLabels;
    NSMutableArray<UILabel*>* _valueLabels;
    BOOL _didSetConstraints;
}

- (instancetype)initWithParticipantInfoItems:(NSArray<ParticipantInfoItem*>*)participantInfoItems
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    _participantInfoItems = participantInfoItems;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor clearColor];
    
    [self setupInfoItemLabels];
    
    return self;
}

- (void)setupInfoItemLabels
{
    _titleLabels = [[NSMutableArray alloc] init];
    _valueLabels = [[NSMutableArray alloc] init];
    
    for (ParticipantInfoItem* participantInfoItem in _participantInfoItems)
    {
        UILabel* titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightUltraLight];
        titleLabel.text = [NSString stringWithFormat:@"%@:", participantInfoItem.title];
        
        UILabel* valueLabel = [[UILabel alloc] init];
        valueLabel.textColor = [UIColor whiteColor];
        valueLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightUltraLight];
        valueLabel.text = participantInfoItem.value;
        valueLabel.textAlignment = NSTextAlignmentLeft;
        
        [_titleLabels addObject:titleLabel];
        [_valueLabels addObject:valueLabel];
        
        [self addSubview:titleLabel];
        [self addSubview:valueLabel];
    }
}

- (void)updateValueWithText:(NSString*)text
                   forTitle:(NSString*)title
{
    [_participantInfoItems enumerateObjectsUsingBlock:^(ParticipantInfoItem * _Nonnull participantInfoItem,
                                                        NSUInteger index,
                                                        BOOL * _Nonnull stop)
    {
        if ([title isEqualToString:participantInfoItem.title])
        {
            _valueLabels[index].text = text;
            *stop = YES;
        }
    }];
}

- (void)updateConstraints
{
    if (!_didSetConstraints)
    {
        [_titleLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull titleLabel, NSUInteger index, BOOL * _Nonnull stop)
        {
            [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading];
            
            CGRect screenSize = [[UIScreen mainScreen] bounds];
            CGFloat minDimension = MIN(screenSize.size.height, screenSize.size.width);
            
            CGFloat labelsVerticalDistance = kLabelsVerticalDistance;
            
            if (minDimension == 320.0)
            {
                labelsVerticalDistance = kLabelsVerticalDistanceForScreenWidth320;
            }
            
            if (index == 0)
            {
                [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
            }
            else
            {
                [titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleLabels[index - 1] withOffset:labelsVerticalDistance];
            }
            
            [NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultHigh
                                 forConstraints:^{
                                     [titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
                                 }];
        }];
        
        [_valueLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull valueLabel, NSUInteger index, BOOL * _Nonnull stop)
        {
            [valueLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_titleLabels[index] withOffset:kLabelsHorizontalDistance];
            
            [valueLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_titleLabels[index]];
            
            [NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultLow
                                 forConstraints:^{
                                     [valueLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
                                     [valueLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0.0 relation:NSLayoutRelationGreaterThanOrEqual];
                                 }];
        }];
        
        _didSetConstraints = YES;
    }
    
    [super updateConstraints];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
{
    if ([UIUtils isIphone5Screen])
    {
        CGFloat fontSize = 17.0;
        
        if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact)
        {
            fontSize = 15.0;
        }
        
        for (UILabel* titleLabel in _titleLabels)
        {
            titleLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightBold];
        }
        
        for (UILabel* valueLabel in _valueLabels)
        {
            valueLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightBold];
        }
    }
}

@end
