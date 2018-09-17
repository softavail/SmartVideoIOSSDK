//
//  UIBarButtonItem+Additions.h
//  VideoEngager
//
//  Created by Angel Terziev on 10.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Additions)

+ (UIBarButtonItem*) fixedSpaceBarButtonItemWithWidth:(CGFloat)width;
+ (UIBarButtonItem*) flexibleSpaceBarButtonItem;
+ (UIBarButtonItem*) barButtonItemWithImageName:(NSString*) imgName target:(id) target action:(SEL) action;
+ (UIBarButtonItem*) barButtonItemWithImage:(UIImage*) image enabled: (BOOL) enabled target:(id) target action:(SEL) action;

@end
