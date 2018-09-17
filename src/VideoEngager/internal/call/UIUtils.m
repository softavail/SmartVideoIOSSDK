//
//  UIUtils.m
//  leadsecure
//
//  Created by ivan shulev on 3/28/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "UIUtils.h"

@implementation UIUtils

+ (BOOL)isIphone5Screen
{
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat minDimension = MIN(screenSize.size.height, screenSize.size.width);
    
    return minDimension == 320.0;
}

@end
