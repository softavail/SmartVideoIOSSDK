//
//  ChatMessageInCellBase.m
//  instac
//
//  Created by Bozhko Terziev on 11/20/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "ChatMessageInCellBase.h"

@interface ChatMessageInCellBase ()

@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;

@end

@implementation ChatMessageInCellBase

- ( id )
initWithStyle       : ( UITableViewCellStyle    ) style
reuseIdentifier     : ( NSString *              ) reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( nil != self )
    {
        
    }
    
    return self;
}

- ( void )
layoutSubviews
{
    [super layoutSubviews];
    
    self.accessibilityIdentifier = self.labelBodyText;
    
    if ( nil != self.tapGesture )
        self.tapGesture.enabled = self.enableTapGesture;
}

- ( void )
awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userInteractionEnabled = NO;
    self.bHideSender = NO;
    
    if ( nil == self.tapGesture )
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    
    if ( nil != self.tapGesture )
        [self addGestureRecognizer:self.tapGesture];
}

- ( void )
tap: ( UITapGestureRecognizer* ) gesture
{
    if ( nil != self.delegate && [self.delegate respondsToSelector:@selector(didSelectIncomingCell:)] )
        [self.delegate performSelector:@selector(didSelectIncomingCell:) withObject:self];
}

@end
