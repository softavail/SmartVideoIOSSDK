//
//  UIView+Constraints.h
//  IPMessenger
//
//  Created by Angel Terziev on 4/6/17.
//  Copyright © 2017 SoftAvail, Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Constraints)

- (NSString*) dumpConstraintsRecursively: (BOOL) recursively;

- (void) resizesToSuperviewWithEdgeInsets: (UIEdgeInsets) edgeInsets;
- (void) removeConstraintsRelatedToItem: (id) item;
- (NSLayoutConstraint*) alignTopToSuperviewWithOffset: (CGFloat) offset;
- (NSLayoutConstraint*) alignLeadingToSuperviewWithOffset: (CGFloat) offset;
- (NSLayoutConstraint*) alignBottomToSuperviewWithOffset: (CGFloat) offset;
- (NSLayoutConstraint*) alignTrailingToSuperviewWithOffset: (CGFloat) offset;
- (NSLayoutConstraint*) alignCenterXToSuperviewWithOffset: (CGFloat) offset andMultiplier: (CGFloat) multiplier;
- (NSLayoutConstraint*) alignCenterYToSuperviewWithOffset: (CGFloat) offset andMultiplier: (CGFloat) multiplier;
- (NSLayoutConstraint*) alignCenterXToSuperview;
- (NSLayoutConstraint*) alignCenterYToSuperview;
- (NSLayoutConstraint*) constrainWidth: (CGFloat) width;
- (NSLayoutConstraint*) constrainHeight: (CGFloat) height;
- (NSLayoutConstraint*) horzSpaceWithLeftItem: (id) view1
                                  toRightItem: (id) view2
                                     constant: (CGFloat) constant;
- (NSLayoutConstraint*) vertSpaceWithTopItem: (id) topView
                                toBottomItem: (id) bottomView
                                     constant: (CGFloat) constant;
- (NSLayoutConstraint*) equalHeightsToSuperViewWithMultiplier: (CGFloat) multiplier;
- (NSLayoutConstraint*) aspectWidthToSuperviewHeightWithMultiplier: (CGFloat) multiplier;

@end
