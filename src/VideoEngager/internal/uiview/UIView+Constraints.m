//
//  UIView+Constraints.m
//  IPMessenger
//
//  Created by Angel Terziev on 4/6/17.
//  Copyright © 2017 SoftAvail, Ltd. All rights reserved.
//

#import "UIView+Constraints.h"

@implementation UIView (Constraints)

+ (void) view:(UIView*) view dumpConstraintsRecursively: (NSMutableString*) dump
{
    [dump appendFormat:@"%@: %@", [[view class] description], view.constraints];
    
    for (UIView* subview in view.subviews) {
        [[self class] view:subview dumpConstraintsRecursively: dump];
    }
}

+ (void) view:(UIView*) view dumpConstraints: (NSMutableString*) dump
{
    [dump appendFormat:@"%@: %@", [[view class] description], view.constraints];
}

- (NSString*) dumpConstraintsRecursively: (BOOL) recursively
{
    NSMutableString* dump = [[NSMutableString alloc] initWithCapacity: 4096];

    if (recursively)
        [[self class] view:self dumpConstraintsRecursively: dump];
    else
        [[self class] view:self dumpConstraints: dump];
    
    return dump;
}

- (void) resizesToSuperviewWithEdgeInsets: (UIEdgeInsets) edgeInsets
{
    if (!self.superview)
        return;
    
    NSLayoutConstraint  *top, *left, *bottom, *right;
    
    top =
    [NSLayoutConstraint constraintWithItem:self
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.superview
                                 attribute:NSLayoutAttributeTop
                                multiplier:1
                                  constant:edgeInsets.top];

    left =
    [NSLayoutConstraint constraintWithItem:self
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.superview
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1
                                  constant:edgeInsets.left];
    bottom =
    [NSLayoutConstraint constraintWithItem:self.superview
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:edgeInsets.bottom];
    right =
    [NSLayoutConstraint constraintWithItem:self.superview
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1
                                  constant:edgeInsets.right];
    
    [self.superview addConstraints:@[top,left,bottom,right]];
}

- (void) removeConstraintsRelatedToItem: (id) item
{
    NSArray<NSLayoutConstraint*> *constraints = [self constraints];
    NSMutableArray<NSLayoutConstraint*> *toremove;

    for (NSLayoutConstraint* constraint in constraints) {
        if (constraint.firstItem == item || constraint.secondItem == item) {
            if (nil == toremove)
                toremove = [[NSMutableArray alloc] init];
            
            [toremove addObject: constraint];
        }
    }
    
    if (nil != toremove)
        [self removeConstraints: toremove];
}

- (NSLayoutConstraint*) alignTopToSuperviewWithOffset: (CGFloat) offset {
    NSLayoutConstraint* constraint;
    if (self.superview) {
        constraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.superview
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1
                                      constant:offset];
        [self.superview addConstraint: constraint];
    }
    
    return constraint;
}

- (NSLayoutConstraint*) alignLeadingToSuperviewWithOffset: (CGFloat) offset {
    NSLayoutConstraint* constraint;
    if (self.superview) {
        constraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.superview
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1
                                      constant:offset];
        [self.superview addConstraint: constraint];
    }
    
    return constraint;
}

- (NSLayoutConstraint*) alignBottomToSuperviewWithOffset: (CGFloat) offset {
    NSLayoutConstraint* constraint;
    if (self.superview) {
        constraint =
        [NSLayoutConstraint constraintWithItem:self.superview
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1
                                      constant:offset];
        [self.superview addConstraint: constraint];
    }
    
    return constraint;
}

- (NSLayoutConstraint*) alignTrailingToSuperviewWithOffset: (CGFloat) offset {
    NSLayoutConstraint* constraint;
    if (self.superview) {
        constraint =
        [NSLayoutConstraint constraintWithItem:self.superview
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1
                                      constant:offset];
        [self.superview addConstraint: constraint];
    }
    
    return constraint;
}

- (NSLayoutConstraint*) alignCenterXToSuperviewWithOffset: (CGFloat) offset
                             andMultiplier: (CGFloat) multiplier
{
    NSLayoutConstraint* constraint;
    if (self.superview) {
        constraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.superview
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:multiplier
                                      constant:offset];
        [self.superview addConstraint: constraint];
    }
    
    return constraint;
}

- (NSLayoutConstraint*) alignCenterXToSuperview {
    return [self alignCenterXToSuperviewWithOffset:0 andMultiplier:1];
}

- (NSLayoutConstraint*) alignCenterYToSuperview {
    return [self alignCenterYToSuperviewWithOffset:0 andMultiplier:1];
}


- (NSLayoutConstraint*) alignCenterYToSuperviewWithOffset: (CGFloat) offset
                             andMultiplier: (CGFloat) multiplier
{
    NSLayoutConstraint* constraint;
    if (self.superview) {
        constraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.superview
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:multiplier
                                      constant:offset];
        [self.superview addConstraint: constraint];
    }
    
    return constraint;
}

- (NSLayoutConstraint*) alignCenterXToSuperviewHeightWithMultiplier: (CGFloat) multiplier {
    NSLayoutConstraint* constraint;
    if (self.superview) {
        constraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.superview
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:multiplier
                                      constant:0];
        [self.superview addConstraint: constraint];
    }
    
    return constraint;
}

- (NSLayoutConstraint*) alignCenterYToSuperviewHeightWithMultiplier: (CGFloat) multiplier {
    NSLayoutConstraint* constraint;
    if (self.superview) {
        constraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.superview
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:multiplier
                                      constant:0];
        [self.superview addConstraint: constraint];
    }
    
    return constraint;
}

- (NSLayoutConstraint*) constrainWidth: (CGFloat) width {
    NSLayoutConstraint* c =
    [NSLayoutConstraint constraintWithItem:self
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1
                                  constant:width];
    [self addConstraint: c];
    return c;
}

- (NSLayoutConstraint*) constrainHeight: (CGFloat) height {
    NSLayoutConstraint* c =
    [NSLayoutConstraint constraintWithItem:self
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1
                                  constant:height];
    [self addConstraint: c];
    return c;
}

- (NSLayoutConstraint*) horzSpaceWithLeftItem: (id) leftView
                                  toRightItem: (id) rightView
                                     constant: (CGFloat) constant
{
    NSLayoutConstraint* c =
    [NSLayoutConstraint constraintWithItem:rightView
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:leftView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1
                                  constant:constant];
    [self addConstraint:c];
    return c;
}

- (NSLayoutConstraint*) vertSpaceWithTopItem: (id) topView
                                toBottomItem: (id) bottomView
                                    constant: (CGFloat) constant
{
    NSLayoutConstraint* c =
    [NSLayoutConstraint constraintWithItem:topView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:bottomView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1
                                  constant:constant];
    [self addConstraint:c];
    return c;
}

- (NSLayoutConstraint*) equalHeightsToSuperViewWithMultiplier: (CGFloat) multiplier {
    NSLayoutConstraint* constraint;
    if (self.superview) {
        constraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.superview
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:multiplier
                                      constant:0];
        [self.superview addConstraint: constraint];
    }
    
    return constraint;
}

- (NSLayoutConstraint*) aspectWidthToSuperviewHeightWithMultiplier: (CGFloat) multiplier {

    NSLayoutConstraint* constraint;
    if (self.superview) {
        constraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.superview
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:multiplier
                                      constant:0];
        [self.superview addConstraint: constraint];
    }
    
    return constraint;
    
}
@end



