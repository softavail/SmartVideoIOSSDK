//
//  LoginButtonCell.m
//  leadsecure
//
//  Created by Bozhko Terziev on 9/28/15.
//  Copyright © 2015 SoftAvail. All rights reserved.
//

#import "LoginButtonCell.h"
#import "UIColor+Additions.h"

@interface LoginButtonCell ()

@property (weak, nonatomic) IBOutlet UIButton *button;


@end

@implementation LoginButtonCell

- ( void )
awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor    = [UIColor cellBackgroundColor];
    self.selectionStyle     = UITableViewCellSelectionStyleNone;
}

- ( void )
layoutSubviews
{
    [super layoutSubviews];
}

- ( void )
setModel:(LoginButtonModel *)model
{
    _model = model;
}

- (void) updateCell {
    
    [self.button setTitle:self.model.buttonTitle forState:UIControlStateNormal];
    self.button.enabled = self.model.enabled;
    
    [self.button.titleLabel setFont:self.model.buttonTitleFont];
    [self.button setTitleColor:self.model.buttonTitleColor forState:UIControlStateNormal];
    
    [self.button setBackgroundImage:[self.model.buttonImages[0] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    [self.button setBackgroundImage:[self.model.buttonImages[1] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateSelected];
    [self.button setBackgroundImage:[self.model.buttonImages[1] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted];
    [self.button setBackgroundImage:[self.model.buttonImages[1] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateDisabled];
    
    NSArray* actions = [self.button actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
    
    for ( NSString* action in actions )
        [self.button removeTarget:self action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
    
    [self.button addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    
    if (0 == self.model.idxPath.row%2)
        self.backgroundColor = [UIColor cellBackgroundColor];
    else
        self.backgroundColor = [UIColor cellBackgroundColorLight];    
}

- (void) updateButtonTitle
{
    [self.button setTitle:self.model.buttonTitle forState:UIControlStateNormal];
}

- (void) onButton: (UIButton*) button {
    
    if ( nil != self.delegate && [self.delegate respondsToSelector:@selector(didPressButton:forCell:)] )
        [self.delegate didPressButton:self.button forCell:self];
}

@end
