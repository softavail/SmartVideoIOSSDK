//
//  UIBarButtonItem+Additions.m
//  VideoEngager
//
//  Created by Angel Terziev on 10.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "UIBarButtonItem+Additions.h"

@implementation UIBarButtonItem (Additions)

+ (UIBarButtonItem*) fixedSpaceBarButtonItemWithWidth:(CGFloat)width{
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = width;
    return fixedItem;
}

+ (UIBarButtonItem*) flexibleSpaceBarButtonItem {
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return bbi;
}

+ (UIBarButtonItem*) barButtonItemWithImageName:(NSString*) imgName target:(id) target action:(SEL) action {
    
    UIImage* image = [UIImage imageNamed: imgName];
    UIBarButtonItem* bbi =
    [[UIBarButtonItem alloc] initWithImage:image
                                     style:UIBarButtonItemStylePlain
                                    target:target
                                    action:action];
    
    return bbi;
}

+ (UIBarButtonItem*) barButtonItemWithImage:(UIImage*) image enabled: (BOOL) enabled target:(id) target action:(SEL) action {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.backgroundColor = [UIColor clearColor];
    
    [button setImage: image forState: UIControlStateNormal];
    
    button.enabled = enabled;
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [button sizeToFit];
    
    UIBarButtonItem* bbi =  [[UIBarButtonItem alloc] initWithCustomView:button];
    bbi.enabled = enabled;
    bbi.width = button.bounds.size.width;
    
    return bbi;
}

@end
