//
//  ICOLLActivityView.h
//  instac
//
//  Created by Bozhko Terziev on 11/19/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "ICOLLActivityView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Additions.h"

NSInteger kTagActivityView = 7304;

@interface ICOLLActivityView ()

@end

@implementation ICOLLActivityView

- ( UIActivityIndicatorView* )
activiyIndicatorView
{
    UIActivityIndicatorView* ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(self.activitySize == ActivitySizeBig) ? UIActivityIndicatorViewStyleWhiteLarge : UIActivityIndicatorViewStyleWhite];
    
    if ( nil != ai )
    {
        ai.hidesWhenStopped = YES;
        
        ai.frame = CGRectMake((CGRectGetWidth(self.baseView.bounds) - CGRectGetWidth(ai.bounds))/2,
                              2*CGRectGetHeight(self.baseView.bounds)/3 + (CGRectGetHeight(self.baseView.bounds)/3 - CGRectGetHeight(ai.bounds))/2,
                              CGRectGetWidth(ai.bounds),
                              CGRectGetHeight(ai.bounds));
    }
    
    return ai;
}

- ( UILabel* )
activityLabel
{
    CGRect rect = self.baseView.bounds;
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(rect), CGRectGetHeight(rect)/3)];
    
    if ( nil != lbl )
    {
        lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        lbl.textColor = [UIColor activityTextColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:( self.activitySize == ActivitySizeBig ) ? 19 : 15 weight:UIFontWeightRegular];
        lbl.numberOfLines = 0;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.text = @"";
    }
    
    return lbl;
}

- ( UIView* )
baseViewActivity
{
    CGSize viewSize = CGSizeMake(290, 210);
    CGRect rect = CGRectMake(CGRectGetWidth(self.bounds)/2 - viewSize.width/2,
                             CGRectGetHeight(self.bounds)/2 - viewSize.height/2,
                             viewSize.width,
                             viewSize.height);
    
    UIView* v = [[UIView alloc] initWithFrame:rect];
    
    if ( nil != v )
    {
        v.backgroundColor = [UIColor clearColor];
        v.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    return v;
}

- ( id )
initWithFrame   : ( CGRect          ) frame
andActivitySize : ( ActivitySize    ) aSize
{
    self = [super initWithFrame:frame];
    
    if ( nil != self )
    {
        self.isHideActivityInProgress = NO;
        self.activitySize = aSize;
        self.tag = kTagActivityView;
        self.backgroundColor = [UIColor activityBackgroundColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.animating          = NO;
        self.baseView           = [self baseViewActivity];
        self.activityIndicator  = [self activiyIndicatorView];
        self.labelActivity      = [self activityLabel];
        
        if ( nil != self.activityIndicator && nil != self.labelActivity && nil != self.baseView )
        {
            [self.baseView addSubview:self.activityIndicator];
            [self.activityIndicator startAnimating];
            
            [self.baseView addSubview:self.labelActivity];
            
            [self.baseView bringSubviewToFront:self.activityIndicator];
            [self.baseView bringSubviewToFront:self.labelActivity];
            
            [self addSubview:self.baseView];
            [self bringSubviewToFront:self.baseView];
        }
    }
    
    return self;
}

-(void) dealloc
{
    NSLog(@" %s - deallocating %p", __PRETTY_FUNCTION__, self);
}

- ( void )
setActivityText: ( NSString* ) text
{
    if ( nil != self.labelActivity )
        self.labelActivity.text= text;
}

- ( void )
hideWithAnimation: ( BOOL ) yorn
{
    if ( self.isHideActivityInProgress )
    {
        NSLog(@"Prevent %@ from removing twice", self.class);
        return;
    }

    self.isHideActivityInProgress = YES;

    if ( yorn )
    {
        [UIView animateWithDuration:0.3
                         animations:^(void){
                             self.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             [self.activityIndicator stopAnimating];
                             [self removeFromSuperview];
                             NSLog(@" %s - %p", __PRETTY_FUNCTION__, self);
                         }];
    }
    else
    {
        [self.activityIndicator stopAnimating];
        [self removeFromSuperview];
    }
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    NSLog(@" %s - %p", __PRETTY_FUNCTION__, self);
}

//- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
//{
//    CABasicAnimation* rotationAnimation;
//    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
//    rotationAnimation.duration = duration;
//    rotationAnimation.cumulative = YES;
//    rotationAnimation.repeatCount = repeat;
//    
//    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
//}
//
@end
