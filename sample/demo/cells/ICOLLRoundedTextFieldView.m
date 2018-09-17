//
//  ICOLLRoundedTextFieldView.m
//  instac
//
//  Created by Bozhko Terziev on 11/21/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "ICOLLRoundedTextFieldView.h"
#import "UIColor+Additions.h"

static const CGFloat borderWidth    = 1;
static const CGFloat cornerRadius   = 5;

@interface ICOLLRoundedTextFieldView ()



@end

@implementation ICOLLRoundedTextFieldView

- ( void )
initMe
{
    self.hasBorder = NO;
    self.backgroundColor = [UIColor cellTextFieldBackgroundColor];
}

- ( id )
initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if ( nil != self )
    {
        [self initMe];
    }
    
    return self;
}

- ( id )
initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if ( nil != self )
    {
        [self initMe];
    }
    
    return self;
}

- ( void )
setHasBorder:(BOOL)hasBorder
{
    _hasBorder = hasBorder;
    
    [self.layer removeAllAnimations];
    [self changeBorder];
}

- ( void )
animate
{
    UIColor* fromColor  = self.hasBorder ? [UIColor clearColor] : [UIColor greenBorderColor];
    UIColor* toColor    = !self.hasBorder ? [UIColor clearColor] : [UIColor blueBorderColor];
    
    CABasicAnimation *color = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    // animate from red to blue border ...
    color.fromValue = (id)fromColor.CGColor;
    color.toValue   = (id)toColor.CGColor;
    // ... and change the model value
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    CABasicAnimation *width = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    // animate from 2pt to 4pt wide border ...
    width.fromValue = @1;
    width.toValue   = @2;
    // ... and change the model value
    self.layer.borderWidth = borderWidth;
    
    CAAnimationGroup *both = [CAAnimationGroup animation];
    // animate both as a group with the duration of 0.5 seconds
    both.duration   = 0.3;
    both.animations = @[color, width];
    // optionally add other configuration (that applies to both animations)
    both.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.layer addAnimation:both forKey:@"color and width"];
}

- ( void )
changeBorder
{
//    if ( self.hasBorder )
//    {
//        self.layer.cornerRadius = cornerRadius;//CGRectGetHeight(self.bounds)/2;
//        self.layer.borderWidth = borderWidth;
//        self.layer.borderColor = [UIColor blueBorderColor].CGColor;
//        self.layer.masksToBounds = YES;
//    }
//    else
//    {
//        self.layer.cornerRadius = cornerRadius;//CGRectGetHeight(self.bounds)/2;
//        self.layer.borderWidth = borderWidth;
//        self.layer.masksToBounds = YES;
//        self.layer.borderColor = [UIColor loginSectionEndColor].CGColor;
//    }
//    
    //[self animate];
}

@end
